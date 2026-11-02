# Result data contract (COM-31)

**Status:** proposal by Anton, needs OK from Kat (COM-19 matching), Nikhil (COM-21 slots) and Matteo (COM-24 result states).

This is the JSON that the matching endpoint returns and that the result card (COM-20) and the result states (COM-24) read. Full example: `data/mock-results.json`.

## Shape

| Field | Type | Who fills it | Shown on card |
|---|---|---|---|
| `query` | string | search box | page title "Results for ..." |
| `problemType.id`, `slug`, `name` | number, string, string | matching (COM-19) via catalogue (COM-17) | - |
| `problemType.fileUrl`, `fileName` | string or null | catalogue / documents (COM-32, COM-33) | linked document |
| `state` | `"available"` \| `"no_availability"` \| `"no_match"` | result state logic (COM-24) | which UI state |
| `experts[]` | array, max 3, sorted by rank | matching (COM-19) | one card each |
| `experts[].expertId` | number | DB `employees.id` | link to profile |
| `experts[].rank` | 1-3 | matching | "#1" badge |
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
