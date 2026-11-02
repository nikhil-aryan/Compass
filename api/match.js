import { tmpdir } from "node:os";
import { join } from "node:path";
import { neon } from "@neondatabase/serverless";

// GET /api/match?q=...  (COM-19 matching). Response shape: docs/data-contract.md
// 1. Classify the query into a problem type with a small open embedding model that runs
//    inside this function (no external AI service). Falls back to keywords if it can't load.
// 2. Look up the skills that problem type needs (problem_type_skills).
// 3. Rank people on those skills (employee_skills), on past experience (how close their
//    expertise and projects are to the query) and on a free slot soon.
// Uses the database schema as it is (db/schema.sql); nothing here needs new tables or columns.

const MODEL = "Xenova/all-MiniLM-L6-v2";
const MIN_SIMILARITY = 0.35;      // below this the query matches no problem type
const KEYWORD_BONUS = 0.1;        // added when a catalogue keyword appears in the query
const WEIGHTS = { skills: 0.5, experience: 0.3, availability: 0.2 };
const EXPERIENCE_RANGE = [0.3, 0.6]; // similarity mapped to an experience score of 0..1
const EXPERIENCE_MIN = 0.5;       // experience score that counts as "has handled this before"
const WINDOW_DAYS = 14;           // slots further away don't count
// availability_slots only has starts_at. Until calendar sync exists, each slot is
// treated as a free 2-hour block.
const FULL_SCORE_DAYS = 3;        // a slot within this many days gets the full availability score
const MAX_EXPERTS = 20;

let embedderPromise = null;       // reused while the function stays warm
const vectorCache = new Map();

function getEmbedder() {
  if (!embedderPromise) {
    embedderPromise = import("@huggingface/transformers").then(({ pipeline, env }) => {
      env.cacheDir = join(tmpdir(), "hf-cache"); // only the temp dir is writable on Vercel
      return pipeline("feature-extraction", MODEL, { dtype: "q8" });
    });
    embedderPromise.catch(() => { embedderPromise = null; }); // retry on the next request
  }
  return embedderPromise;
}

async function embed(texts) {
  const embedder = await getEmbedder();
  const out = await embedder(texts, { pooling: "mean", normalize: true });
  return out.tolist();
}

async function cachedVectors(texts) {
  const missing = texts.filter((t) => !vectorCache.has(t));
  if (missing.length) (await embed(missing)).forEach((v, i) => vectorCache.set(missing[i], v));
  return texts.map((t) => vectorCache.get(t));
}

const dot = (a, b) => a.reduce((s, x, i) => s + x * b[i], 0); // vectors are normalised

function keywordHits(query, type) {
  const q = query.toLowerCase();
  return (type.keywords || []).filter((k) => q.includes(k.toLowerCase())).length;
}

// Each type is described by its name + description and by each of its keywords;
// the query's best similarity to any of them is the type's score.
async function classify(query, types) {
  try {
    const texts = types.map((t) => [`${t.name}. ${t.description || ""}`, ...(t.keywords || [])]);
    const [qv] = await embed([query]);
    let best = null;
    for (let i = 0; i < types.length; i++) {
      const vs = await cachedVectors(texts[i]);
      const score = Math.max(...vs.map((v) => dot(qv, v))) + (keywordHits(query, types[i]) ? KEYWORD_BONUS : 0);
      if (!best || score > best.score) best = { type: types[i], score };
    }
    return best && best.score >= MIN_SIMILARITY ? { ...best, method: "embedding", qv } : { type: null, score: best ? best.score : 0, method: "embedding" };
  } catch (err) {
    let best = null;
    for (const t of types) {
      const hits = keywordHits(query, t);
      if (hits && (!best || hits > best.score)) best = { type: t, score: hits };
    }
    return best ? { ...best, method: "keyword" } : { type: null, score: 0, method: "keyword" };
  }
}

// Past experience: the person's expertise or project closest to the query.
// Returns { experience: 0..1, evidence: project name or null } per row.
async function experienceFor(rows, type, qv) {
  const textsOf = (r) => [r.expertise, ...r.projects];
  if (qv) {
    try {
      const all = [...new Set(rows.flatMap(textsOf))];
      const vecs = new Map((await cachedVectors(all)).map((v, i) => [all[i], v]));
      const [lo, hi] = EXPERIENCE_RANGE;
      return rows.map((r) => {
        const sims = textsOf(r).map((t) => dot(qv, vecs.get(t)));
        const i = sims.indexOf(Math.max(...sims));
        const experience = Math.min(1, Math.max(0, (sims[i] - lo) / (hi - lo)));
        return { experience, evidence: i > 0 ? r.projects[i - 1] : null };
      });
    } catch (err) {
      // fall through to keywords
    }
  }
  const words = type.keywords || [];
  return rows.map((r) => {
    const hit = (t) => words.some((k) => t.toLowerCase().includes(k.toLowerCase()));
    const project = r.projects.find(hit);
    return { experience: project || hit(r.expertise) ? 1 : 0, evidence: project || null };
  });
}

function fmtDay(iso) {
  return new Date(iso).toLocaleString("en-GB", { weekday: "short", day: "numeric", month: "short", hour: "2-digit", minute: "2-digit", timeZone: "Europe/Madrid" });
}

function availabilityScore(slots, now) {
  if (!slots.length) return 0;
  const days = (new Date(slots[0]) - now) / 86400000;
  if (days <= FULL_SCORE_DAYS) return 1;
  return Math.max(0, 1 - (days - FULL_SCORE_DAYS) / (WINDOW_DAYS - FULL_SCORE_DAYS));
}

function reasonFor(matched, needed, experience, evidence, slots) {
  const parts = [];
  if (matched.length) parts.push(`Has ${matched.length} of ${needed.length} skills this needs (${matched.join(", ")})`);
  if (experience >= EXPERIENCE_MIN) parts.push(evidence ? `worked on ${evidence}` : "expertise fits this problem");
  parts.push(slots.length ? `free ${fmtDay(slots[0])}` : "no free slot in the next two weeks");
  const text = parts.join("; ");
  return text.charAt(0).toUpperCase() + text.slice(1) + ".";
}

export default async function handler(req, res) {
  const query = String(req.query.q || "").trim().slice(0, 500);
  if (!query) return res.status(400).json({ error: "Missing query" });

  try {
    const sql = neon(process.env.DATABASE_URL);
    const types = await sql`
      SELECT id, slug, name, description, COALESCE(keywords, '{}') AS keywords, file_url, file_name
      FROM problem_types ORDER BY id`;

    const match = await classify(query, types);
    const base = { query, classification: { method: match.method, score: Math.round(match.score * 100) / 100 } };
    if (!match.type) return res.status(200).json({ ...base, problemType: null, state: "no_match", experts: [] });

    const pt = match.type;
    const needed = (await sql`
      SELECT s.name FROM problem_type_skills pts JOIN skills s ON s.id = pts.skill_id
      WHERE pts.problem_type_id = ${pt.id} ORDER BY s.name`).map((r) => r.name);

    const rows = await sql`
      SELECT e.id, e.full_name, e.job_role, e.city, e.expertise, COALESCE(e.projects, '{}') AS projects,
             COALESCE((SELECT array_agg(s.name ORDER BY s.name) FROM employee_skills es
                       JOIN skills s ON s.id = es.skill_id WHERE es.employee_id = e.id), '{}') AS skills,
             COALESCE((SELECT array_agg(to_char(a.starts_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') ORDER BY a.starts_at)
                       FROM availability_slots a
                       WHERE a.employee_id = e.id
                         AND a.starts_at > now()
                         AND a.starts_at < now() + make_interval(days => ${WINDOW_DAYS})), '{}') AS slots
      FROM employees e
      WHERE e.expertise IS NOT NULL`;

    const exp = await experienceFor(rows, pt, match.qv);
    const now = new Date();
    const experts = rows
      .map((r, i) => {
        const matched = needed.filter((s) => r.skills.includes(s));
        const { experience, evidence } = exp[i];
        const skillScore = needed.length ? matched.length / needed.length : 0;
        const score = WEIGHTS.skills * skillScore + WEIGHTS.experience * experience + WEIGHTS.availability * availabilityScore(r.slots, now);
        return {
          relevant: skillScore > 0 || experience >= EXPERIENCE_MIN,
          score,
          expertId: r.id,
          matchPercent: Math.round(score * 100),
          name: r.full_name,
          role: r.job_role,
          city: r.city,
          expertise: r.expertise,
          projects: r.projects,
          skillTags: matched.concat(r.skills.filter((s) => !matched.includes(s))),
          reason: reasonFor(matched, needed, experience, evidence, r.slots),
          slots: r.slots.slice(0, 2),
        };
      })
      .filter((x) => x.relevant)
      .sort((a, b) => b.score - a.score || a.name.localeCompare(b.name))
      .slice(0, MAX_EXPERTS)
      .map(({ relevant, score, ...x }, i) => ({ rank: i + 1, ...x }));

    const state = !experts.length ? "no_match"
      : experts.slice(0, 3).some((x) => x.slots.length) ? "available" : "no_availability";

    res.status(200).json({
      ...base,
      problemType: { id: pt.id, slug: pt.slug, name: pt.name, fileUrl: pt.file_url, fileName: pt.file_name, skills: needed },
      state,
      experts,
    });
  } catch (err) {
    res.status(500).json({ error: "Matching failed" });
  }
}
