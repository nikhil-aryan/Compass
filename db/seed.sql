-- Compass seed data (synthetic only, see CLAUDE.md rule 3).
-- Jira: COM-39 (profiles and skills), COM-17 (problem-type catalogue, final by Mateo 31 Oct 2026), COM-33 (documents).
-- Safe to run more than once. Brings the DB to exactly this state:
--   * people/skills/slots are added if missing (matched by email), existing rows are not changed
--   * problem types are upserted by slug; the 2 types Mateo dropped are removed
--   * problem_type_skills is synced to the catalogue below
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

-- 2. Employees (21 synthetic profiles; last 6 added for the cross-functional problem types)
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
  ('Nadia Haddad', 'Analyst, Finance & Data', 'Madrid', 'nadia.haddad@compass-demo.test', 'Junior analyst who supports models and reporting. Fast with Excel and SQL.', ARRAY['Retail business case','Sales KPI dashboard']),
  ('Sebastian Vogel', 'Data Strategy Manager', 'Frankfurt', 'sebastian.vogel@compass-demo.test', 'Builds business cases and TCO models for data platform moves. Bridges finance and engineering teams.', ARRAY['Core banking data migration','Cloud TCO assessment']),
  ('Ines Carvalho', 'Senior Data Consultant, Value', 'Porto', 'ines.carvalho@compass-demo.test', 'Sizes the cost and payback of data projects and checks the numbers against what engineers actually build.', ARRAY['Data platform business case','Retail data lake migration']),
  ('Maya Cohen', 'Value Realisation Lead', 'Vienna', 'maya.cohen@compass-demo.test', 'Tracks the benefits of transformation programmes and turns them into clear before/after charts for steering committees.', ARRAY['ERP benefits tracking','Transformation ROI dashboard']),
  ('Lukas Brandt', 'Transformation Finance Manager', 'Zurich', 'lukas.brandt@compass-demo.test', 'Plans cost-reduction programmes and runs the workshops that get teams to agree on where to save.', ARRAY['Cost reduction programme','Shared services redesign']),
  ('Amara Nwosu', 'Post-Merger Integration Consultant', 'Brussels', 'amara.nwosu@compass-demo.test', 'Leads data and people integration after acquisitions, from CRM consolidation to aligning both teams.', ARRAY['Insurance merger CRM consolidation','Bank carve-out data split']),
  ('Pavel Novak', 'Incident Response Lead', 'Prague', 'pavel.novak@compass-demo.test', 'Coordinates the response to data breaches: root cause, notification duties and clean-up.', ARRAY['Retail data breach response','Incident playbook rollout'])
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
  ('nadia.haddad@compass-demo.test', 'data-visualisation'),
  ('sebastian.vogel@compass-demo.test', 'financial-modelling'),
  ('sebastian.vogel@compass-demo.test', 'data-engineering'),
  ('sebastian.vogel@compass-demo.test', 'cloud-aws'),
  ('ines.carvalho@compass-demo.test', 'data-engineering'),
  ('ines.carvalho@compass-demo.test', 'financial-modelling'),
  ('ines.carvalho@compass-demo.test', 'sql'),
  ('maya.cohen@compass-demo.test', 'financial-modelling'),
  ('maya.cohen@compass-demo.test', 'data-visualisation'),
  ('maya.cohen@compass-demo.test', 'change-management'),
  ('lukas.brandt@compass-demo.test', 'financial-modelling'),
  ('lukas.brandt@compass-demo.test', 'change-management'),
  ('lukas.brandt@compass-demo.test', 'workshop-facilitation'),
  ('amara.nwosu@compass-demo.test', 'data-engineering'),
  ('amara.nwosu@compass-demo.test', 'gdpr'),
  ('amara.nwosu@compass-demo.test', 'change-management'),
  ('pavel.novak@compass-demo.test', 'data-engineering'),
  ('pavel.novak@compass-demo.test', 'legal-compliance'),
  ('pavel.novak@compass-demo.test', 'gdpr')
) AS v(email, skill)
JOIN employees e ON e.email = v.email
JOIN skills s ON s.name = v.skill
ON CONFLICT DO NOTHING;

-- 4. Availability slots (fake, no calendar sync). Tomasz and Julien only have late slots -> 'no availability' state.
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
  ('nadia.haddad@compass-demo.test', '2026-11-06T09:30:00+01:00'::timestamptz),
  ('sebastian.vogel@compass-demo.test', '2026-11-04T10:00:00+01:00'::timestamptz),
  ('sebastian.vogel@compass-demo.test', '2026-11-06T09:30:00+01:00'::timestamptz),
  ('ines.carvalho@compass-demo.test', '2026-11-03T15:00:00+01:00'::timestamptz),
  ('ines.carvalho@compass-demo.test', '2026-11-05T14:00:00+01:00'::timestamptz),
  ('maya.cohen@compass-demo.test', '2026-11-03T09:00:00+01:00'::timestamptz),
  ('maya.cohen@compass-demo.test', '2026-11-05T11:00:00+01:00'::timestamptz),
  ('lukas.brandt@compass-demo.test', '2026-11-04T16:00:00+01:00'::timestamptz),
  ('lukas.brandt@compass-demo.test', '2026-11-06T13:00:00+01:00'::timestamptz),
  ('amara.nwosu@compass-demo.test', '2026-11-04T10:00:00+01:00'::timestamptz),
  ('amara.nwosu@compass-demo.test', '2026-11-05T14:00:00+01:00'::timestamptz),
  ('pavel.novak@compass-demo.test', '2026-11-03T15:00:00+01:00'::timestamptz),
  ('pavel.novak@compass-demo.test', '2026-11-06T09:30:00+01:00'::timestamptz)
) AS v(email, starts_at)
JOIN employees e ON e.email = v.email
WHERE NOT EXISTS (
  SELECT 1 FROM availability_slots a WHERE a.employee_id = e.id AND a.starts_at = v.starts_at
);

-- 5. Problem types removed from the final catalogue (COM-17)
DELETE FROM problem_types WHERE slug IN ('workshop-facilitation', 'gdpr-privacy');

-- 6. Problem types (final catalogue by Mateo, COM-17) with search keywords and document link
INSERT INTO problem_types (slug, name, description, keywords, file_url, file_name) VALUES
  ('migration-cost', 'Estimating the cost of a data platform migration', 'How much it costs to move a client''s data to a new platform and when the investment pays back', ARRAY['migration cost','migration budget','data platform migration','payback period','migration business case','tco'], '/docs/migration-cost.html', 'Estimating the cost of a data platform migration - checklist'),
  ('transformation-roi', 'Showing a client the ROI of a transformation project', 'How to prove with numbers and clear charts that a change project was worth it', ARRAY['roi','return on investment','value realisation','benefits tracking','project impact','business case review'], '/docs/transformation-roi.html', 'Showing a client the ROI of a transformation project - checklist'),
  ('merger-customer-data', 'Combining customer data after a merger', 'How to merge two companies'' customer databases legally and without the teams clashing', ARRAY['merger','acquisition','m&a','post-merger integration','crm consolidation','data integration','duplicate customers'], '/docs/merger-customer-data.html', 'Combining customer data after a merger - checklist'),
  ('budget-cut', 'Planning a budget cut without losing the team', 'How to decide where to cut costs and communicate it so people stay on board', ARRAY['budget cut','cost reduction','savings plan','restructuring','team morale','change communication'], '/docs/budget-cut.html', 'Planning a budget cut without losing the team - checklist'),
  ('data-leak', 'Handling a client data leak', 'What to do when client data is exposed: find the cause, meet legal duties and estimate the cost', ARRAY['data leak','data breach','security incident','incident response','breach notification','exposed data'], '/docs/data-leak.html', 'Handling a client data leak - checklist'),
  ('pricing-proposal', 'Pricing a client proposal', 'How to price a fixed-fee or time-and-materials proposal', ARRAY['pricing','quote','fee','fixed fee','time and materials','rate card','proposal pricing'], '/docs/pricing-proposal.html', 'Pricing a client proposal - checklist'),
  ('financial-model', 'Building or fixing a financial model', 'How to build, check or repair a spreadsheet model for a client or internal case', ARRAY['financial model','excel','spreadsheet','forecast','cash flow model','projections','model review'], '/docs/financial-model.html', 'Building or fixing a financial model - checklist'),
  ('sql-data-pipeline', 'SQL query or data pipeline problem', 'When a query returns wrong results, runs slowly or a data pipeline breaks', ARRAY['sql','query','query optimisation','etl','pipeline failure','database error'], '/docs/sql-data-pipeline.html', 'SQL query or data pipeline problem - checklist'),
  ('cloud-deployment', 'Cloud deployment or infrastructure issue', 'When an app won''t deploy, a server fails or the cloud setup needs fixing', ARRAY['aws','cloud','deployment','infrastructure','ci/cd','server outage','cloud architecture'], '/docs/cloud-deployment.html', 'Cloud deployment or infrastructure issue - checklist'),
  ('dashboard-reporting', 'Dashboard or BI reporting', 'How to build or fix a dashboard or report so the data is clear and correct', ARRAY['dashboard','power bi','bi','reporting','kpi report','data visualisation'], '/docs/dashboard-reporting.html', 'Dashboard or BI reporting - checklist'),
  ('agile-delivery', 'Agile delivery or Jira setup', 'How to run sprints, organise a backlog or configure a Jira board', ARRAY['agile','scrum','sprint','sprint planning','backlog','jira','user stories'], '/docs/agile-delivery.html', 'Agile delivery or Jira setup - checklist')
ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name, description = EXCLUDED.description, keywords = EXCLUDED.keywords, file_url = EXCLUDED.file_url, file_name = EXCLUDED.file_name;

-- 7. Remove skill links that are no longer in the catalogue
DELETE FROM problem_type_skills pts USING problem_types p, skills s
WHERE pts.problem_type_id = p.id AND pts.skill_id = s.id
  AND (p.slug, s.name) NOT IN (VALUES
  ('migration-cost', 'financial-modelling'),
  ('migration-cost', 'data-engineering'),
  ('transformation-roi', 'financial-modelling'),
  ('transformation-roi', 'data-visualisation'),
  ('transformation-roi', 'change-management'),
  ('merger-customer-data', 'data-engineering'),
  ('merger-customer-data', 'gdpr'),
  ('merger-customer-data', 'change-management'),
  ('budget-cut', 'financial-modelling'),
  ('budget-cut', 'change-management'),
  ('budget-cut', 'workshop-facilitation'),
  ('data-leak', 'data-engineering'),
  ('data-leak', 'legal-compliance'),
  ('data-leak', 'financial-modelling'),
  ('pricing-proposal', 'pricing'),
  ('pricing-proposal', 'financial-modelling'),
  ('financial-model', 'financial-modelling'),
  ('financial-model', 'excel'),
  ('sql-data-pipeline', 'sql'),
  ('sql-data-pipeline', 'data-engineering'),
  ('cloud-deployment', 'cloud-aws'),
  ('cloud-deployment', 'devops'),
  ('dashboard-reporting', 'power-bi'),
  ('dashboard-reporting', 'data-visualisation'),
  ('agile-delivery', 'agile-scrum'),
  ('agile-delivery', 'jira')
);

-- 8. Skills per problem type
INSERT INTO problem_type_skills (problem_type_id, skill_id)
SELECT p.id, s.id
FROM (VALUES
  ('migration-cost', 'financial-modelling'),
  ('migration-cost', 'data-engineering'),
  ('transformation-roi', 'financial-modelling'),
  ('transformation-roi', 'data-visualisation'),
  ('transformation-roi', 'change-management'),
  ('merger-customer-data', 'data-engineering'),
  ('merger-customer-data', 'gdpr'),
  ('merger-customer-data', 'change-management'),
  ('budget-cut', 'financial-modelling'),
  ('budget-cut', 'change-management'),
  ('budget-cut', 'workshop-facilitation'),
  ('data-leak', 'data-engineering'),
  ('data-leak', 'legal-compliance'),
  ('data-leak', 'financial-modelling'),
  ('pricing-proposal', 'pricing'),
  ('pricing-proposal', 'financial-modelling'),
  ('financial-model', 'financial-modelling'),
  ('financial-model', 'excel'),
  ('sql-data-pipeline', 'sql'),
  ('sql-data-pipeline', 'data-engineering'),
  ('cloud-deployment', 'cloud-aws'),
  ('cloud-deployment', 'devops'),
  ('dashboard-reporting', 'power-bi'),
  ('dashboard-reporting', 'data-visualisation'),
  ('agile-delivery', 'agile-scrum'),
  ('agile-delivery', 'jira')
) AS v(slug, skill)
JOIN problem_types p ON p.slug = v.slug
JOIN skills s ON s.name = v.skill
ON CONFLICT DO NOTHING;

-- 9. Coverage check: every type should have >= 2 strong experts (>= 2 matching skills) free in the demo week.
SELECT p.name,
       COUNT(DISTINCT es.employee_id) AS experts,
       COUNT(DISTINCT es.employee_id) FILTER (WHERE x.n >= 2) AS strong_experts,
       COUNT(DISTINCT es.employee_id) FILTER (WHERE x.n >= 2 AND a.starts_at < '2026-11-09') AS strong_and_free
FROM problem_types p
JOIN problem_type_skills pts ON pts.problem_type_id = p.id
JOIN employee_skills es ON es.skill_id = pts.skill_id
JOIN LATERAL (SELECT COUNT(*) AS n FROM employee_skills e2 JOIN problem_type_skills p2 ON p2.skill_id = e2.skill_id AND p2.problem_type_id = p.id WHERE e2.employee_id = es.employee_id) x ON true
LEFT JOIN availability_slots a ON a.employee_id = es.employee_id
GROUP BY p.name
ORDER BY strong_and_free, experts;
