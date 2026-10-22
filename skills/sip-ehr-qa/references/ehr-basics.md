# EHR basics in simple words

## Words
| Word | Simple meaning |
|---|---|
| EHR | Hospital system that holds patient records (e.g. OpenEMR, Epic). |
| Feed | One hospital connection in SIP. Has a token, an organisation, a protocol (HL7 or FHIR) and `allowed_events`. |
| HL7 v2 | Old text format. Lines (segments) split by `|`. Content-Type `application/hl7-v2`. |
| FHIR | New JSON format (resources like Patient, Condition, Appointment). Content-Type `application/fhir+json`. |
| MRN | Patient number at the hospital. |
| Event id | Unique id of one message (HL7: MSH-10; FHIR: header `X-Ehr-Event-Id`). Same id again = resend. |

## HL7 message types
| Code | Meaning | In SIP |
|---|---|---|
| ADT^A04 | Register a patient | Creates patient |
| ADT^A08 | Update patient info | Updates patient; with DG1 can record a condition |
| SIU^S12 | Book appointment (surgery) | Creates case |
| SIU^S13 / S14 | Reschedule / modify | Updates case (not handled by care import V1) |
| SIU^S15 | Cancel | Cancels case (not handled by care import V1) |

## HL7 segments (lines)
| Segment | Holds |
|---|---|
| MSH | Header: sender, message type (MSH-9), control id (MSH-10), version |
| EVN | Event type and time |
| PID | Patient: MRN (PID-3), name (PID-5 `Last^First`), DOB (PID-7), sex, address, phone (PID-13) |
| PV1 | Visit |
| DG1 | Diagnosis (ICD-10 code e.g. M41.125 scoliosis) |
| SCH | Appointment ids (SCH-1 placer, SCH-2 filler) and status |
| AIS | Procedure (CPT code e.g. 22802 spinal fusion) and start time |
| AIL | Location (OR room) |
| AIP | Surgeon id (mapped to a SIP physician) |

## FHIR basics
- Headers: `X-Ehr-Event-Id` (unique), `X-Ehr-Event-Type` (`create` / `update` / `cancel`, must be allowed by the feed for that resource).
- Patient: `id`, `identifier` (MRN), `name` (family, given), `birthDate`, `gender`, `telecom` (phone/email).
- Only PatientCreated on the FHIR feed triggers the fetch chain (follow-up fetches for conditions and appointments).

## Message status
| Status | Meaning |
|---|---|
| received | Stored, waiting for worker |
| processing | Worker is on it |
| processed | Done, events published |
| quarantined | Stopped with an error code (needs fix / resend) |
| ignored | Valid but nothing to do (e.g. code not in catalogue) |

Stages: parse > route > map > validate > identity > match_codes > publish. `last_stage` tells where it stopped.

Common error codes: `missing_required_field`, `invalid_date`, `invalid_phone`, `invalid_field`, `unsupported_event`, `unknown_patient`, `not_in_catalogue`, `invalid_feed_token` (401), `unexpected_error` (not handled - often a bug).

## Care import (SIP-216 / SIP-217)
| Event | Job | Result |
|---|---|---|
| PatientCreated / PatientUpdated | Patients::CreateOrUpdatePatientJob | Create or update care patient (by org + MRN) |
| ConditionRecorded | PatientEpisodes::CreateOrUpdatePatientEpisodeJob | Create active episode if none |
| CaseScheduled | PatientCases::CreateOrUpdatePatientCaseJob | Create case under active episode with same condition |

- Failed (not retried, saved in Solid Queue failed executions): `mrn_in_other_organisation`, `external_id_conflict`, `mrn_taken`, `email_taken`, `contact_number_taken`, `invalid_case_date`, `invalid_param`.
- Ignored (worker log warn `<Job>: ignored <reason>`): episode job `patient_unknown`, `condition_unknown`, `episode_active`, `episode_overlap`; case job `already_recorded`, `patient_unknown`, `no_active_episode`, `episode_condition_differs`, `case_type_unknown`, `case_before_episode_start`, `duplicate_case`.
- Physician: case `provider.id` mapped to a SIP physician -> case assigned; not mapped -> case unassigned (surgeon does not see patient).
- Imported patients are "Not invited" (no invite, no onboarding survey).
- Only switch: feed enabled flag. Disabled feed -> 401 `invalid_feed_token`.
- Not handled in V1: ConditionUpdated, CaseUpdated, CaseCancelled, CaseCompleted.

## Code maps
- Org row beats global row; exact match beats prefix; longer prefix wins.
- Synthetic seed: M41* scoliosis, M40.0/M40.2 kyphosis, M40.5 lordosis; CPT 22800-22812 spinal fusion, 22551 ACDF (lordosis), 22600 PCF (kyphosis).
