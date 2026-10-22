---
name: sip-qa-bruno-builder
description: Use when QA needs Bruno API requests made from test scenarios - "make Bruno requests", "create Bruno folder for SIP-xxx", "automate these test cases in Bruno", "add a request for TCxx". Builds a local QA Bruno folder (opencollection YAML) with assertions, run command and DB/log checks.
---

# SIP QA Bruno builder

Turn test scenarios into a Bruno folder the user can run with one command.

## Rules

1. **QA folders only:** `Bruno/QA <Area>/<NN Name>/` inside the sip-server repo. **Never commit** them. Never edit Dev folders (`Flows/`, `Domains/`).
2. **No secrets in files.** Tokens and passwords come from the `Local` environment (`{{EHR_FEED_TOKEN}}`, `{{PROVIDER_ACCESS_TOKEN}}`, ...). If a login is needed, reuse the Dev sign-in request or ask the user to run it - do not copy passwords.
3. **Dummy data** with a unique stamp per run: `const s = Date.now();` -> MRN `QA-<TAG>-${s}`, event id `qa-<tag>-${s}-<step>`, phone from `s % 100000`.
4. **One folder = one run.** Runtime vars live only inside one run, so put setup + test + check in the same folder, in order (`01`, `02`, ...).
5. **Wait for async work:** add `await bru.sleep(3000-5000);` before a request that depends on the worker. Also space out messages for the same patient (known race, TC21).
6. **Check the format first:** read 1-2 existing requests in the repo (e.g. a Dev flow) and copy their style - headers, auth, body type. Bruno CLI 4.x uses opencollection YAML (`info`, `http`, `runtime`, `settings`).

## Steps

1. Get the scenarios (from the sheet tab or the user). Confirm the list (ID + title + expected status code).
2. Read the API: controller / route / Dev Bruno flow / docs for the endpoint, headers and body.
3. Write the files (template below). File name: `NN <TC ID> <short title> - Expect <result>.yml`.
4. Add a `folder.yml` with docs: Jira id, "QA only, local, do not commit".
5. Check: parse every YAML (python `yaml.safe_load`), make sure no password / real token is in any file.
6. Give the user ONE-line commands: run, wait, DB check, log check (see skill `sip-ehr-qa` > local-setup).
7. Read the result files, then update the sheet (skill `sip-qa-test-sheet`).

## Request template

```yaml
info:
  name: TC07 Patient A - Kyphosis Diagnosis - Expect Ignored
  type: http
  seq: 3
http:
  method: POST
  url: '{{SERVER_URL}}/integration/ehr/messages'
  headers:
  - name: Accept
    value: application/json
  - name: Content-Type
    value: application/hl7-v2
  body:
    type: text
    data: |-
      MSH|^~\&|SYNTH_EHR|SYNTH_GLOBUS|SIP|SIP|20261022100000||ADT^A08^ADT_A01|{{QA_EVENT_ID}}|P|2.5.1
      PID|1||{{QA_MRN}}^^^SYNTH_GLOBUS^MR||QACare^Test||19800101|F
  auth:
    type: bearer
    token: '{{EHR_HL7_FEED_TOKEN}}'
runtime:
  scripts:
  - type: before-request
    code: |-
      await bru.sleep(3000);
      bru.setVar("QA_EVENT_ID", `qa-x-${bru.getVar("QA_STAMP")}-a08`);
  assertions:
  - expression: res.status
    operator: eq
    value: '202'
  actions:
  - type: set-variable
    phase: after-response
    selector:
      expression: res.body.message_id
      method: jsonq
    variable:
      name: QA_MSG_ID
      scope: runtime
settings:
  encodeUrl: true
  timeout: 0
  followRedirects: true
  maxRedirects: 5
docs: |-
  TC07. What it tests and what to expect (status, log line, DB).
```

- Assertion operators: `eq`, `neq`, `gt`, `contains`, `notContains`, `isDefined`, `isUndefined`.
- JSON body: `body: { type: json, data: |- {...} }`.
- Status check request: `GET {{SERVER_URL}}/integration/ehr/messages/{{QA_MSG_ID}}` with assertions on `res.body.status`, `res.body.error_code`.

## Run commands (one line each)

- Folder: `cd <REPO>/Bruno && ./node_modules/.bin/bru run "QA <Area>/<NN Name>" -r --env Local --reporter-json <RESULTS>/<name>.json`
- One file with old values: `... bru run "<path>.yml" --env Local --env-var QA_STAMP=<value>`

## Output to the user

Folder name, list of requests (ID + expected), the run command, then "say done and I will read the results".
