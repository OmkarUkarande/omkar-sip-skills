---
name: sip-ehr-qa
description: Use when testing SIP EHR integration on a local laptop - HL7 or FHIR messages, EHR feeds, care import (patient, episode, case from EHR), Bruno EHR flows, EHR DB checks, worker logs, or any Jira about EHR / integration / OpenEMR / hospital messages. Also use to explain HL7/FHIR terms (A04, A08, S12, DG1) in simple words.
---

# SIP EHR QA

Help a QA engineer test the SIP EHR integration on their own laptop, in simple steps.

## Golden rules (always)

1. **Local only.** Dummy data only (MRN starts with `QA-`). Never use real patient data.
2. **No secrets in files.** Never write passwords or tokens into files, Jira or chat. Tokens come from the Bruno `Local` environment; passwords come from the Dev seed / Dev Bruno flow.
3. **Never commit QA folders** (`Bruno/QA EHR`, result files) to the sip-server repo.
4. **Commands are ONE line.** Multi-line pastes break in the terminal. Chain with `&&` (or `;` when the next step must run even if the first fails).
5. **One step at a time.** Say which app (Terminal / Bruno / browser / DB), what to type, and what the user should see.
6. **On an error, ask for the exact message.** Do not guess.
7. Save run outputs to a results folder (e.g. `bruno-bulk/` next to the repo) so they can be read and attached.
8. PHI rule from Dev: event data can hold PHI - never paste event payloads into Jira or chat.

## The flow in one picture

```
Hospital EHR --(HL7 or FHIR message)--> POST /integration/ehr/messages
  -> stored (received) -> worker: parse > route > map > validate > identity > match_codes > publish
  -> message status: processed / quarantined / ignored
  -> domain events (PatientCreated, PatientUpdated, ConditionRecorded, CaseScheduled ...)
  -> Care import jobs -> SIP care patient -> episode -> case -> surgeon sees patient in SIP web
```

Simple words: see `references/ehr-basics.md` (A04, A08, S12, DG1, FHIR, statuses, error codes).

## How to run a test (standard steps)

1. **Check setup** (Terminal): containers up (rails, solid-queue-worker, mysql_db). Worker must be Up - if not, start it again (see `references/local-setup.md`).
2. **Check seed**: feeds + physician mapping exist. If care import does nothing / case unassigned -> run `rails data:populate_ehr_feeds` in the rails container.
3. **Send messages** with Bruno CLI from the repo `Bruno` folder:
   `./node_modules/.bin/bru run "<folder>" -r --env Local --reporter-json <results>/<name>.json`
   - `-r` is needed for folders. Runtime vars live only inside one run, so put related requests in one folder.
   - Use templates in `templates/` (HL7 and FHIR). New MRN + new event id per run (use `Date.now()`).
4. **Wait 5-10 s** for the worker, then **check DB** with a `.sql` file (templates: `templates/ehr_db_check.sql`, `templates/care_check.sql`).
5. **Check worker log** for `ehr.run ... outcome=`, `ignored <reason>`, `Failed (<reason>)`.
6. **Check UI** in SIP web (login as the mapped surgeon) and take a screenshot.
7. **Record result** in the test case sheet (skill `sip-qa-test-sheet`) and Jira (skill `sip-qa-jira`).

Exact one-line commands: `references/local-setup.md`.

## What to cover for any EHR Jira (checklist)

- **Receive API**: token missing/wrong (401), wrong content type (415), bad body (422), too big (413), dedupe (same id = 200 same message, same id + different body = 409).
- **Status API**: own message, other feed (404), unknown id (404).
- **Mapping / validation**: required fields, dates, phone, unknown codes, long text (boundary 255/256), Unicode names.
- **Event types**: create / update / cancel per feed `allowed_events` (X-Ehr-Event-Type must be allowed for that resourceType).
- **Care import (AC style)**: create vs update by org + MRN, fields not sent stay unchanged, active episode rules, case under matching episode, resend = no duplicates, physician mapped vs unassigned.
- **Failures and ignores**: MRN in other org, email/phone taken, invalid case date; ignored reasons in worker log.
- **Order and timing**: messages for one patient close together (known risk), worker stopped then started (nothing lost).
- **UI**: patient list, header, episode, case, surgeon, "Not invited" status, no onboarding survey.
- **Out of scope**: write NA with one line why.

Full scenario list with IDs and expected results: `references/test-catalogue.md`.

## Known decisions and bugs (check before raising a bug)

See `references/test-catalogue.md` > "Dev decisions". Do not re-raise items Dev marked Expected / Ignore.

## Output

- Steps for the user: numbered, short, one command per step.
- Results: Passed / Failed / NA / Pending + one line of evidence (status code, message id, DB value, log line).
