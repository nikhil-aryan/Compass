# Result data contract (COM-31)

**Status:** proposal by Anton, needs OK from Kat (COM-19 matching), Nikhil (COM-21 slots) and Matteo (COM-24 result states).

This is the JSON that the matching endpoint returns and that the result card (COM-20) and the result states (COM-24) read. Full example: `data/mock-results.json`.

## Shape

| Field | Type | Who fills it | Shown on card |
|---|---|---|---|
| `query` | string | search box | page title "Results for ..." |
| `problemType.id`, `slug`, `name` | number, string, string | matching (COM-19) via catalogue (COM-17) | - |
| `problemType.fileUrl`, `fileName` | string or null | catalogue / documents (COM-32, COM-33) | linked document |
| `problemType.skills` | string[] | DB `problem_type_skills` | - (used for the reason text) |
| `classification.method`, `score` | `"embedding"` \| `"keyword"`, number | matching (COM-19) | - (debugging only) |
| `state` | `"available"` \| `"no_availability"` \| `"no_match"` | result state logic (COM-24) | which UI state |
| `experts[]` | array, max 20, sorted by rank | matching (COM-19) | top 3 as cards, the rest under "See more" |
| `experts[].expertId` | number | DB `employees.id` | link to profile |
| `experts[].rank` | 1-20 | matching | "#1" badge |
| `experts[].matchPercent` | 0-100 | matching | "92% match" |
| `experts[].name`, `role`, `city` | string | DB `employees` | header |
| `experts[].expertise` | string | DB `employees.expertise` | "Expertise" text |
| `experts[].projects` | string[] | DB `employees.projects` | project chips |
| `experts[].skillTags` | string[] (max 3 shown) | DB `employee_skills` | skill chips |
| `experts[].reason` | string, one line | matching (COM-19) | "Why this person" |
| `experts[].slots` | ISO datetime[] (next 2, can be empty) | availability (COM-21) | slots + Request button (COM-47) |

## Decisions in this proposal

1. **The document belongs to the problem type, not to the expert.** It is sent once (`problemType.fileUrl`), not on every card. This matches COM-33 ("add fileUrl to each problem type").
2. **`slots` can be empty.** Experts without a slot stay in the list (story 6: "show available from <date>, don't hide them").
3. **`team` is dropped** from the original COM-31 field list. The Claude Design results screen shows city, not team, and the DB has no team column.
4. If `fileUrl` is null, the card shows "No document for this problem yet" (COM-37 fallback).
5. **More than 3 experts** are returned (up to 20). The page shows the top 3 and puts the rest behind "See more".

## How matching ranks people (`api/match.js`)

1. **Problem type.** A small open embedding model (all-MiniLM-L6-v2) runs inside the function and compares the query with each type's name, description and keywords. If it can't load, keyword matching is used instead. Below a similarity of 0.35 the result is `no_match`.
2. **Skills needed** come from `problem_type_skills`.
3. **Score** (0-1, shown as `matchPercent`):
   - 50% skills: share of the needed skills the person has (`employee_skills`)
   - 30% experience: how close the person's expertise or one of their projects is to the query (same embedding model). The closest project is named in the reason.
   - 20% availability: a free slot within 3 days scores full, fading to 0 at 14 days. `availability_slots` has no end time, so each slot counts as a free 2-hour block until calendar sync exists.
4. People with neither a needed skill nor experience are left out.

This uses the existing schema only (no new tables or columns). Skills come from `employee_skills`. `scripts/tag-profiles.js` can suggest skills for new profiles with a local LLM (Ollama) and writes them to that same table.
