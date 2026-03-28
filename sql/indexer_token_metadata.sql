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
  banner_url TEXT,
  name TEXT,
  symbol TEXT,
  description TEXT,
  created_on TEXT,
  addresses JSONB,
  token_layer_id TEXT,
  tags TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
  token TEXT,
  website TEXT,
  twitter_url TEXT,
  discord_url TEXT,
  telegram_url TEXT,
  farcaster_url TEXT,
  github_url TEXT,
  socials JSONB,
  attributes JSONB,
  raw_json JSONB NOT NULL,
  content_sha256 TEXT,
  fetched_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  immutable BOOLEAN NOT NULL DEFAULT true
);

ALTER TABLE indexer.token_metadata
  ADD COLUMN IF NOT EXISTS banner_url TEXT,
  ADD COLUMN IF NOT EXISTS twitter_url TEXT,
  ADD COLUMN IF NOT EXISTS discord_url TEXT,
  ADD COLUMN IF NOT EXISTS telegram_url TEXT,
  ADD COLUMN IF NOT EXISTS farcaster_url TEXT,
  ADD COLUMN IF NOT EXISTS github_url TEXT,
  ADD COLUMN IF NOT EXISTS socials JSONB;

UPDATE indexer.token_metadata
SET banner_url = COALESCE(raw_json->>'banner', raw_json->>'banner_url'),
    created_on = CASE
      WHEN COALESCE(raw_json->>'createdOn', '') ~* '^https?://' THEN NULL
      ELSE COALESCE(raw_json->>'createdOn', created_on)
    END,
    tags = COALESCE(ARRAY(
      SELECT DISTINCT NULLIF(regexp_replace(lower(value), '^#+', ''), '')
      FROM unnest(COALESCE(tags, ARRAY[]::TEXT[])) AS value
      WHERE NULLIF(regexp_replace(lower(value), '^#+', ''), '') IS NOT NULL
    ), ARRAY[]::TEXT[]),
    twitter_url = COALESCE(
      raw_json->>'twitter',
      raw_json->>'twitter_url',
      raw_json->>'x',
      raw_json->>'x_url',
      raw_json->'socials'->>'twitter',
      raw_json->'socials'->>'x',
      twitter_url
    ),
    discord_url = COALESCE(
      raw_json->>'discord',
      raw_json->>'discord_url',
      raw_json->'socials'->>'discord',
      discord_url
    ),
    telegram_url = COALESCE(
      raw_json->>'telegram',
      raw_json->>'telegram_url',
      raw_json->'socials'->>'telegram',
      telegram_url
    ),
    farcaster_url = COALESCE(
      raw_json->>'farcaster',
      raw_json->>'farcaster_url',
      raw_json->'socials'->>'farcaster',
      farcaster_url
    ),
    github_url = COALESCE(
      raw_json->>'github',
      raw_json->>'github_url',
      raw_json->'socials'->>'github',
      github_url
    ),
    socials = NULLIF(jsonb_strip_nulls(jsonb_build_object(
      'twitter', COALESCE(
        raw_json->>'twitter',
        raw_json->>'twitter_url',
        raw_json->>'x',
        raw_json->>'x_url',
        raw_json->'socials'->>'twitter',
        raw_json->'socials'->>'x',
        twitter_url
      ),
      'discord', COALESCE(
        raw_json->>'discord',
        raw_json->>'discord_url',
        raw_json->'socials'->>'discord',
        discord_url
      ),
      'telegram', COALESCE(
        raw_json->>'telegram',
        raw_json->>'telegram_url',
        raw_json->'socials'->>'telegram',
        telegram_url
      ),
      'farcaster', COALESCE(
        raw_json->>'farcaster',
        raw_json->>'farcaster_url',
        raw_json->'socials'->>'farcaster',
        farcaster_url
      ),
      'github', COALESCE(
        raw_json->>'github',
        raw_json->>'github_url',
        raw_json->'socials'->>'github',
        github_url
      )
    )), '{}'::jsonb);

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

CREATE OR REPLACE FUNCTION public.sync_token_uri_sources()
RETURNS TABLE(inserted_sources BIGINT, inserted_jobs BIGINT)
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT * FROM indexer.sync_token_uri_sources();
$$;

CREATE OR REPLACE FUNCTION public.claim_token_metadata_jobs(p_limit INTEGER DEFAULT 20)
RETURNS TABLE(token_uri TEXT, attempts INTEGER, max_attempts INTEGER)
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT * FROM indexer.claim_token_metadata_jobs(p_limit);
$$;

CREATE OR REPLACE FUNCTION public.token_metadata_exists(p_token_uri TEXT)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT EXISTS(
    SELECT 1
    FROM indexer.token_metadata m
    WHERE m.token_uri = p_token_uri
  );
$$;

CREATE OR REPLACE FUNCTION public.mark_token_metadata_job_done(p_token_uri TEXT)
RETURNS VOID
LANGUAGE sql
SECURITY DEFINER
AS $$
  UPDATE indexer.token_metadata_jobs
  SET status = 'done',
      processed_at = now(),
      next_retry_at = NULL,
      last_error = NULL,
      updated_at = now()
  WHERE token_uri = p_token_uri;
$$;

CREATE OR REPLACE FUNCTION public.mark_token_metadata_job_failed(
  p_token_uri TEXT,
  p_error_message TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_attempts INTEGER := 0;
  v_max_attempts INTEGER := 3;
  v_next_attempts INTEGER := 1;
  v_reached_max BOOLEAN := FALSE;
  v_retry_at TIMESTAMPTZ := NULL;
BEGIN
  SELECT attempts, max_attempts
  INTO v_attempts, v_max_attempts
  FROM indexer.token_metadata_jobs
  WHERE token_uri = p_token_uri;

  v_next_attempts := COALESCE(v_attempts, 0) + 1;
  v_reached_max := v_next_attempts >= COALESCE(v_max_attempts, 3);

  IF NOT v_reached_max THEN
    v_retry_at := now() + make_interval(secs => v_next_attempts * 60);
  END IF;

  UPDATE indexer.token_metadata_jobs
  SET status = CASE WHEN v_reached_max THEN 'error' ELSE 'pending' END,
      attempts = v_next_attempts,
      next_retry_at = v_retry_at,
      last_error = LEFT(COALESCE(p_error_message, ''), 4000),
      updated_at = now()
  WHERE token_uri = p_token_uri;
END;
$$;

CREATE OR REPLACE FUNCTION public.upsert_token_metadata(
  p_token_uri TEXT,
  p_resolved_metadata_url TEXT,
  p_image_url TEXT,
  p_image_storage_path TEXT,
  p_image_storage_url TEXT,
  p_banner_url TEXT,
  p_name TEXT,
  p_symbol TEXT,
  p_description TEXT,
  p_created_on TEXT,
  p_addresses JSONB,
  p_token_layer_id TEXT,
  p_tags TEXT[],
  p_token TEXT,
  p_website TEXT,
  p_twitter_url TEXT,
  p_discord_url TEXT,
  p_telegram_url TEXT,
  p_farcaster_url TEXT,
  p_github_url TEXT,
  p_socials JSONB,
  p_attributes JSONB,
  p_raw_json JSONB,
  p_content_sha256 TEXT,
  p_immutable BOOLEAN DEFAULT TRUE
)
RETURNS VOID
LANGUAGE sql
SECURITY DEFINER
AS $$
  INSERT INTO indexer.token_metadata (
    token_uri,
    resolved_metadata_url,
    image_url,
    image_storage_path,
    image_storage_url,
    banner_url,
    name,
    symbol,
    description,
    created_on,
    addresses,
    token_layer_id,
    tags,
    token,
    website,
    twitter_url,
    discord_url,
    telegram_url,
    farcaster_url,
    github_url,
    socials,
    attributes,
    raw_json,
    content_sha256,
    fetched_at,
    immutable
  )
  VALUES (
    p_token_uri,
    p_resolved_metadata_url,
    p_image_url,
    p_image_storage_path,
    p_image_storage_url,
    p_banner_url,
    p_name,
    p_symbol,
    p_description,
    p_created_on,
    p_addresses,
    p_token_layer_id,
    COALESCE(p_tags, ARRAY[]::TEXT[]),
    p_token,
    p_website,
    p_twitter_url,
    p_discord_url,
    p_telegram_url,
    p_farcaster_url,
    p_github_url,
    p_socials,
    p_attributes,
    p_raw_json,
    p_content_sha256,
    now(),
    COALESCE(p_immutable, TRUE)
  )
  ON CONFLICT (token_uri) DO UPDATE
  SET resolved_metadata_url = EXCLUDED.resolved_metadata_url,
      image_url = EXCLUDED.image_url,
      image_storage_path = EXCLUDED.image_storage_path,
      image_storage_url = EXCLUDED.image_storage_url,
      banner_url = EXCLUDED.banner_url,
      name = EXCLUDED.name,
      symbol = EXCLUDED.symbol,
      description = EXCLUDED.description,
      created_on = EXCLUDED.created_on,
      addresses = EXCLUDED.addresses,
      token_layer_id = EXCLUDED.token_layer_id,
      tags = EXCLUDED.tags,
      token = EXCLUDED.token,
      website = EXCLUDED.website,
      twitter_url = EXCLUDED.twitter_url,
      discord_url = EXCLUDED.discord_url,
      telegram_url = EXCLUDED.telegram_url,
      farcaster_url = EXCLUDED.farcaster_url,
      github_url = EXCLUDED.github_url,
      socials = EXCLUDED.socials,
      attributes = EXCLUDED.attributes,
      raw_json = EXCLUDED.raw_json,
      content_sha256 = EXCLUDED.content_sha256,
      fetched_at = EXCLUDED.fetched_at,
      immutable = EXCLUDED.immutable;
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

REVOKE ALL ON FUNCTION public.sync_token_uri_sources() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.sync_token_uri_sources() TO service_role;

REVOKE ALL ON FUNCTION public.claim_token_metadata_jobs(INTEGER) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.claim_token_metadata_jobs(INTEGER) TO service_role;

REVOKE ALL ON FUNCTION public.token_metadata_exists(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.token_metadata_exists(TEXT) TO service_role;

REVOKE ALL ON FUNCTION public.mark_token_metadata_job_done(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.mark_token_metadata_job_done(TEXT) TO service_role;

REVOKE ALL ON FUNCTION public.mark_token_metadata_job_failed(TEXT, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.mark_token_metadata_job_failed(TEXT, TEXT) TO service_role;

REVOKE ALL ON FUNCTION public.upsert_token_metadata(
  TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, JSONB, TEXT, TEXT[], TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, JSONB, JSONB, JSONB, TEXT, BOOLEAN
) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.upsert_token_metadata(
  TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, JSONB, TEXT, TEXT[], TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, JSONB, JSONB, JSONB, TEXT, BOOLEAN
) TO service_role;
