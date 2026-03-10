DO $$
DECLARE
  s TEXT;
BEGIN
  FOREACH s IN ARRAY ARRAY['indexer_evm_base_sepolia', 'indexer_evm_bnb_testnet']
  LOOP
    IF to_regclass(format('%I.%I', s, 'agg_token_trade')) IS NULL THEN
      CONTINUE;
    END IF;

    EXECUTE format($q$
      ALTER TABLE %I.agg_token_trade
      ADD COLUMN IF NOT EXISTS token_layer_id TEXT
    $q$, s);

    EXECUTE format($q$
      WITH addr_map AS (
        SELECT
          lower(src.token_address) AS token_address,
          max(src.token_id) AS token_layer_id
        FROM (
          SELECT token_address, token_id FROM %I.raw_registry_token_created
          UNION ALL
          SELECT token_address, token_id FROM %I.raw_registry_token_registered
          UNION ALL
          SELECT token_address, token_id FROM %I.raw_registry_external_token_created
        ) src
        WHERE src.token_address IS NOT NULL
          AND btrim(src.token_address) <> ''
          AND src.token_id IS NOT NULL
          AND btrim(src.token_id) <> ''
        GROUP BY 1
      )
      UPDATE %I.agg_token_trade t
      SET token_layer_id = m.token_layer_id
      FROM addr_map m
      WHERE lower(t.token_address) = m.token_address
        AND (t.token_layer_id IS NULL OR btrim(t.token_layer_id) = '')
    $q$, s, s, s, s);

    EXECUTE format($q$
      CREATE INDEX IF NOT EXISTS idx_agg_token_trade_token_layer_id
      ON %I.agg_token_trade (token_layer_id)
    $q$, s);
  END LOOP;
END $$;
