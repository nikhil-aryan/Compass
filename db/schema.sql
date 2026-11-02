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

-- ---------------------------------------------------------------
-- Added for COM-20 / COM-39 (Anton). Run in the Neon SQL Editor
-- BEFORE db/seed.sql. Safe to run more than once.
-- ---------------------------------------------------------------

-- Projects shown on the result card (design: "App - Search results")
ALTER TABLE employees ADD COLUMN IF NOT EXISTS projects TEXT[];

-- Problem-type catalogue (COM-17, final by Mateo 31 Oct 2026)
-- file_url / file_name = the document shown on the result card (COM-33)
CREATE TABLE IF NOT EXISTS problem_types (
  id          SERIAL PRIMARY KEY,
  slug        TEXT UNIQUE NOT NULL,
  name        TEXT NOT NULL,
  description TEXT,
  file_url    TEXT,
  file_name   TEXT
);

-- Search keywords per problem type (COM-17 / COM-29, used to map free text to a type)
ALTER TABLE problem_types ADD COLUMN IF NOT EXISTS keywords TEXT[];

-- Which skills solve which problem type (used by matching, COM-19)
CREATE TABLE IF NOT EXISTS problem_type_skills (
  problem_type_id INT REFERENCES problem_types(id) ON DELETE CASCADE,
  skill_id        INT REFERENCES skills(id) ON DELETE CASCADE,
  PRIMARY KEY (problem_type_id, skill_id)
);
