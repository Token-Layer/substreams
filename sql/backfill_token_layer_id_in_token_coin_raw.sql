DO $$
DECLARE
  s TEXT;
BEGIN
  FOREACH s IN ARRAY ARRAY['indexer_evm_base_sepolia', 'indexer_evm_bnb_testnet']
  LOOP
    IF to_regclass(format('%I.%I', s, 'raw_token_coin_transfer')) IS NOT NULL THEN
      EXECUTE format('ALTER TABLE %I.raw_token_coin_transfer ADD COLUMN IF NOT EXISTS token_layer_id TEXT', s);
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
        UPDATE %I.raw_token_coin_transfer t
        SET token_layer_id = m.token_layer_id
        FROM addr_map m
        WHERE lower(t.token_address) = m.token_address
          AND (t.token_layer_id IS NULL OR btrim(t.token_layer_id) = '')
      $q$, s, s, s, s);
      EXECUTE format('CREATE INDEX IF NOT EXISTS idx_tokencoin_transfer_token_layer_id ON %I.raw_token_coin_transfer (token_layer_id)', s);
    END IF;

    IF to_regclass(format('%I.%I', s, 'raw_token_coin_oft_sent')) IS NOT NULL THEN
      EXECUTE format('ALTER TABLE %I.raw_token_coin_oft_sent ADD COLUMN IF NOT EXISTS token_layer_id TEXT', s);
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
        UPDATE %I.raw_token_coin_oft_sent t
        SET token_layer_id = m.token_layer_id
        FROM addr_map m
        WHERE lower(t.token_address) = m.token_address
          AND (t.token_layer_id IS NULL OR btrim(t.token_layer_id) = '')
      $q$, s, s, s, s);
      EXECUTE format('CREATE INDEX IF NOT EXISTS idx_tokencoin_oftsent_token_layer_id ON %I.raw_token_coin_oft_sent (token_layer_id)', s);
    END IF;

    IF to_regclass(format('%I.%I', s, 'raw_token_coin_approval')) IS NOT NULL THEN
      EXECUTE format('ALTER TABLE %I.raw_token_coin_approval ADD COLUMN IF NOT EXISTS token_layer_id TEXT', s);
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
        UPDATE %I.raw_token_coin_approval t
        SET token_layer_id = m.token_layer_id
        FROM addr_map m
        WHERE lower(t.token_address) = m.token_address
          AND (t.token_layer_id IS NULL OR btrim(t.token_layer_id) = '')
      $q$, s, s, s, s);
      EXECUTE format('CREATE INDEX IF NOT EXISTS idx_tokencoin_approval_token_layer_id ON %I.raw_token_coin_approval (token_layer_id)', s);
    END IF;

    IF to_regclass(format('%I.%I', s, 'raw_token_coin_enforced_option_set')) IS NOT NULL THEN
      EXECUTE format('ALTER TABLE %I.raw_token_coin_enforced_option_set ADD COLUMN IF NOT EXISTS token_layer_id TEXT', s);
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
        UPDATE %I.raw_token_coin_enforced_option_set t
        SET token_layer_id = m.token_layer_id
        FROM addr_map m
        WHERE lower(t.token_address) = m.token_address
          AND (t.token_layer_id IS NULL OR btrim(t.token_layer_id) = '')
      $q$, s, s, s, s);
      EXECUTE format('CREATE INDEX IF NOT EXISTS idx_tokencoin_enforcedoptset_token_layer_id ON %I.raw_token_coin_enforced_option_set (token_layer_id)', s);
    END IF;

    IF to_regclass(format('%I.%I', s, 'raw_token_coin_initialized')) IS NOT NULL THEN
      EXECUTE format('ALTER TABLE %I.raw_token_coin_initialized ADD COLUMN IF NOT EXISTS token_layer_id TEXT', s);
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
        UPDATE %I.raw_token_coin_initialized t
        SET token_layer_id = m.token_layer_id
        FROM addr_map m
        WHERE lower(t.token_address) = m.token_address
          AND (t.token_layer_id IS NULL OR btrim(t.token_layer_id) = '')
      $q$, s, s, s, s);
      EXECUTE format('CREATE INDEX IF NOT EXISTS idx_tokencoin_initialized_token_layer_id ON %I.raw_token_coin_initialized (token_layer_id)', s);
    END IF;

    IF to_regclass(format('%I.%I', s, 'raw_token_coin_msg_inspector_set')) IS NOT NULL THEN
      EXECUTE format('ALTER TABLE %I.raw_token_coin_msg_inspector_set ADD COLUMN IF NOT EXISTS token_layer_id TEXT', s);
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
        UPDATE %I.raw_token_coin_msg_inspector_set t
        SET token_layer_id = m.token_layer_id
        FROM addr_map m
        WHERE lower(t.token_address) = m.token_address
          AND (t.token_layer_id IS NULL OR btrim(t.token_layer_id) = '')
      $q$, s, s, s, s);
      EXECUTE format('CREATE INDEX IF NOT EXISTS idx_tokencoin_msginspect_token_layer_id ON %I.raw_token_coin_msg_inspector_set (token_layer_id)', s);
    END IF;

    IF to_regclass(format('%I.%I', s, 'raw_token_coin_oft_received')) IS NOT NULL THEN
      EXECUTE format('ALTER TABLE %I.raw_token_coin_oft_received ADD COLUMN IF NOT EXISTS token_layer_id TEXT', s);
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
        UPDATE %I.raw_token_coin_oft_received t
        SET token_layer_id = m.token_layer_id
        FROM addr_map m
        WHERE lower(t.token_address) = m.token_address
          AND (t.token_layer_id IS NULL OR btrim(t.token_layer_id) = '')
      $q$, s, s, s, s);
      EXECUTE format('CREATE INDEX IF NOT EXISTS idx_tokencoin_oftreceived_token_layer_id ON %I.raw_token_coin_oft_received (token_layer_id)', s);
    END IF;

    IF to_regclass(format('%I.%I', s, 'raw_token_coin_ownership_transferred')) IS NOT NULL THEN
      EXECUTE format('ALTER TABLE %I.raw_token_coin_ownership_transferred ADD COLUMN IF NOT EXISTS token_layer_id TEXT', s);
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
        UPDATE %I.raw_token_coin_ownership_transferred t
        SET token_layer_id = m.token_layer_id
        FROM addr_map m
        WHERE lower(t.token_address) = m.token_address
          AND (t.token_layer_id IS NULL OR btrim(t.token_layer_id) = '')
      $q$, s, s, s, s);
      EXECUTE format('CREATE INDEX IF NOT EXISTS idx_tokencoin_ownertransf_token_layer_id ON %I.raw_token_coin_ownership_transferred (token_layer_id)', s);
    END IF;

    IF to_regclass(format('%I.%I', s, 'raw_token_coin_peer_set')) IS NOT NULL THEN
      EXECUTE format('ALTER TABLE %I.raw_token_coin_peer_set ADD COLUMN IF NOT EXISTS token_layer_id TEXT', s);
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
        UPDATE %I.raw_token_coin_peer_set t
        SET token_layer_id = m.token_layer_id
        FROM addr_map m
        WHERE lower(t.token_address) = m.token_address
          AND (t.token_layer_id IS NULL OR btrim(t.token_layer_id) = '')
      $q$, s, s, s, s);
      EXECUTE format('CREATE INDEX IF NOT EXISTS idx_tokencoin_peerset_token_layer_id ON %I.raw_token_coin_peer_set (token_layer_id)', s);
    END IF;

    IF to_regclass(format('%I.%I', s, 'raw_token_coin_pre_crime_set')) IS NOT NULL THEN
      EXECUTE format('ALTER TABLE %I.raw_token_coin_pre_crime_set ADD COLUMN IF NOT EXISTS token_layer_id TEXT', s);
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
        UPDATE %I.raw_token_coin_pre_crime_set t
        SET token_layer_id = m.token_layer_id
        FROM addr_map m
        WHERE lower(t.token_address) = m.token_address
          AND (t.token_layer_id IS NULL OR btrim(t.token_layer_id) = '')
      $q$, s, s, s, s);
      EXECUTE format('CREATE INDEX IF NOT EXISTS idx_tokencoin_precrime_token_layer_id ON %I.raw_token_coin_pre_crime_set (token_layer_id)', s);
    END IF;
  END LOOP;
END $$;
