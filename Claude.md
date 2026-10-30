# Compass

Internal knowledge matching platform (group project, Agile Digital Product
Development, IE Business School). An employee describes a problem, the system
checks the knowledge base first, then suggests the 3 best-matched colleagues.
See README.md for the concept and MVP scope.

## How the project is built

- Front end: static HTML pages in `pages/`, entry page `index.html`. Some pages
  are `.dc.html` design-canvas files. Images are in `images/`, `assets/`.
- Back end: serverless functions in `api/` (Vercel). Each file is one endpoint,
  e.g. `api/employees.js` is served at `/api/employees`.
- Database: Neon Postgres (project `compass-DB`, Frankfurt), connected to Vercel.
  Table definitions are in `db/schema.sql`.
- Hosting: Vercel, live at https://compass-seven-tau.vercel.app

## Data flow

Browser page -> fetch("/api/...") -> function in `api/` -> Neon.
Pages must never talk to the database directly. Only functions in `api/` read
`process.env.DATABASE_URL`.

## Rules

1. Never commit secrets. `DATABASE_URL` lives in Vercel environment variables.
   `.env*` files are in `.gitignore`. Never print or paste connection strings.
2. Never push directly to `main`. `main` is production and every push redeploys
   the live site. Work on a branch (e.g. `feature/profile-page`), push it, open
   a pull request. Vercel builds a preview for every branch.
3. Use synthetic data only. This is a prototype with no login on its API.
   Real employee, student or applicant data needs authentication and approval
   under IE's data governance policy (GDPR) first.
4. Keep API functions small: use the `@neondatabase/serverless` driver, tagged
   template queries (no string concatenation of user input), return JSON, and
   return a generic error message on failure.
5. Front end pages should keep working if an API call fails (show a fallback).
6. Keep the design consistent with the Compass brand: Poppins for headings,
   Open Sans for body text, blue-to-purple gradient (#2974cd to #6d2cbf),
   WCAG 2.1 AA accessibility (real buttons and links, labels on inputs,
   visible focus states, sufficient contrast).

## Running and testing

- Test changes on the Vercel preview of your branch, e.g. open the preview URL
  and add `/api/employees` to check an endpoint.
- Running locally needs `vercel link` and `vercel env pull .env.local` (needs
  access to the Vercel team). Never commit `.env.local`.
- Adding or changing tables: update `db/schema.sql` and run the SQL in the Neon
  SQL Editor. Say so in the pull request.

## Current endpoints

- `GET /api/employees` returns id, full_name, job_role, city, expertise.
