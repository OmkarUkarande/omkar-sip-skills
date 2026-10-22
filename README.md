# SIP QA skills

QA skills for Claude, built from real SIP testing (EHR, sheets, Jira). Personal repo for now - will be shared with the QA team.

| Skill | Use it for |
|---|---|
| `skills/sip-ehr-qa` | Testing EHR (HL7 / FHIR / care import) on a local laptop: steps, commands, DB checks, logs, scenario list |
| `skills/sip-qa-test-sheet` | Test cases in the QA Google Sheet - one tab per Jira, fixed 8-column format |
| `skills/sip-qa-jira` | QA comment with status labels + CC @dev, bug ticket, Dev message, EOD |
| `skills/sip-qa-bruno-builder` | Turn test scenarios into a runnable QA Bruno folder |
| `skills/sip-qa-bug-retest` | Retest a fixed bug + regression, update sheet and Jira |
| `context/SIP_EHR_Context.md` | One file with everything about SIP EHR so far - add to your Claude project |

## How to use
- **Claude desktop / Cowork:** Settings > Skills > add each folder (or zip a folder and upload).
- **Claude Code:** copy a skill folder into `~/.claude/skills/` (personal) or `<repo>/.claude/skills/` (team).
- Put `context/SIP_EHR_Context.md` in your Claude project files.

## Rules for everyone
- Dummy data only. No passwords, tokens or patient data in any file.
- QA Bruno folders and results never go into the sip-server repo.
- Keep words simple. Update the context file after each EHR Jira.

## Jira tracking
Story: [SIP-259](https://higgsbosonhealth.atlassian.net/browse/SIP-259) - SIP QA Claude skills (latest zips attached).

| Skill | Sub-task |
|---|---|
| sip-ehr-qa | [SIP-260](https://higgsbosonhealth.atlassian.net/browse/SIP-260) |
| sip-qa-test-sheet | [SIP-261](https://higgsbosonhealth.atlassian.net/browse/SIP-261) |
| sip-qa-jira | [SIP-262](https://higgsbosonhealth.atlassian.net/browse/SIP-262) |
| sip-qa-bruno-builder | [SIP-263](https://higgsbosonhealth.atlassian.net/browse/SIP-263) |
| sip-qa-bug-retest | [SIP-264](https://higgsbosonhealth.atlassian.net/browse/SIP-264) |
| SIP_EHR_Context.md | [SIP-265](https://higgsbosonhealth.atlassian.net/browse/SIP-265) |

## How to change a skill
1. New branch -> edit -> commit -> push.
2. Open a pull request on GitHub, add a reviewer.
3. After approval: merge, re-zip the skill into `dist/`, attach the zip to its Jira sub-task with a comment "v<N> - what changed".
