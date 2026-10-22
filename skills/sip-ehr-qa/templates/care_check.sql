-- QA SIP-216 / SIP-217 care import check (local only). Run after the 07 Care Import Bruno run.
SELECT '1. QA-CI care patients (expect A, B, X, D once each; NO patient C; invite_sent_at NULL = TC15)' AS section;
SELECT u.id, u.first_name, u.last_name, u.mrn, u.contact_number, u.invite_sent_at, u.created_at FROM users u WHERE u.mrn LIKE 'QA-CI-%' ORDER BY u.id;
SELECT '2. Patient D count (TC17 - expect 1)' AS section;
SELECT COUNT(*) AS patient_d_count FROM users WHERE mrn LIKE 'QA-CI-D-%' AND created_at > NOW() - INTERVAL 2 HOUR;
SELECT '3. Org links (TC13 - patient X only in org 1)' AS section;
SELECT u.mrn, oa.organisation_id, oa.type, oa.external_id FROM organisation_associations oa JOIN users u ON u.id = oa.user_id WHERE u.mrn LIKE 'QA-CI-%' ORDER BY u.mrn;
SELECT '4. Episodes (TC07 - patient A has 1 scoliosis episode, no kyphosis episode; patient B none)' AS section;
SELECT u.mrn, c.`key` AS condition_key, e.id AS episode_id, e.status, e.started_on FROM patient_episodes e JOIN patient_conditions pc ON pc.id = e.patient_condition_id JOIN conditions c ON c.id = pc.condition_id JOIN users u ON u.id = pc.user_id WHERE u.mrn LIKE 'QA-CI-%' ORDER BY u.mrn, e.id;
SELECT '5. Cases (TC09 - patient A only spinal fusion 2026-12-10, no ACDF; patient B none)' AS section;
SELECT u.mrn, ct.`key` AS case_type, pc2.case_date, pc2.status, pc2.external_id, pc2.created_by_id FROM patient_cases pc2 JOIN patient_episodes e ON e.id = pc2.patient_episode_id JOIN patient_conditions pc ON pc.id = e.patient_condition_id JOIN users u ON u.id = pc.user_id JOIN case_types ct ON ct.id = pc2.case_type_id WHERE u.mrn LIKE 'QA-CI-%' ORDER BY u.mrn, pc2.id;
SELECT '6. Failed care jobs last 2 hours (TC13 mrn_in_other_organisation, TC14 contact_number_taken)' AS section;
SELECT f.id, j.class_name, LEFT(f.error, 160) AS error, f.created_at FROM sip_dev_queue.solid_queue_failed_executions f JOIN sip_dev_queue.solid_queue_jobs j ON j.id = f.job_id WHERE f.created_at > NOW() - INTERVAL 2 HOUR ORDER BY f.id;
SELECT '7. QA-CI EHR messages (all should be processed)' AS section;
SELECT m.id, f.code AS feed, m.source_event_type AS type, m.status, m.error_code, LEFT(m.source_message_id, 40) AS event_id FROM integration_ehr_messages m JOIN integration_ehr_feeds f ON f.id = m.feed_id WHERE m.source_message_id LIKE 'qa-ci-%' ORDER BY m.id;
