# EHR test catalogue

Reusable scenario list from SIP-179 (V1), SIP-180 (HL7), SIP-181 (FHIR), SIP-216/217 (care import). Use the IDs in sheets and Jira. Bruno folder names are from the local `QA EHR` folder (copy, never commit).

## Dev decisions (do not re-raise)
| Finding | Decision |
|---|---|
| Patient update without phone/email wipes saved values (F17, H08) | Bug SIP-244 (+ auto logout and notify patient) |
| Last name > 255 / MRN clash -> unexpected_error (F11, F20) | Bug SIP-247 (backlog) + full name validation |
| SIU S15 for never-booked surgery creates cancelled case | Ignore |
| DOB 2099 / 1850 accepted | Ignore |
| Unchanged resend publishes update/cancel again | No change |
| S13 after cancel moves case back to scheduled | Ignore |
| Surgery with no start time saved as scheduled, no date | Expected |
| Same JSON with only spacing changed -> 409 | Expected |
| Lowercase `bearer` -> 401 | Expected |
| Bad phone rejects whole patient | Expected |
| EHR patients get push/SMS on case add before invite | New story: auto-invite flag |
| A04 + A08 for same patient sent close together -> RecordNotUnique, message lost (TC21) | Asked Dev (22 Oct) |
| Care import switch = feed enabled flag only (no separate setting) | Asked Dev (22 Oct) |

## SIP-179 / 180 / 181 scenarios
| ID | Scenario | Expected |
|---|---|---|
| DEV-01 | Verify FHIR happy path: new patient, fetch conditions + appointments, care patient, update, resend | All 12 pass: 202, processed, 4 follow-ups (2 processed, 2 ignored), patient in care, no duplicates |
| DEV-02 | Verify FHIR conflicting resend returns 409 | Step 2 = 409 conflicting_payload |
| DEV-03 | Verify FHIR patient without birth date is quarantined | quarantined, missing_required_field |
| DEV-04 | Verify HL7 happy path: A04, resend, A08 + DG1, S12, care, S13, S15 | All 16 pass; patient + case in care for globus.physician |
| DEV-05 | Verify old FHIR Sync (test_resource) flow still works | Patient + case created via /fhir/test_resource |
| TC-R01 | Verify request without token is refused with 401 | 401 invalid_feed_token, nothing stored |
| TC-R02 | Verify wrong token is refused with 401 | 401 invalid_feed_token |
| TC-R03 | Verify FHIR body on HL7 feed is refused with 415 | 415 unsupported_media_type |
| TC-R04 | Verify application/json Content-Type is refused and patient data is not logged | 415; log shows [FILTERED] for patient fields |
| TC-R05 | Verify missing X-Ehr-Event-Id is refused | 422 missing_event_id |
| TC-R06 | Verify event type 'Create' (capital) is refused | 422 invalid_event_type |
| TC-R07 | Verify event type 'delete' is refused | 422 invalid_event_type |
| TC-R08 | Verify broken JSON is refused | 422 invalid_json |
| TC-R09 | Verify JSON array body is refused | 422 invalid_json |
| TC-R10 | Verify body without resourceType is refused | 422 missing_resource_type |
| TC-R11 | Verify empty body is refused | 422 |
| TC-R12 | Verify event id longer than 255 chars is refused | 422 envelope_too_long |
| TC-R13 | Verify body over 1 MB is refused | 413 payload_too_large |
| TC-R14 | Verify Content-Type with charset is accepted | 202 |
| TC-R15 | Verify lowercase 'bearer' scheme is accepted (RFC 7235) | 202 (401 = minor finding) |
| TC-R16 | Verify HL7 without MSH is refused | 422 invalid_hl7 |
| TC-R17 | Verify HL7 without MSH-10 is refused | 422 missing_control_id |
| TC-R18 | Verify HL7 without MSH-9 is refused | 422 missing_message_type |
| TC-R19 | Verify HL7 with text/plain is refused | 415 |
| TC-D01 | Verify new FHIR patient is accepted with message_id and status_url | 202 + message_id + status_url |
| TC-D02 | Verify exact resend returns 200 with the same message_id | 200, same message_id, no new row |
| TC-D03 | Verify same event id with different body is refused | 409 conflicting_payload, nothing stored |
| TC-D04 | Verify same content with only whitespace change (JSON re-serialized retry) | 200 expected by content; 409 = finding (raw byte compare) |
| TC-D05 | Verify same event id on another feed is accepted (dedupe per feed) | 202 |
| TC-D06 | Verify attempts_count stays 1 after resend | attempts_count = 1 |
| TC-S01 | Verify status shows own message without payload or patient data | 200; status, last_stage, received_at; no raw_payload, no DOB |
| TC-S02 | Verify another feed cannot read the message | 404 |
| TC-S03 | Verify unknown id returns 404 | 404 |
| TC-S04 | Verify status without token returns 401 | 401 |
| TC-S05 | Verify non-numeric id returns 404 | 404 |
| TC-F01 | Verify patient without family name is quarantined | quarantined missing_required_field |
| TC-F02 | Verify patient without id and identifier is quarantined | quarantined missing_required_field |
| TC-F03 | Verify invalid birth date 1990-13-45 is quarantined | quarantined invalid_date |
| TC-F04 | Verify future birth date 2099 is not accepted | quarantined |
| TC-F05 | Verify birth date 1850 is not accepted | quarantined |
| TC-F06 | Verify invalid phone handling | quarantined invalid_phone OR phone dropped (agree with PM) |
| TC-F07 | Verify Patient cancel event is quarantined | quarantined unsupported_event |
| TC-F08 | Verify Observation resource is quarantined | quarantined unsupported_event |
| TC-F09 | Verify Bundle resource is quarantined | quarantined unsupported_event |
| TC-F10 | Verify identifier from unknown authority is not saved as MRN | processed; MRN empty in DB |
| TC-F11 | Verify 300-char last name is handled | quarantined invalid_field |
| TC-F12 | Verify Unicode name (José Ñúñez-O'Brien) is saved correctly | processed; name correct in DB + care |
| TC-F13 | Verify blank family name ' ' is quarantined | quarantined missing_required_field |
| TC-F14 | Verify year-only birth date 1985 | quarantined invalid_date or saved 1985-01-01 (agree) |
| TC-F15 | Verify patient with email + phone is created | processed |
| TC-F16 | Verify update with same data publishes nothing | ignored; no extra PatientUpdated |
| TC-F17 | Verify update without telecom keeps email + phone | processed; email + phone still in DB |
| TC-F18 | Verify update for never-created patient | Agree: create or quarantine |
| TC-F19 | Create patient B for identity clash | processed |
| TC-F20 | Verify update of A with B's MRN is quarantined clearly | quarantined, not unexpected_error |
| TC-H01 | Verify ADT^A04 new patient creates PatientCreated | processed |
| TC-H02 | Verify x-application/hl7-v2+er7 content type is accepted | processed |
| TC-H03 | Verify CR-only line endings work | processed |
| TC-H04 | Verify ADT^A03 (not allowed) is quarantined | quarantined unsupported_event |
| TC-H05 | Verify A04 without DOB is quarantined | quarantined missing_required_field |
| TC-H06 | Verify PID-3 from other authority is quarantined | quarantined missing_required_field |
| TC-H07 | Verify A08 for unknown patient | Agree: create or quarantine (AC2 covers known only) |
| TC-H08 | Verify A08 without phone keeps stored phone | processed; phone still in DB |
| TC-H09 | Verify A08 with same data publishes nothing | ignored |
| TC-H10 | Verify S12 for unknown patient is quarantined | quarantined unknown_patient |
| TC-H11 | Verify S12 with untracked CPT and no DG1 is ignored | ignored not_in_catalogue |
| TC-H12 | Verify S12 books a surgery (CaseScheduled with surgeon + OR) | processed; case in DB with provider + location |
| TC-H13 | Verify S12 resend with new control id publishes nothing | ignored |
| TC-H14 | Verify S13 reschedule gives CaseUpdated | processed; new date in DB |
| TC-H15 | Verify S15 cancel gives CaseCancelled | processed; status cancelled |
| TC-H16 | Verify second S15 publishes nothing | ignored |
| TC-H17 | Verify S13 after cancel | Agree: reopen or quarantine |
| TC-H18 | Verify S15 for never-scheduled surgery is not published | quarantined/ignored |
| TC-H19 | Verify S12 without appointment id is quarantined | quarantined missing_required_field |
| TC-H20 | Verify S12 with invalid start date is quarantined | quarantined invalid_date |
| TC-H21 | Verify S12 without start time | Agree: quarantine or dateless case |
| TC-H22 | Verify DST-day time uses feed timezone | processed; starts_at correct in DB |
| TC-M01 | Verify message is not stuck if worker stops mid-processing | Message processed (0 stuck rows) |
| TC-M02 | Verify SIU before ADT is recovered | S12 stays quarantined (out of scope per Jira) - raise risk to PM |
| TC-M03 | Verify EHR cancel/reschedule updates SIP care case | SIP case shows new date / cancelled |
| TC-M04 | Verify events carry org, feed, message_id, refs, schema_version 2 | All fields present, same shape HL7 vs FHIR |
| TC-M05 | Verify all-or-nothing publish | Both or none |
| TC-M06 | Verify code map: org row wins over global, exact over prefix | Org row used |
| TC-M07 | Verify follow-ups listed for FHIR patient | 4 follow-ups with own status |
| TC-M08 | Verify new diagnosis/appointment after patient created reaches SIP | Re-fetch happens |
| TC-M09 | Verify care patient gets no onboarding survey/invite automatically | Agree with PM |
| TC-M10 | Verify EHR patient notifications before consent | Agree with PM: should a hospital patient get SMS/push before signup/consent? |

## SIP-216 / 217 care import scenarios
| ID | Scenario | Expected |
|---|---|---|
| TC01 | FHIR PatientCreated creates care patient | Patient created for org + MRN |
| TC02 | HL7 A04 creates care patient | Patient created |
| TC03 | Resend same patient event | No duplicate patient |
| TC04 | Patient update reaches care | Same patient updated |
| TC05 | Fields not sent in update stay unchanged | Phone/email kept (blocked by SIP-244) |
| TC06 | Condition creates active episode | One active episode |
| TC07 | Second condition while episode active | Ignored episode_active, no 2nd episode |
| TC08 | Case under active episode with same condition | Case created with right date |
| TC09 | Case with different condition / no episode | Ignored episode_condition_differs / no_active_episode |
| TC10 | Resend condition / case | No duplicates |
| TC11 | Mapped physician | Case assigned, surgeon sees patient |
| TC12 | Unmapped physician | Case unassigned |
| TC13 | MRN already in another org | Failed mrn_in_other_organisation, no merge |
| TC14 | Email / phone already used | Failed contact_number_taken / email_taken |
| TC15 | No invite / onboarding survey | Not invited, invite_sent_at NULL |
| TC16 | Feed disabled | 401 invalid_feed_token, no care records |
| TC17 | Same new patient sent 3 times | One patient |
| TC18 | Failed / ignored can be checked | Worker log + failed executions show reasons |
| TC19 | Reschedule / cancel / complete | NA - out of scope V1 |
| TC20 | Unicode name | Saved and shown correctly in SIP web |
| TC21 | A04 + A08 same patient close together | All processed in order (failed on 22 Oct - asked Dev) |
