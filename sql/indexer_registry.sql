CREATE SCHEMA IF NOT EXISTS indexer;

CREATE TABLE IF NOT EXISTS indexer.indexer_chains (
  chain TEXT PRIMARY KEY,
  schema_name TEXT NOT NULL UNIQUE,
  chain_type TEXT NOT NULL CHECK (chain_type IN ('evm', 'solana')),
  enabled BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 1000,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_indexer_chains_enabled_sort
  ON indexer.indexer_chains (enabled, sort_order, chain);

CREATE OR REPLACE FUNCTION indexer.register_indexer_chain(
  p_chain TEXT,
  p_schema_name TEXT,
  p_chain_type TEXT,
  p_enabled BOOLEAN DEFAULT TRUE,
  p_sort_order INTEGER DEFAULT 1000,
  p_metadata JSONB DEFAULT '{}'::jsonb
) RETURNS indexer.indexer_chains
LANGUAGE plpgsql
AS $$
DECLARE
  v_row indexer.indexer_chains;
BEGIN
  INSERT INTO indexer.indexer_chains (
    chain,
    schema_name,
    chain_type,
    enabled,
    sort_order,
    metadata
  )
  VALUES (
    p_chain,
    p_schema_name,
    p_chain_type,
    p_enabled,
    p_sort_order,
    COALESCE(p_metadata, '{}'::jsonb)
  )
  ON CONFLICT (chain) DO UPDATE
  SET schema_name = EXCLUDED.schema_name,
      chain_type = EXCLUDED.chain_type,
      enabled = EXCLUDED.enabled,
      sort_order = EXCLUDED.sort_order,
      metadata = EXCLUDED.metadata,
      updated_at = now()
  RETURNING * INTO v_row;

  RETURN v_row;
END;
$$;

CREATE OR REPLACE FUNCTION indexer.disable_indexer_chain(p_chain TEXT)
RETURNS VOID
LANGUAGE sql
AS $$
  UPDATE indexer.indexer_chains
  SET enabled = FALSE,
      updated_at = now()
  WHERE chain = p_chain;
$$;

REVOKE ALL ON TABLE indexer.indexer_chains FROM anon;
REVOKE ALL ON TABLE indexer.indexer_chains FROM authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE indexer.indexer_chains TO service_role;

REVOKE ALL ON FUNCTION indexer.register_indexer_chain(TEXT, TEXT, TEXT, BOOLEAN, INTEGER, JSONB) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION indexer.register_indexer_chain(TEXT, TEXT, TEXT, BOOLEAN, INTEGER, JSONB) TO service_role;

REVOKE ALL ON FUNCTION indexer.disable_indexer_chain(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION indexer.disable_indexer_chain(TEXT) TO service_role;
