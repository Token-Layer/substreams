CREATE SCHEMA IF NOT EXISTS indexer;
GRANT USAGE ON SCHEMA indexer TO service_role;

CREATE TABLE IF NOT EXISTS indexer.token_uri_sources (
  id BIGSERIAL PRIMARY KEY,
  chain TEXT NOT NULL,
  source_event TEXT NOT NULL,
  token_id TEXT,
  token_address TEXT,
  token_uri TEXT NOT NULL,
  evt_block_number NUMERIC,
  evt_block_time TIMESTAMP,
  evt_tx_hash TEXT,
  evt_index NUMERIC,
  first_seen_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (chain, source_event, token_id, token_address, token_uri)
);

CREATE INDEX IF NOT EXISTS idx_token_uri_sources_token_uri
  ON indexer.token_uri_sources (token_uri);
CREATE INDEX IF NOT EXISTS idx_token_uri_sources_chain
  ON indexer.token_uri_sources (chain);
CREATE INDEX IF NOT EXISTS idx_token_uri_sources_token_id
  ON indexer.token_uri_sources (token_id);
CREATE INDEX IF NOT EXISTS idx_token_uri_sources_token_address
  ON indexer.token_uri_sources (token_address);

CREATE TABLE IF NOT EXISTS indexer.token_metadata_jobs (
  token_uri TEXT PRIMARY KEY,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'done', 'error')),
  attempts INTEGER NOT NULL DEFAULT 0,
  max_attempts INTEGER NOT NULL DEFAULT 3,
  next_retry_at TIMESTAMPTZ,
  last_error TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  processed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_token_metadata_jobs_status_retry
  ON indexer.token_metadata_jobs (status, next_retry_at, updated_at);

CREATE TABLE IF NOT EXISTS indexer.token_metadata (
  token_uri TEXT PRIMARY KEY,
  resolved_metadata_url TEXT,
  image_url TEXT,
  image_storage_path TEXT,
  image_storage_url TEXT,
  name TEXT,
  symbol TEXT,
  description TEXT,
  created_on TEXT,
  addresses JSONB,
  token_layer_id TEXT,
  tags TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
  token TEXT,
  website TEXT,
  attributes JSONB,
  raw_json JSONB NOT NULL,
  content_sha256 TEXT,
  fetched_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  immutable BOOLEAN NOT NULL DEFAULT true
);

CREATE INDEX IF NOT EXISTS idx_token_metadata_token_layer_id
  ON indexer.token_metadata (token_layer_id);
CREATE INDEX IF NOT EXISTS idx_token_metadata_tags_gin
  ON indexer.token_metadata USING GIN (tags);

CREATE OR REPLACE FUNCTION indexer.sync_token_uri_sources()
RETURNS TABLE(inserted_sources BIGINT, inserted_jobs BIGINT)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_sources BIGINT := 0;
  v_jobs BIGINT := 0;
BEGIN
  WITH ins AS (
    INSERT INTO indexer.token_uri_sources (
      chain, source_event, token_id, token_address, token_uri,
      evt_block_number, evt_block_time, evt_tx_hash, evt_index
    )
    SELECT
      v.chain,
      v.source_event,
      v.token_id,
      lower(v.token_address),
      v.token_uri,
      v.evt_block_number,
      v.evt_block_time,
      v.evt_tx_hash,
      v.evt_index
    FROM indexer.vw_tokens_created v
    WHERE v.token_uri IS NOT NULL
      AND btrim(v.token_uri) <> ''
    ON CONFLICT (chain, source_event, token_id, token_address, token_uri) DO NOTHING
    RETURNING 1
  )
  SELECT COUNT(*) INTO v_sources FROM ins;

  WITH ins AS (
    INSERT INTO indexer.token_metadata_jobs (token_uri, status, attempts, max_attempts)
    SELECT DISTINCT s.token_uri, 'pending', 0, 3
    FROM indexer.token_uri_sources s
    LEFT JOIN indexer.token_metadata m ON m.token_uri = s.token_uri
    LEFT JOIN indexer.token_metadata_jobs j ON j.token_uri = s.token_uri
    WHERE m.token_uri IS NULL
      AND j.token_uri IS NULL
    ON CONFLICT (token_uri) DO NOTHING
    RETURNING 1
  )
  SELECT COUNT(*) INTO v_jobs FROM ins;

  RETURN QUERY SELECT v_sources, v_jobs;
END;
$$;

CREATE OR REPLACE FUNCTION indexer.claim_token_metadata_jobs(p_limit INTEGER DEFAULT 20)
RETURNS TABLE(token_uri TEXT, attempts INTEGER, max_attempts INTEGER)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  WITH picked AS (
    SELECT j.token_uri
    FROM indexer.token_metadata_jobs j
    WHERE j.status IN ('pending', 'error')
      AND j.attempts < j.max_attempts
      AND (j.next_retry_at IS NULL OR j.next_retry_at <= now())
    ORDER BY j.updated_at ASC
    LIMIT p_limit
    FOR UPDATE SKIP LOCKED
  ), upd AS (
    UPDATE indexer.token_metadata_jobs j
    SET status = 'processing',
        updated_at = now(),
        last_error = NULL
    FROM picked p
    WHERE j.token_uri = p.token_uri
    RETURNING j.token_uri, j.attempts, j.max_attempts
  )
  SELECT u.token_uri, u.attempts, u.max_attempts
  FROM upd u;
END;
$$;

CREATE OR REPLACE VIEW indexer.vw_token_metadata_job_status AS
SELECT
  j.token_uri,
  j.status,
  j.attempts,
  j.max_attempts,
  j.next_retry_at,
  j.last_error,
  j.created_at,
  j.updated_at,
  j.processed_at,
  m.fetched_at,
  m.image_storage_url,
  m.tags
FROM indexer.token_metadata_jobs j
LEFT JOIN indexer.token_metadata m ON m.token_uri = j.token_uri;

-- Service-role-only access
REVOKE ALL ON TABLE indexer.token_uri_sources FROM anon;
REVOKE ALL ON TABLE indexer.token_uri_sources FROM authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE indexer.token_uri_sources TO service_role;

REVOKE ALL ON TABLE indexer.token_metadata_jobs FROM anon;
REVOKE ALL ON TABLE indexer.token_metadata_jobs FROM authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE indexer.token_metadata_jobs TO service_role;

REVOKE ALL ON TABLE indexer.token_metadata FROM anon;
REVOKE ALL ON TABLE indexer.token_metadata FROM authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE indexer.token_metadata TO service_role;

REVOKE ALL ON TABLE indexer.vw_token_metadata_job_status FROM anon;
REVOKE ALL ON TABLE indexer.vw_token_metadata_job_status FROM authenticated;
GRANT SELECT ON TABLE indexer.vw_token_metadata_job_status TO service_role;

GRANT USAGE, SELECT ON SEQUENCE indexer.token_uri_sources_id_seq TO service_role;

REVOKE ALL ON FUNCTION indexer.sync_token_uri_sources() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION indexer.sync_token_uri_sources() TO service_role;

REVOKE ALL ON FUNCTION indexer.claim_token_metadata_jobs(INTEGER) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION indexer.claim_token_metadata_jobs(INTEGER) TO service_role;
