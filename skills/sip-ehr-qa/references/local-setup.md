# Local setup and one-line commands

Replace `<REPO>` with your sip-server folder (e.g. `~/Desktop/SIP/sip-server`) and `<RESULTS>` with your results folder (e.g. `~/Desktop/SIP/qa-results`). All commands are ONE line.

## Apps and URLs (local)
| App | URL |
|---|---|
| SIP web | http://localhost:8080 |
| SIP API | http://localhost:3000 |
| Event store browser (published events) | http://localhost:3000/res |
| DB UI (adminer) | see docker-compose |
| OpenEMR (if used) | https://localhost:9300 |

## Start / check
- Start app: `cd <REPO> && docker compose -f docker-compose.yml -f docker-compose.app.yml up -d`
- Check containers: `cd <REPO> && docker compose -f docker-compose.yml -f docker-compose.app.yml ps`
- Worker not Up after a restart: `cd <REPO> && docker compose -f docker-compose.yml -f docker-compose.app.yml up -d solid-queue-worker`
- Restore EHR feeds + physician mapping + code maps: `cd <REPO> && docker compose -f docker-compose.yml -f docker-compose.app.yml exec -T rails bin/rails data:populate_ehr_feeds`
- Map a physician: `cd <REPO> && docker compose -f docker-compose.yml -f docker-compose.app.yml exec -T rails bin/rails ehr:map_physician PHYSICIAN_EMAIL=<email> EHR_PROVIDER_ID=<id>`

## Bruno
- Run a folder: `cd <REPO>/Bruno && ./node_modules/.bin/bru run "QA EHR/<folder>" -r --env Local --reporter-json <RESULTS>/<name>.json`
- Run one file with values from an earlier run: `cd <REPO>/Bruno && ./node_modules/.bin/bru run "QA EHR/<folder>/<file>.yml" --env Local --env-var KEY=value`
- Use the repo CLI (`./node_modules/.bin/bru`), not a global one. Without `-r` a folder runs 0 requests.

## DB check
- Run a sql file: `cd <REPO> && docker compose exec -T mysql_db mysql -uroot -p"$(grep '^DB_PASSWORD=' .env | cut -d= -f2)" --default-character-set=utf8mb4 sip_dev < "<path>/care_check.sql" > <RESULTS>/db.txt 2>&1`
- zsh: always quote `'^DB_PASSWORD='` (unquoted `^` breaks it -> "Access denied").
- Solid Queue tables are in the `sip_dev_queue` database.

## Worker log
- Save last 30 min: `cd <REPO> && docker compose -f docker-compose.yml -f docker-compose.app.yml logs --since 30m solid-queue-worker 2>&1 | grep -i "ehr.run\|ignored\|failed\|error" > <RESULTS>/worker.txt`
- Look for: `ehr.run message_id=<id> outcome=<status> stage=<stage> error_code=<code>`, `ignored <reason>`, `IntegrationEventJob::Failed (<reason>)`.

## Feed on / off (TC16 style) - always switch back on in the same line
`cd <REPO> && docker compose -f docker-compose.yml -f docker-compose.app.yml exec -T rails bin/rails runner 'Integration::Ehr::Feed.find_by!(code: "<feed_code>").update!(enabled: false); puts "FEED OFF"'; <send test here>; docker compose -f docker-compose.yml -f docker-compose.app.yml exec -T rails bin/rails runner 'Integration::Ehr::Feed.find_by!(code: "<feed_code>").update!(enabled: true); puts "FEED ON"'`

## Common problems
| You see | Why | Fix |
|---|---|---|
| Bruno: 0 requests | folder run without `-r` / wrong CLI | use `./node_modules/.bin/bru ... -r` |
| mysql: Access denied | zsh ate `^` | quote `'^DB_PASSWORD='` |
| Messages stay `received` | worker down | start solid-queue-worker |
| Care patient not created / case unassigned | seed missing feeds or physician mapping | `data:populate_ehr_feeds` |
| `unsupported_event` on FHIR | X-Ehr-Event-Type not in feed `allowed_events` | use an allowed type or update feed settings |
| `unexpected_error` | unhandled error (check `error_detail`) | likely bug - collect message id + log line |
| "Unknown ruby interpreter version" | local Mac warning | ignore |
