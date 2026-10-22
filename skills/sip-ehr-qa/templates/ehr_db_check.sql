-- QA EHR DB check (local only). Run after the QA EHR Bruno run.
SELECT '1. QA messages (last 3 hours)' AS section;
SELECT m.id, f.code AS feed, m.source_event_type AS type, m.status, m.error_code, m.last_stage, m.attempts_count AS tries, m.origin, LEFT(m.source_message_id,40) AS event_id
FROM integration_ehr_messages m JOIN integration_ehr_feeds f ON f.id = m.feed_id
WHERE m.received_at > NOW() - INTERVAL 3 HOUR ORDER BY m.id;
SELECT '2. Stuck messages (received/processing for over 5 min) - should be 0 rows' AS section;
SELECT id, status, attempts_count, received_at, claimed_at FROM integration_ehr_messages
WHERE status IN ('received','processing') AND received_at < NOW() - INTERVAL 5 MINUTE;
SELECT '3. QA patients in integration table (check F17 / H08: phone + email wiped?)' AS section;
SELECT id, mrn, resource_id, first_name, last_name, dob, sex, phone, email, updated_at FROM integration_ehr_patients
WHERE mrn LIKE 'QA%' OR resource_id LIKE 'QA%' ORDER BY id;
SELECT '4. QA cases (check H12-H18, H21, H22)' AS section;
SELECT c.id, p.mrn, c.source_id, c.status, c.case_type_key, c.case_date, c.starts_at, c.provider_name, c.location_name
FROM integration_ehr_cases c JOIN integration_ehr_patients p ON p.id = c.patient_id WHERE p.mrn LIKE 'QA%' ORDER BY c.id;
SELECT '5. EHR events published in last 3 hours (look for extra PatientUpdated / CaseUpdated / CaseCancelled)' AS section;
SELECT event_type, COUNT(*) AS total FROM event_store_events
WHERE event_type LIKE 'Integration::Ehr%' AND created_at > NOW() - INTERVAL 3 HOUR GROUP BY event_type ORDER BY event_type;
SELECT '6. SIP care patients created from QA EHR messages (SIP-217)' AS section;
SELECT id, first_name, last_name, mrn, email, created_at FROM users WHERE mrn LIKE 'QA%' ORDER BY id;
SELECT '7. Setup check: latest migration (expect 20261014090000 or later) + external_id column + globus surgeon' AS section;
SELECT MAX(version) AS latest_migration FROM schema_migrations;
SELECT COUNT(*) AS external_id_column FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'patient_cases' AND column_name = 'external_id';
SELECT id, email FROM users WHERE email IN ('globus.physician@higgs.care','jay.chen@higgs.care');
SELECT '8. Care import jobs that failed (SIP-217)' AS section;
SELECT j.class_name, LEFT(f.error, 200) AS error, f.created_at FROM sip_dev_queue.solid_queue_failed_executions f JOIN sip_dev_queue.solid_queue_jobs j ON j.id = f.job_id ORDER BY f.id DESC LIMIT 15;
