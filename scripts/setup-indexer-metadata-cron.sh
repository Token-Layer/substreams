#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ -f ./.env.shared.sink ]]; then
  # shellcheck disable=SC1091
  source ./.env.shared.sink
fi

if [[ -z "${DATABASE_URL:-}" && -n "${DATABASE_URL_BASE:-}" ]]; then
  DATABASE_URL="$DATABASE_URL_BASE"
fi

: "${DATABASE_URL:?Set DATABASE_URL or DATABASE_URL_BASE in env}"

SUPABASE_BASE_URL="${SUPABASE_URL:-${SB_URL:-}}"
: "${SUPABASE_BASE_URL:?Set SUPABASE_URL (or SB_URL) in env}"

if ! command -v psql >/dev/null 2>&1; then
  echo "psql is required." >&2
  exit 1
fi

JOB_NAME="${INDEXER_METADATA_CRON_JOB_NAME:-indexer-token-metadata-every-minute}"
JOB_LIMIT="${INDEXER_METADATA_CRON_LIMIT:-25}"
WORKER_TOKEN="${INDEXER_METADATA_WORKER_TOKEN:-}"
FUNC_URL="${SUPABASE_BASE_URL%/}/functions/v1/indexer-token-metadata"

# psql does not understand schemaName query param.
PSQL_DSN="$(echo "$DATABASE_URL" | sed -E 's/[?&]schemaName=[^&]*//g; s/[?&]$//')"

psql "$PSQL_DSN" \
  -v ON_ERROR_STOP=1 \
  -v job_name="$JOB_NAME" \
  -v func_url="$FUNC_URL" \
  -v worker_token="$WORKER_TOKEN" \
  -v job_limit="$JOB_LIMIT" <<'SQL'
CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS pg_net;

SELECT cron.unschedule(jobid)
FROM cron.job
WHERE jobname = :'job_name';

WITH headers AS (
  SELECT CASE
    WHEN :'worker_token' = '' THEN jsonb_build_object(
      'Content-Type', 'application/json'
    )
    ELSE jsonb_build_object(
      'Content-Type', 'application/json',
      'x-worker-token', :'worker_token'
    )
  END AS v
), body AS (
  SELECT jsonb_build_object('limit', (:'job_limit')::int) AS v
)
SELECT cron.schedule(
  :'job_name',
  '* * * * *',
  format(
    $$SELECT net.http_post(url := %L, headers := %L::jsonb, body := %L::jsonb);$$,
    :'func_url',
    (SELECT v::text FROM headers),
    (SELECT v::text FROM body)
  )
);

SELECT jobid, jobname, schedule, command
FROM cron.job
WHERE jobname = :'job_name';
SQL
