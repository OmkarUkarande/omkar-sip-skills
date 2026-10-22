---
name: sip-qa-jira
description: Use for any SIP Jira writing by QA - QA comment / sign-off ("QA tested verified validated", "make QA comment", "update Jira"), raising a bug ticket, a message to Dev about findings, or an EOD / status update. Writes simple human words with coloured status labels and CC @developer mentions.
---

# SIP QA Jira writing

Four outputs: **QA comment**, **Bug ticket**, **Dev message**, **EOD status**. Always simple, short, human words. Main things in **bold** or as a status label.

## Before writing

1. Read the Jira: description, AC, status, assignee, comments, linked issues.
2. Read the QA sheet tab for the counts and results (skill `sip-qa-test-sheet`).
3. **Find who to CC:** the Jira assignee + every developer who commented on the Jira (not QA, not bots). Add any fixed names the user asks for. Look up their Atlassian accountId and use a real mention.
4. Show the draft to the user. Post only after "yes". Never change the Jira status unless asked.

## 1. QA comment

Post as ADF (rich text) so the labels show as coloured lozenges. Templates: `references/adf-templates.md`.

**Header labels** (first line) - pick one:
| Result | Labels |
|---|---|
| All passed | `QA TESTED` (green) - `VERIFIED & VALIDATED` (green) |
| Passed with known bugs / open items | `QA TESTED` (green) - `VERIFIED WITH KNOWN ISSUES` (yellow) |
| Still testing | `QA IN PROGRESS` (blue) |
| Blocked | `QA BLOCKED` (yellow) |
| Failed / reopen | `QA FAILED` (red) - `REOPENED` (red) |

Then an env label: `LOCAL` / `TEST ENV` / `STAGE` (grey).

**Body:**
```
[labels]  [env label]

**Summary:** 1-2 lines - what was tested and how (Bruno API / app UI / DB / logs). Counts: X Passed, Y Failed, Z NA, W Pending.

**Testing points:**
- **<Area>** - what was checked - result seen (code / message / DB value).  [PASSED]
- **<Area>** - ...  [FAILED - SIP-xxx]
- **<Area>** - ...  [NA - out of scope]
- **<Area>** - ...  [PENDING - blocked by SIP-xxx]

**Bugs / open items:** SIP-xxx (one line each)   (only if any)

**Evidence:** PFA sheet & screenshots - <sheet tab link>

CC: @Dev1 @Dev2
```
Rules:
- 4-8 testing points. One area per point. Real results, not "works".
- Small status label at the end of each point: PASSED (green), FAILED (red), NA (grey), PENDING (yellow).
- NA / pending items are always listed, never hidden.
- Re-test after a Dev fix: first line under labels = "Dev fixed <X> - re-tested all scenarios."
- No passwords, tokens or patient data (PHI) in comments.

## 2. Bug ticket

Type Bug. Title: `[Server|Web|Mobile] <area>: <what breaks>`. Labels: area tags (e.g. `EHR`, `server`). Link "relates to" the story.
```
Found during QA of <JIRA> on <env>.

### Issue - <one line>
**Steps**
1. ...
**Actual**
- ...
**Expected**
- ...

**Environment:** <env, branch/build, data used>
**Evidence:** <test ids, sheet tab, files>
**Related:** <JIRA ids>
```
One issue per bug. If Dev splits or adds points, update the ticket the same way (add a "Dev added" section).

## 3. Dev message (Slack / chat)

```
Hi <name>, found <one thing> while testing <JIRA> on <env>.

What I did: <1-3 short steps>
What happened: <result, ids, error code>
Expected: <one line>

<Why it matters - one line>. Should I raise a bug, or is it known / planned? Evidence: <sheet tab / TC id>.
```
Keep it under 10 lines. Ask one clear question at the end.

## 4. EOD status

```
EOD - <date>
- <JIRA> - <done / in progress / blocked> - <one line what>.
- ...
Blockers: <none / one line each>
Tomorrow: <1-2 lines>
```
No emoji. 1-2 lines per item.

## Tone

Plain English, short sentences, casual but professional. Bold only the key words. No long paragraphs.
