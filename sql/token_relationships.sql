-- Ensure canonical token relationships exist across all token-bearing tables
-- in the current schema (set by setup script search_path).

CREATE TABLE IF NOT EXISTS "dim_token" (
  "token_layer_id" TEXT PRIMARY KEY,
  "token_address" TEXT,
  "name" TEXT,
  "symbol" TEXT,
  "decimals" NUMERIC,
  "token_uri" TEXT,
  "source_event" TEXT,
  "created_evt_block_number" NUMERIC,
  "created_evt_block_time" TIMESTAMP,
  "updated_evt_block_number" NUMERIC,
  "updated_evt_block_time" TIMESTAMP
);

DO $$
DECLARE
  rec RECORD;
  cname TEXT;
BEGIN
  -- Recreate deterministically in case prior setup created only a subset.
  FOR rec IN
    SELECT conname, conrelid::regclass AS relname
    FROM pg_constraint c
    JOIN pg_namespace n ON n.oid = c.connamespace
    WHERE n.nspname = current_schema()
      AND (conname LIKE 'fk_tlid_%' OR conname LIKE 'fk_tid_%')
  LOOP
    EXECUTE format('ALTER TABLE %s DROP CONSTRAINT IF EXISTS %I', rec.relname, rec.conname);
  END LOOP;

  FOR rec IN
    SELECT
      c.table_name,
      bool_or(c.column_name = 'token_layer_id') AS has_token_layer_id,
      bool_or(c.column_name = 'token_id') AS has_token_id,
      bool_or(c.column_name = 'token_address') AS has_token_address,
      bool_or(c.column_name = 'key_id') AS has_key_id
    FROM information_schema.columns c
    JOIN information_schema.tables t
      ON t.table_schema = c.table_schema
     AND t.table_name = c.table_name
    WHERE c.table_schema = current_schema()
      AND t.table_type = 'BASE TABLE'
      AND c.table_name <> 'dim_token'
      AND c.column_name IN ('token_layer_id', 'token_id', 'token_address', 'key_id')
    GROUP BY c.table_name
  LOOP
    -- LiquidityManager key_id is protocol token key (token_layer_id).
    IF rec.table_name LIKE 'raw_liquidity_mananager_%' AND rec.has_key_id AND NOT rec.has_token_layer_id THEN
      EXECUTE format('ALTER TABLE %I ADD COLUMN IF NOT EXISTS token_layer_id TEXT', rec.table_name);
      rec.has_token_layer_id := true;
    END IF;

    IF rec.table_name LIKE 'raw_liquidity_mananager_%' AND rec.has_key_id AND rec.has_token_layer_id THEN
      EXECUTE format($q$
        UPDATE %I
        SET token_layer_id = key_id
        WHERE (token_layer_id IS NULL OR token_layer_id = '')
          AND key_id IS NOT NULL
          AND key_id <> ''
      $q$, rec.table_name);
    END IF;

    -- Fill missing token_layer_id by token_address mapping whenever possible.
    IF rec.has_token_layer_id AND rec.has_token_address THEN
      EXECUTE format($q$
        UPDATE %I t
        SET token_layer_id = d.token_layer_id
        FROM dim_token d
        WHERE (t.token_layer_id IS NULL OR t.token_layer_id = '')
          AND t.token_address IS NOT NULL
          AND lower(t.token_address) = lower(d.token_address)
      $q$, rec.table_name);
    END IF;

    IF rec.has_token_layer_id THEN
      cname := 'fk_tlid_' || substr(md5(rec.table_name), 1, 10);
      EXECUTE format(
        'ALTER TABLE %I ADD CONSTRAINT %I FOREIGN KEY (token_layer_id) REFERENCES dim_token(token_layer_id) DEFERRABLE INITIALLY DEFERRED NOT VALID',
        rec.table_name, cname
      );
    END IF;

    -- LiquidityManager token_id is Uniswap position NFT id, not token_layer_id.
    IF rec.has_token_id AND rec.table_name NOT LIKE 'raw_liquidity_mananager_%' THEN
      cname := 'fk_tid_' || substr(md5(rec.table_name), 1, 10);
      EXECUTE format(
        'ALTER TABLE %I ADD CONSTRAINT %I FOREIGN KEY (token_id) REFERENCES dim_token(token_layer_id) DEFERRABLE INITIALLY DEFERRED NOT VALID',
        rec.table_name, cname
      );
    END IF;
  END LOOP;
END $$;
