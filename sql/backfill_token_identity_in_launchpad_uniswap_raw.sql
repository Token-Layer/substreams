DO $$
DECLARE
  s TEXT;
BEGIN
  FOREACH s IN ARRAY ARRAY['indexer_evm_base_sepolia', 'indexer_evm_bnb_testnet']
  LOOP
    -- Launchpad buy/sell: add token_address by token_id map.
    IF to_regclass(format('%I.%I', s, 'raw_launchpad_buy')) IS NOT NULL THEN
      EXECUTE format('ALTER TABLE %I.raw_launchpad_buy ADD COLUMN IF NOT EXISTS token_address TEXT', s);
      EXECUTE format($q$
        WITH id_map AS (
          SELECT lower(src.token_id) AS token_id, max(lower(src.token_address)) AS token_address
          FROM (
            SELECT token_id, token_address FROM %I.raw_registry_token_created
            UNION ALL
            SELECT token_id, token_address FROM %I.raw_registry_token_registered
            UNION ALL
            SELECT token_id, token_address FROM %I.raw_registry_external_token_created
          ) src
          WHERE src.token_id IS NOT NULL AND btrim(src.token_id) <> ''
            AND src.token_address IS NOT NULL AND btrim(src.token_address) <> ''
          GROUP BY 1
        )
        UPDATE %I.raw_launchpad_buy b
        SET token_address = m.token_address
        FROM id_map m
        WHERE lower(b.token_id) = m.token_id
          AND (b.token_address IS NULL OR btrim(b.token_address) = '')
      $q$, s, s, s, s);
      EXECUTE format('CREATE INDEX IF NOT EXISTS idx_launchpad_buy_token_address ON %I.raw_launchpad_buy (token_address)', s);
    END IF;

    IF to_regclass(format('%I.%I', s, 'raw_launchpad_sell')) IS NOT NULL THEN
      EXECUTE format('ALTER TABLE %I.raw_launchpad_sell ADD COLUMN IF NOT EXISTS token_address TEXT', s);
      EXECUTE format($q$
        WITH id_map AS (
          SELECT lower(src.token_id) AS token_id, max(lower(src.token_address)) AS token_address
          FROM (
            SELECT token_id, token_address FROM %I.raw_registry_token_created
            UNION ALL
            SELECT token_id, token_address FROM %I.raw_registry_token_registered
            UNION ALL
            SELECT token_id, token_address FROM %I.raw_registry_external_token_created
          ) src
          WHERE src.token_id IS NOT NULL AND btrim(src.token_id) <> ''
            AND src.token_address IS NOT NULL AND btrim(src.token_address) <> ''
          GROUP BY 1
        )
        UPDATE %I.raw_launchpad_sell b
        SET token_address = m.token_address
        FROM id_map m
        WHERE lower(b.token_id) = m.token_id
          AND (b.token_address IS NULL OR btrim(b.token_address) = '')
      $q$, s, s, s, s);
      EXECUTE format('CREATE INDEX IF NOT EXISTS idx_launchpad_sell_token_address ON %I.raw_launchpad_sell (token_address)', s);
    END IF;

    -- Uniswap: derive tracked token address/token_layer_id from pool metadata.
    IF to_regclass(format('%I.%I', s, 'raw_uniswap_v3_pool_created')) IS NOT NULL THEN
      EXECUTE format('ALTER TABLE %I.raw_uniswap_v3_pool_created ADD COLUMN IF NOT EXISTS token_address TEXT', s);
      EXECUTE format('ALTER TABLE %I.raw_uniswap_v3_pool_created ADD COLUMN IF NOT EXISTS token_layer_id TEXT', s);
      EXECUTE format($q$
        WITH addr_map AS (
          SELECT lower(src.token_address) AS token_address, max(src.token_id) AS token_layer_id
          FROM (
            SELECT token_address, token_id FROM %I.raw_registry_token_created
            UNION ALL
            SELECT token_address, token_id FROM %I.raw_registry_token_registered
            UNION ALL
            SELECT token_address, token_id FROM %I.raw_registry_external_token_created
          ) src
          WHERE src.token_address IS NOT NULL AND btrim(src.token_address) <> ''
            AND src.token_id IS NOT NULL AND btrim(src.token_id) <> ''
          GROUP BY 1
        )
        UPDATE %I.raw_uniswap_v3_pool_created p
        SET token_address = COALESCE(
              (SELECT m.token_address FROM addr_map m WHERE m.token_address = lower(p.token0) LIMIT 1),
              (SELECT m.token_address FROM addr_map m WHERE m.token_address = lower(p.token1) LIMIT 1),
              p.token_address
            ),
            token_layer_id = COALESCE(
              (SELECT m.token_layer_id FROM addr_map m WHERE m.token_address = lower(p.token0) LIMIT 1),
              (SELECT m.token_layer_id FROM addr_map m WHERE m.token_address = lower(p.token1) LIMIT 1),
              p.token_layer_id
            )
      $q$, s, s, s, s);
      EXECUTE format('CREATE INDEX IF NOT EXISTS idx_uniswapv3_poolcreated_token_address ON %I.raw_uniswap_v3_pool_created (token_address)', s);
      EXECUTE format('CREATE INDEX IF NOT EXISTS idx_uniswapv3_poolcreated_token_layer_id ON %I.raw_uniswap_v3_pool_created (token_layer_id)', s);
    END IF;

    IF to_regclass(format('%I.%I', s, 'raw_uniswap_v3_swap')) IS NOT NULL
       AND to_regclass(format('%I.%I', s, 'raw_uniswap_v3_pool_created')) IS NOT NULL THEN
      EXECUTE format('ALTER TABLE %I.raw_uniswap_v3_swap ADD COLUMN IF NOT EXISTS token_address TEXT', s);
      EXECUTE format('ALTER TABLE %I.raw_uniswap_v3_swap ADD COLUMN IF NOT EXISTS token_layer_id TEXT', s);
      EXECUTE format($q$
        UPDATE %I.raw_uniswap_v3_swap sw
        SET token_address = pc.token_address,
            token_layer_id = pc.token_layer_id
        FROM %I.raw_uniswap_v3_pool_created pc
        WHERE lower(sw.pool) = lower(pc.pool)
          AND (
            sw.token_address IS DISTINCT FROM pc.token_address
            OR sw.token_layer_id IS DISTINCT FROM pc.token_layer_id
          )
      $q$, s, s);
      EXECUTE format('CREATE INDEX IF NOT EXISTS idx_uniswapv3_swap_token_address ON %I.raw_uniswap_v3_swap (token_address)', s);
      EXECUTE format('CREATE INDEX IF NOT EXISTS idx_uniswapv3_swap_token_layer_id ON %I.raw_uniswap_v3_swap (token_layer_id)', s);
    END IF;
  END LOOP;
END $$;
