---
name: sip-qa-bug-retest
description: Use when Dev fixes a bug and QA must retest it - "retest SIP-xxx", "bug is fixed check it", "Ready for QA bug", "close the bug". Finds the linked test cases, re-runs them, checks for side effects, and updates the sheet and Jira.
---

# SIP QA bug retest

Retest a fixed bug end to end, then update the sheet and Jira.

## Steps

1. **Read the bug** (steps, expected, Dev comments, "Dev added" points, linked stories). Note the fix build / branch / PR.
2. **Get the latest code** on the test laptop or env (pull the branch, restart app, worker Up, seed if needed). Ask the user to confirm the build.
3. **Find the linked test cases:** test IDs in the bug (e.g. F17, H08, TC05) and rows in the sheet tabs that say `Failed - <bug id>` or `Pending - blocked by <bug id>`.
4. **Plan the retest** (show the user):
   - **Fix check:** the exact bug steps -> now expected result.
   - **New points:** anything Dev added to the bug (e.g. auto logout + notify).
   - **Side effects (regression):** 3-5 nearby happy paths that use the same code (e.g. create, update, resend).
5. **Run** with Bruno (skill `sip-qa-bruno-builder` / existing QA folders), DB check and worker log, UI check + screenshot if UI is involved.
6. **Decide:**
   | Result | Action |
   |---|---|
   | Fixed + no side effects | Sheet rows -> `Passed - retest <date>`. Jira comment `QA TESTED - VERIFIED & VALIDATED`. User moves bug to Done/Closed. |
   | Partly fixed | Sheet `Failed - retest <date>: <what still fails>`. Jira comment `QA FAILED - REOPENED` with steps + evidence. |
   | New problem found | Keep bug result as is; raise a new bug (skill `sip-qa-jira`) and link it. |
7. **Update** the story too: change its blocked rows (e.g. TC05 on SIP-216) and add one line to the story's QA comment.

## Retest comment (short)

```
[QA TESTED] - [VERIFIED & VALIDATED]  [LOCAL]   (or [QA FAILED] - [REOPENED])

Dev fixed <one line> - re-tested on <env/build>.

Testing points:
- **Bug steps** - <result>  [PASSED]
- **<Dev added point>** - <result>  [PASSED]
- **Regression: <area>** - <result>  [PASSED]

Evidence: <sheet tab link> (rows <ids>), <run file / SS>
CC: @Dev
```

## Rules

- Retest on the build that has the fix - always write the build/branch/date in the evidence.
- Never mark Passed without proof (status code, DB value, log line or SS).
- Do not change Jira status yourself unless the user asks.
