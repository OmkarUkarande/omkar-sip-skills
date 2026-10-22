# ADF templates (Jira rich text)

Use `contentFormat: "adf"` when posting with the Atlassian tool. Status colours: `neutral` (grey), `purple`, `blue`, `red`, `yellow`, `green`.

## Status label (lozenge)
```json
{ "type": "status", "attrs": { "text": "QA TESTED", "color": "green" } }
```

## Mention (real @)
```json
{ "type": "mention", "attrs": { "id": "<atlassian accountId>", "text": "@Name Surname" } }
```
Find the accountId: assignee / comment author on the Jira, or `lookupJiraAccountId` with the name.

## Full QA comment (example)
```json
{
  "type": "doc", "version": 1,
  "content": [
    { "type": "paragraph", "content": [
      { "type": "status", "attrs": { "text": "QA TESTED", "color": "green" } },
      { "type": "text", "text": " - " },
      { "type": "status", "attrs": { "text": "VERIFIED & VALIDATED", "color": "green" } },
      { "type": "text", "text": "  " },
      { "type": "status", "attrs": { "text": "LOCAL", "color": "neutral" } }
    ]},
    { "type": "paragraph", "content": [
      { "type": "text", "text": "Summary: ", "marks": [{ "type": "strong" }] },
      { "type": "text", "text": "Tested care import end to end with Bruno, DB checks and SIP web. 18 Passed, 1 NA." }
    ]},
    { "type": "paragraph", "content": [ { "type": "text", "text": "Testing points:", "marks": [{ "type": "strong" }] } ]},
    { "type": "bulletList", "content": [
      { "type": "listItem", "content": [ { "type": "paragraph", "content": [
        { "type": "text", "text": "Patient create", "marks": [{ "type": "strong" }] },
        { "type": "text", "text": " - HL7 A04 and FHIR create made the care patient, resend made no duplicate. " },
        { "type": "status", "attrs": { "text": "PASSED", "color": "green" } }
      ]}]}
    ]},
    { "type": "paragraph", "content": [
      { "type": "text", "text": "Evidence: ", "marks": [{ "type": "strong" }] },
      { "type": "text", "text": "PFA sheet & screenshots - " },
      { "type": "text", "text": "SIP-216/217 tab", "marks": [{ "type": "link", "attrs": { "href": "<sheet tab link>" } }] }
    ]},
    { "type": "paragraph", "content": [
      { "type": "text", "text": "CC: " },
      { "type": "mention", "attrs": { "id": "<accountId>", "text": "@Dev Name" } }
    ]}
  ]
}
```
