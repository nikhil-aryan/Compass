-- Compass seed data (synthetic only, see CLAUDE.md rule 3).
-- Jira: COM-39 (profiles and skills). Problem types are a DRAFT for COM-17 (Mateo to confirm).
-- Safe to run more than once: rows are matched by email / name and skipped if they exist.
-- Existing test rows (ids 1-6) are not touched.
-- Run AFTER the schema changes in db/schema.sql.

-- 1. Skills
INSERT INTO skills (name) VALUES
  ('agile-scrum'),
  ('change-management'),
  ('cloud-aws'),
  ('data-engineering'),
  ('data-visualisation'),
  ('devops'),
  ('excel'),
  ('financial-modelling'),
  ('gdpr'),
  ('jira'),
  ('legal-compliance'),
  ('power-bi'),
  ('pricing'),
  ('sql'),
  ('workshop-facilitation')
ON CONFLICT (name) DO NOTHING;

-- 2. Employees (15 synthetic profiles)
INSERT INTO employees (full_name, job_role, city, email, expertise, projects) VALUES
  ('Lena Hartmann', 'Senior Consultant, Pricing', 'Munich', 'lena.hartmann@compass-demo.test', 'Builds pricing models for fixed-fee and outcome-based proposals. Known for turning messy scope into a defensible price.', ARRAY['Telco pricing review','Insurance bid 2026']),
  ('Diego Navarro', 'Manager, Corporate Finance', 'Madrid', 'diego.navarro@compass-demo.test', 'Leads business-case and forecasting work for CFO clients. Reviews models for logic errors before they reach the client.', ARRAY['Retail business case','Energy forecast model']),
  ('Priya Raman', 'Data Engineer', 'London', 'priya.raman@compass-demo.test', 'Designs and fixes ETL pipelines on Postgres and Snowflake. Good at finding why a query is slow.', ARRAY['Bank data warehouse','Churn data lake']),
  ('Tomasz Kowalski', 'Senior Data Engineer', 'Warsaw', 'tomasz.kowalski@compass-demo.test', 'Owns data quality checks and pipeline monitoring for analytics teams. Writes most of the internal SQL style guide.', ARRAY['Logistics reporting','Pharma data platform']),
  ('Aisha Okafor', 'Cloud Architect', 'Berlin', 'aisha.okafor@compass-demo.test', 'Sets up AWS landing zones and CI/CD pipelines. Helps teams debug failed deployments.', ARRAY['Public sector cloud move','SaaS migration']),
  ('Marco Bellini', 'DevOps Engineer', 'Milan', 'marco.bellini@compass-demo.test', 'Automates builds, tests and releases with GitHub Actions and Terraform.', ARRAY['Mobile app pipeline','Infra as code rollout']),
  ('Sofia Lindqvist', 'Manager, Change & People', 'Stockholm', 'sofia.lindqvist@compass-demo.test', 'Designs and runs client workshops for transformation programmes. Strong on stakeholder alignment.', ARRAY['ERP change programme','Operating model redesign']),
  ('Julien Moreau', 'Senior Consultant, Strategy', 'Paris', 'julien.moreau@compass-demo.test', 'Facilitates strategy and design-thinking workshops with executive teams.', ARRAY['Growth strategy offsite','Customer journey sprint']),
  ('Clara Becker', 'Data Protection Lead', 'Hamburg', 'clara.becker@compass-demo.test', 'Advises project teams on GDPR, DPAs and retention rules. First call for anything involving personal data.', ARRAY['HR analytics DPIA','Customer data audit']),
  ('Rui Fernandes', 'Legal & Compliance Consultant', 'Lisbon', 'rui.fernandes@compass-demo.test', 'Reviews contracts and data processing setups for compliance risks.', ARRAY['Vendor contract review','Cookie consent rollout']),
  ('Hannah Schulz', 'BI Consultant', 'Cologne', 'hannah.schulz@compass-demo.test', 'Builds Power BI dashboards and KPI frameworks for management reporting.', ARRAY['Sales KPI dashboard','Ops control tower']),
  ('Kenji Watanabe', 'Data Visualisation Specialist', 'Amsterdam', 'kenji.watanabe@compass-demo.test', 'Turns complex datasets into clear charts and dashboards. Runs internal dataviz trainings.', ARRAY['Board reporting pack','Supply chain dashboard']),
  ('Elena Popescu', 'Agile Coach', 'Bucharest', 'elena.popescu@compass-demo.test', 'Coaches teams on Scrum and Kanban and sets up Jira boards that people actually use.', ARRAY['Bank agile transformation','Product team launch']),
  ('Oliver Grant', 'Scrum Master', 'Dublin', 'oliver.grant@compass-demo.test', 'Runs sprint ceremonies and backlog refinement for two delivery teams. Jira admin for the practice.', ARRAY['Insurance portal delivery','Internal tools squad']),
  ('Nadia Haddad', 'Analyst, Finance & Data', 'Madrid', 'nadia.haddad@compass-demo.test', 'Junior analyst who supports models and reporting. Fast with Excel and SQL.', ARRAY['Retail business case','Sales KPI dashboard'])
ON CONFLICT (email) DO NOTHING;

-- 3. Employee skills
INSERT INTO employee_skills (employee_id, skill_id)
SELECT e.id, s.id
FROM (VALUES
  ('lena.hartmann@compass-demo.test', 'pricing'),
  ('lena.hartmann@compass-demo.test', 'financial-modelling'),
  ('lena.hartmann@compass-demo.test', 'excel'),
  ('diego.navarro@compass-demo.test', 'financial-modelling'),
  ('diego.navarro@compass-demo.test', 'excel'),
  ('diego.navarro@compass-demo.test', 'pricing'),
  ('priya.raman@compass-demo.test', 'sql'),
  ('priya.raman@compass-demo.test', 'data-engineering'),
  ('priya.raman@compass-demo.test', 'cloud-aws'),
  ('tomasz.kowalski@compass-demo.test', 'sql'),
  ('tomasz.kowalski@compass-demo.test', 'data-engineering'),
  ('tomasz.kowalski@compass-demo.test', 'power-bi'),
  ('aisha.okafor@compass-demo.test', 'cloud-aws'),
  ('aisha.okafor@compass-demo.test', 'devops'),
  ('aisha.okafor@compass-demo.test', 'gdpr'),
  ('marco.bellini@compass-demo.test', 'devops'),
  ('marco.bellini@compass-demo.test', 'cloud-aws'),
  ('marco.bellini@compass-demo.test', 'agile-scrum'),
  ('sofia.lindqvist@compass-demo.test', 'workshop-facilitation'),
  ('sofia.lindqvist@compass-demo.test', 'change-management'),
  ('sofia.lindqvist@compass-demo.test', 'agile-scrum'),
  ('julien.moreau@compass-demo.test', 'workshop-facilitation'),
  ('julien.moreau@compass-demo.test', 'change-management'),
  ('julien.moreau@compass-demo.test', 'pricing'),
  ('clara.becker@compass-demo.test', 'gdpr'),
  ('clara.becker@compass-demo.test', 'legal-compliance'),
  ('clara.becker@compass-demo.test', 'change-management'),
  ('rui.fernandes@compass-demo.test', 'legal-compliance'),
  ('rui.fernandes@compass-demo.test', 'gdpr'),
  ('rui.fernandes@compass-demo.test', 'excel'),
  ('hannah.schulz@compass-demo.test', 'power-bi'),
  ('hannah.schulz@compass-demo.test', 'data-visualisation'),
  ('hannah.schulz@compass-demo.test', 'sql'),
  ('kenji.watanabe@compass-demo.test', 'data-visualisation'),
  ('kenji.watanabe@compass-demo.test', 'power-bi'),
  ('kenji.watanabe@compass-demo.test', 'excel'),
  ('elena.popescu@compass-demo.test', 'agile-scrum'),
  ('elena.popescu@compass-demo.test', 'jira'),
  ('elena.popescu@compass-demo.test', 'workshop-facilitation'),
  ('oliver.grant@compass-demo.test', 'jira'),
  ('oliver.grant@compass-demo.test', 'agile-scrum'),
  ('oliver.grant@compass-demo.test', 'devops'),
  ('nadia.haddad@compass-demo.test', 'excel'),
  ('nadia.haddad@compass-demo.test', 'sql'),
  ('nadia.haddad@compass-demo.test', 'data-visualisation')
) AS v(email, skill)
JOIN employees e ON e.email = v.email
JOIN skills s ON s.name = v.skill
ON CONFLICT DO NOTHING;

-- 4. Availability slots (fake, no calendar sync). 2 people only have late slots -> 'no availability' state.
INSERT INTO availability_slots (employee_id, starts_at)
SELECT e.id, v.starts_at
FROM (VALUES
  ('lena.hartmann@compass-demo.test', '2026-11-03T09:00:00+01:00'::timestamptz),
  ('lena.hartmann@compass-demo.test', '2026-11-04T16:00:00+01:00'::timestamptz),
  ('diego.navarro@compass-demo.test', '2026-11-03T15:00:00+01:00'::timestamptz),
  ('diego.navarro@compass-demo.test', '2026-11-05T11:00:00+01:00'::timestamptz),
  ('priya.raman@compass-demo.test', '2026-11-04T10:00:00+01:00'::timestamptz),
  ('priya.raman@compass-demo.test', '2026-11-05T14:00:00+01:00'::timestamptz),
  ('tomasz.kowalski@compass-demo.test', '2026-11-23T10:00:00+01:00'::timestamptz),
  ('tomasz.kowalski@compass-demo.test', '2026-11-24T14:00:00+01:00'::timestamptz),
  ('aisha.okafor@compass-demo.test', '2026-11-03T09:00:00+01:00'::timestamptz),
  ('aisha.okafor@compass-demo.test', '2026-11-06T09:30:00+01:00'::timestamptz),
  ('marco.bellini@compass-demo.test', '2026-11-04T16:00:00+01:00'::timestamptz),
  ('marco.bellini@compass-demo.test', '2026-11-06T13:00:00+01:00'::timestamptz),
  ('sofia.lindqvist@compass-demo.test', '2026-11-03T15:00:00+01:00'::timestamptz),
  ('sofia.lindqvist@compass-demo.test', '2026-11-04T10:00:00+01:00'::timestamptz),
  ('julien.moreau@compass-demo.test', '2026-11-23T10:00:00+01:00'::timestamptz),
  ('julien.moreau@compass-demo.test', '2026-11-24T14:00:00+01:00'::timestamptz),
  ('clara.becker@compass-demo.test', '2026-11-05T11:00:00+01:00'::timestamptz),
  ('clara.becker@compass-demo.test', '2026-11-06T09:30:00+01:00'::timestamptz),
  ('rui.fernandes@compass-demo.test', '2026-11-05T14:00:00+01:00'::timestamptz),
  ('rui.fernandes@compass-demo.test', '2026-11-06T13:00:00+01:00'::timestamptz),
  ('hannah.schulz@compass-demo.test', '2026-11-03T09:00:00+01:00'::timestamptz),
  ('hannah.schulz@compass-demo.test', '2026-11-04T10:00:00+01:00'::timestamptz),
  ('kenji.watanabe@compass-demo.test', '2026-11-04T16:00:00+01:00'::timestamptz),
  ('kenji.watanabe@compass-demo.test', '2026-11-05T14:00:00+01:00'::timestamptz),
  ('elena.popescu@compass-demo.test', '2026-11-03T15:00:00+01:00'::timestamptz),
  ('elena.popescu@compass-demo.test', '2026-11-06T09:30:00+01:00'::timestamptz),
  ('oliver.grant@compass-demo.test', '2026-11-05T11:00:00+01:00'::timestamptz),
  ('oliver.grant@compass-demo.test', '2026-11-06T13:00:00+01:00'::timestamptz),
  ('nadia.haddad@compass-demo.test', '2026-11-04T10:00:00+01:00'::timestamptz),
  ('nadia.haddad@compass-demo.test', '2026-11-06T09:30:00+01:00'::timestamptz)
) AS v(email, starts_at)
JOIN employees e ON e.email = v.email
WHERE NOT EXISTS (
  SELECT 1 FROM availability_slots a WHERE a.employee_id = e.id AND a.starts_at = v.starts_at
);

-- 5. Problem types (DRAFT for COM-17) and their documents (COM-32 / COM-33)
INSERT INTO problem_types (slug, name, description, file_url, file_name) VALUES
  ('pricing-proposal', 'Pricing a client proposal', 'How to price a fixed-fee or T&M proposal', '/docs/pricing-proposal.html', 'Pricing a client proposal - checklist'),
  ('financial-model', 'Building or fixing a financial model', 'Excel models, business cases, forecasts', '/docs/financial-model.html', 'Building or fixing a financial model - checklist'),
  ('sql-data-pipeline', 'SQL query or data pipeline problem', 'Slow queries, broken ETL jobs, data quality', '/docs/sql-data-pipeline.html', 'SQL query or data pipeline problem - checklist'),
  ('cloud-deployment', 'Cloud deployment or infrastructure issue', 'Deploying to AWS/Azure, CI/CD failures', '/docs/cloud-deployment.html', 'Cloud deployment or infrastructure issue - checklist'),
  ('workshop-facilitation', 'Running a client workshop', 'Planning and facilitating workshops with clients', '/docs/workshop-facilitation.html', 'Running a client workshop - checklist'),
  ('gdpr-privacy', 'GDPR or data privacy question', 'Consent, data minimisation, DPAs, retention', '/docs/gdpr-privacy.html', 'GDPR or data privacy question - checklist'),
  ('dashboard-reporting', 'Dashboard or BI reporting', 'Power BI dashboards, KPIs, data visualisation', '/docs/dashboard-reporting.html', 'Dashboard or BI reporting - checklist'),
  ('agile-delivery', 'Agile delivery or Jira setup', 'Scrum ceremonies, backlog structure, Jira boards', '/docs/agile-delivery.html', 'Agile delivery or Jira setup - checklist')
ON CONFLICT (slug) DO NOTHING;

INSERT INTO problem_type_skills (problem_type_id, skill_id)
SELECT p.id, s.id
FROM (VALUES
  ('pricing-proposal', 'pricing'),
  ('pricing-proposal', 'financial-modelling'),
  ('financial-model', 'financial-modelling'),
  ('financial-model', 'excel'),
  ('sql-data-pipeline', 'sql'),
  ('sql-data-pipeline', 'data-engineering'),
  ('cloud-deployment', 'cloud-aws'),
  ('cloud-deployment', 'devops'),
  ('workshop-facilitation', 'workshop-facilitation'),
  ('workshop-facilitation', 'change-management'),
  ('gdpr-privacy', 'gdpr'),
  ('gdpr-privacy', 'legal-compliance'),
  ('dashboard-reporting', 'power-bi'),
  ('dashboard-reporting', 'data-visualisation'),
  ('agile-delivery', 'agile-scrum'),
  ('agile-delivery', 'jira')
) AS v(slug, skill)
JOIN problem_types p ON p.slug = v.slug
JOIN skills s ON s.name = v.skill
ON CONFLICT DO NOTHING;

-- 6. Coverage check: every problem type should have >= 2 experts, >= 2 of them with a slot this week.
SELECT p.name,
       COUNT(DISTINCT es.employee_id) AS experts,
       COUNT(DISTINCT es.employee_id) FILTER (WHERE a.starts_at < '2026-11-09') AS available_this_week
FROM problem_types p
JOIN problem_type_skills pts ON pts.problem_type_id = p.id
JOIN employee_skills es ON es.skill_id = pts.skill_id
LEFT JOIN availability_slots a ON a.employee_id = es.employee_id
GROUP BY p.name
ORDER BY experts;
