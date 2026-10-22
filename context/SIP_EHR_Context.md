# SIP EHR - QA context (one file for future work)

*Owner: Omkar (QA). Last updated: 22 Oct 2026. Local testing only. Dummy data only.*

## 1. What SIP EHR does (simple)
Hospitals send patient data (HL7 or FHIR) to SIP. SIP stores the message, checks it, and publishes events. Care import then creates the SIP patient, episode and case, and the mapped surgeon sees the patient in SIP web. Imported patients are "Not invited" until someone clicks Invite.

## 2. Jira map
| Jira | What | QA status (22 Oct) |
|---|---|---|
| SIP-175 | OpenEMR -> SIP POC (sub-tasks SIP-234..237) | Done |
| SIP-179 | EHR integration V1: receive messages, publish events | Tested, comment posted |
| SIP-180 | HL7 v2 | Tested, comment posted |
| SIP-181 | FHIR | Tested, comment posted |
| SIP-216 | Create care patient / episode / case from EHR events (AC1-5) | 18 Passed, 1 NA, 1 Pending, 1 Failed - waiting Dev |
| SIP-217 | Care import jobs (Dev notes) | Same tab as SIP-216 |
| SIP-244 | Bug: update without phone/email wipes them (+ auto logout & notify patient) | To Do (Dev) |
| SIP-247 | Bug: long name / MRN clash -> unexpected_error + full name validation | Backlog |

Sheet: "SIP - Omkar" - tabs SIP-179 (gid 17901), SIP-180 (18001), SIP-181 (18101), SIP-216/217 (21601).

## 3. Setup (local)
- Repo `sip-server`, branch `qa/fhir-poc` (main merged 19 Oct, has SIP-217 and SIP-99).
- Docker: rails, solid-queue-worker, mysql_db, opensearch, adminer. Files `docker-compose.yml` + `docker-compose.app.yml`.
- SIP web localhost:8080, API localhost:3000, events browser localhost:3000/res, OpenEMR https://localhost:9300.
- Feeds: `synthetic_spine_fhir` (FHIR, org 1 Spine Center of Atlanta, surgeon Jay Chen = Practitioner/synthetic-surgeon-1) and `synthetic_globus_hl7` (HL7, org 2 Globus, Dr. Riley Shah = globus.physician, SYNTH-PROV-1860).
- If care import does nothing: `rails data:populate_ehr_feeds`.
- Bruno QA folders (local, never commit): `Bruno/QA EHR` - 01 Receive API, 02 Resend And Conflict, 03 Status API, 04 FHIR Patient, 05 HL7, 06 Manual Checks, 07 Care Import, 08 Unicode Name. SQL: `db_check.sql`, `care_check.sql`.
- Results folder: `~/Desktop/SIP/openemr/bruno-bulk` (sip179_*, sip216_*).

## 4. Dev decisions (do not re-raise)
- Fix: wipe phone/email on update (SIP-244); long name / MRN clash (SIP-247).
- Ignore: S15 for never-booked surgery, DOB 2099/1850, S13 after cancel.
- No change: unchanged resend publishes event again.
- Expected: no start time -> scheduled no date; same JSON different spacing -> 409; lowercase bearer -> 401; bad phone rejects whole patient.
- X-Ehr-Event-Type must be in the feed's allowed events for that resource.
- Update does not re-fetch (fetch chain only on PatientCreated, FHIR).

## 5. New stories from Dev (not QA bugs)
1. Auto-invite flag for EHR patients (today push + SMS go out on case add even when Not invited).
2. Merge self sign-up patient with EHR patient.
3. Merge EHR and domain services.
4. UI for failed EHR requests and non-invited patients.

## 6. Open items (22 Oct)
- TC21: A04 + A08 for same patient close together -> RecordNotUnique, message quarantined, data lost. Sent to Dev, waiting.
- TC16: SIP-217 says "setting off by default" but code/doc says feed enabled flag is the only switch. Asked Dev.
- TC05 + SIP-179 F17/H08: retest after SIP-244 fix. F11/F20: retest after SIP-247.
- After Dev replies: update sheet, final QA comment on SIP-216/217 (with SS), user changes status.

## 7. Ideas for future EHR testing
- Invite an imported patient -> invite + onboarding survey works.
- Surgeon sees only own org patients (cross-org check).
- Case with impossible date (invalid_case_date), case before episode start.
- Retry a failed job after fixing data.
- Real hospital timing: many messages for one patient within seconds (load / order test).
- When real code maps come: re-run code-map tests with real ICD/CPT lists.

## 8. Lessons learned
- Bruno: use repo CLI + `-r`; runtime vars only inside one run; use `--env-var` to reuse values.
- zsh: quote `'^DB_PASSWORD='`.
- After `docker compose restart`, start the worker again if it is not Up.
- Check Dev doc `docs/ehr-care-import.md` first - it lists all failed / ignored reasons.
- Commands as one line; ask for exact error text; one step at a time.
