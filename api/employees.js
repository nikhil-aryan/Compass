import { neon } from "@neondatabase/serverless";

export default async function handler(req, res) {
  try {
    const sql = neon(process.env.DATABASE_URL);
    const rows = await sql`
      SELECT id, full_name, job_role, city, expertise
      FROM employees
      ORDER BY full_name`;
    res.status(200).json(rows);
  } catch (err) {
    res.status(500).json({ error: "Database error" });
  }
}
