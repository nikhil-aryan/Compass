-- Compass database schema (Neon Postgres)
-- Structure only, no data. Run in the Neon SQL Editor to create the tables.

CREATE TABLE IF NOT EXISTS employees (
  id          SERIAL PRIMARY KEY,
  full_name   TEXT NOT NULL,
  job_role    TEXT,
  city        TEXT,
  email       TEXT UNIQUE,
  expertise   TEXT,
  weekly_help_budget_hours INT DEFAULT 2
);

CREATE TABLE IF NOT EXISTS skills (
  id   SERIAL PRIMARY KEY,
  name TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS employee_skills (
  employee_id INT REFERENCES employees(id) ON DELETE CASCADE,
  skill_id    INT REFERENCES skills(id) ON DELETE CASCADE,
  PRIMARY KEY (employee_id, skill_id)
);

CREATE TABLE IF NOT EXISTS availability_slots (
  id          SERIAL PRIMARY KEY,
  employee_id INT REFERENCES employees(id) ON DELETE CASCADE,
  starts_at   TIMESTAMPTZ NOT NULL
);
