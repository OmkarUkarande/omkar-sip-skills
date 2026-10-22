---
name: sip-qa-test-sheet
description: Use when a Jira comes to QA and test cases must be written or results recorded in the QA Google Sheet - "make test cases", "add sheet tab", "update sheet", "test scenarios for SIP-xxx", "mark passed/failed". Builds one tab per Jira in the fixed 8-column format with Passed/Failed/NA/Pending status.
---

# SIP QA test case sheet

One Google Sheet per QA person (ask for the link once). **One tab per Jira.** Same format every time, so anyone can read any tab.

## Steps

1. **Read the Jira** (description, AC, comments, linked tickets). List every AC and note out-of-scope items.
2. **Draft the cases** (show the list to the user first - titles + status only - and confirm).
3. **Create the tab** (format below), fill rows, then share the tab link (`.../edit#gid=<sheetId>`).
4. **While testing**, update Actual Result + Status per row with real evidence.
5. **At the end**, give the counts: Passed / Failed / NA / Pending.

## Columns (exactly these 8)

| Col | Header | What to write |
|---|---|---|
| A | Sr. No. - TC ID | `TC01 - AC1`, `TC07 - AC2`, `TC13 - SIP-217`, `TC21 - Bug`, `M01` (manual), `DEV-01` (Dev flow) |
| B | Test Case Title | One line: `Verify <what> <condition> <expected>` |
| C | Precondition | What must be ready (env, seed, data, previous TC) |
| D | Account Details | Env + feed / role / login email. **Never passwords or tokens.** |
| E | Test Steps | Numbered, short: `1. ...\n2. ...` |
| F | Expected Result | From the AC, in simple words |
| G | Actual Result | `Run <date>: <what happened> + evidence` (status code, message id, DB value, log line, "PFA SS") |
| H | Status | `Passed` / `Failed` / `NA` / `Pending` / `In Progress` (add short reason: `Failed - SIP-244`, `NA - out of scope`, `Pending - blocked by SIP-244`) |

Row 1 = title (merged A1:H1): `<JIRA-ID> - <Jira title> - <Env> QA`. Row 2 = headers. Data from row 3.

## Coverage rule (what rows to write)

- At least **1 positive row per AC**, plus the main negative / boundary rows.
- Add rows for: duplicates/resend, permissions/roles, failures and error codes, UI check, regression of the old flow.
- Out-of-scope items: one row with `NA` and why (never hide them).
- Bugs found: one row with `Failed` + bug id; keep it after the fix and update to `Passed - retest <date>`.
- Default 10-25 rows. Keep titles short.

## Format (exact)

- Title row: background `rgb(0.976, 0.8, 0.608)`, font EB Garamond 15 bold.
- Header row: background `rgb(0.118, 0.227, 0.447)`, white bold, size 15.
- Body: EB Garamond 11, wrap, borders on all cells.
- Column widths (px): 142, 335, 294, 323, 288, 273, 360, 150. Freeze 2 rows.
- Conditional format on column H (text contains): Passed = green, Failed = red, NA = grey, Pending = yellow, In Progress = blue.

### Easiest way (Google Sheets tools)

1. `duplicateSheet` from any existing formatted tab (new `sheetId` like `<jira number>01`, e.g. SIP-216 -> 21601, title = Jira id).
2. `repeatCell` with `fields: "userEnteredValue"` on rows 3+ to clear old values (keeps format).
3. `update_values` for A1:H<n>.
4. `deleteDimension` for extra empty rows; `appendDimension` + `copyPaste` (PASTE_FORMAT) to add rows.

If no formatted tab exists, create the tab with `addSheet`, then apply the format above with `repeatCell`, `updateDimensionProperties`, `mergeCells`, `updateBorders`, `addConditionalFormatRule`.

## Writing style

- Simple words. Short sentences. No jargon unless needed (then explain once).
- Actual Result must have proof. "Works" alone is not enough.
- Dummy data only in the sheet (MRN `QA-...`, test emails).

## Example rows

| TC ID | Title | Expected | Actual | Status |
|---|---|---|---|---|
| TC07 - AC2 | Verify Condition event is ignored when an active episode exists | No 2nd episode, log "ignored episode_active" | Run 22 Oct: msg 166 processed, log shows ignored episode_active, 1 episode in DB | Passed |
| TC05 - AC1 | Verify fields not sent in update stay unchanged | Phone and email kept | Blocked by SIP-244 | Pending |
| TC19 - Out of scope | Verify reschedule / cancel in care | Out of scope as per Jira | - | NA |
