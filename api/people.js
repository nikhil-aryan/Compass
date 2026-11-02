import { neon } from "@neondatabase/serverless";

// GET /api/people  (COM-55 People directory)
// All demo employees with profile data, their projects and skills.
// Rows without expertise or projects (old placeholders) are left out.
export default async function handler(req, res) {
  try {
    const sql = neon(process.env.DATABASE_URL);
    const rows = await sql`
      SELECT e.id, e.full_name, e.job_role, e.city, e.email, e.expertise,
             COALESCE(e.projects, '{}') AS projects,
             COALESCE(array_agg(s.name ORDER BY s.name) FILTER (WHERE s.name IS NOT NULL), '{}') AS skills
      FROM employees e
      LEFT JOIN employee_skills es ON es.employee_id = e.id
      LEFT JOIN skills s ON s.id = es.skill_id
      WHERE e.expertise IS NOT NULL AND e.projects IS NOT NULL
      GROUP BY e.id
      ORDER BY e.full_name`;
    res.status(200).json(rows);
  } catch (err) {
    res.status(500).json({ error: "Database error" });
  }
}
