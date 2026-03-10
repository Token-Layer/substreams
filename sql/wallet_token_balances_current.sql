-- Maintains a strict current-balance table (one row per token_address+wallet)
-- from the append-only WalletTokenBalance sink table.
--
-- Usage:
-- 1) Replace `indexer_schema` with your target schema (e.g. indexer_evm_base_sepolia)
-- 2) Run in your Postgres SQL editor once per schema.

DO $$
DECLARE
  target_schema text := 'indexer_schema';
  source_table text;
BEGIN
  IF to_regclass(format('%I.%I', target_schema, 'WalletTokenBalance')) IS NOT NULL THEN
    source_table := 'WalletTokenBalance';
  ELSIF to_regclass(format('%I.%I', target_schema, 'Wallet_TokenBalance')) IS NOT NULL THEN
    source_table := 'Wallet_TokenBalance';
  ELSE
    RAISE EXCEPTION 'Source table not found in schema % (expected WalletTokenBalance or Wallet_TokenBalance)', target_schema;
  END IF;

  EXECUTE format($sql$
    CREATE TABLE IF NOT EXISTS %I.wallet_token_balances_current (
      token_address text NOT NULL,
      wallet text NOT NULL,
      balance numeric NOT NULL,
      last_evt_block_number bigint NOT NULL,
      last_evt_block_time timestamp,
      updated_at timestamp NOT NULL DEFAULT now(),
      PRIMARY KEY (token_address, wallet)
    );
  $sql$, target_schema);

  EXECUTE format($sql$
    CREATE OR REPLACE FUNCTION %I.sync_wallet_token_balances_current()
    RETURNS trigger
    LANGUAGE plpgsql
    AS $fn$
    BEGIN
      INSERT INTO %I.wallet_token_balances_current (
        token_address,
        wallet,
        balance,
        last_evt_block_number,
        last_evt_block_time,
        updated_at
      )
      VALUES (
        NEW.token_address,
        NEW.wallet,
        NEW.balance::numeric,
        NEW.evt_block_number::bigint,
        NEW.evt_block_time,
        now()
      )
      ON CONFLICT (token_address, wallet) DO UPDATE
      SET
        balance = EXCLUDED.balance,
        last_evt_block_number = EXCLUDED.last_evt_block_number,
        last_evt_block_time = EXCLUDED.last_evt_block_time,
        updated_at = now()
      WHERE
        EXCLUDED.last_evt_block_number > %I.wallet_token_balances_current.last_evt_block_number
        OR (
          EXCLUDED.last_evt_block_number = %I.wallet_token_balances_current.last_evt_block_number
          AND COALESCE(EXCLUDED.last_evt_block_time, 'epoch'::timestamp) >= COALESCE(%I.wallet_token_balances_current.last_evt_block_time, 'epoch'::timestamp)
        );

      RETURN NEW;
    END;
    $fn$;
  $sql$, target_schema, target_schema, target_schema, target_schema, target_schema);

  EXECUTE format(
    'DROP TRIGGER IF EXISTS trg_sync_wallet_token_balances_current ON %I.%I;',
    target_schema, source_table
  );

  EXECUTE format(
    'CREATE TRIGGER trg_sync_wallet_token_balances_current AFTER INSERT ON %I.%I FOR EACH ROW EXECUTE FUNCTION %I.sync_wallet_token_balances_current();',
    target_schema, source_table, target_schema
  );

  -- Initial backfill sync from historical snapshots.
  EXECUTE format($sql$
    INSERT INTO %I.wallet_token_balances_current (
      token_address,
      wallet,
      balance,
      last_evt_block_number,
      last_evt_block_time,
      updated_at
    )
    SELECT DISTINCT ON (w.token_address, w.wallet)
      w.token_address,
      w.wallet,
      w.balance::numeric,
      w.evt_block_number::bigint,
      w.evt_block_time,
      now()
    FROM %I.%I w
    ORDER BY w.token_address, w.wallet, w.evt_block_number DESC, w.evt_block_time DESC
    ON CONFLICT (token_address, wallet) DO UPDATE
    SET
      balance = EXCLUDED.balance,
      last_evt_block_number = EXCLUDED.last_evt_block_number,
      last_evt_block_time = EXCLUDED.last_evt_block_time,
      updated_at = now()
    WHERE
      EXCLUDED.last_evt_block_number > %I.wallet_token_balances_current.last_evt_block_number
      OR (
        EXCLUDED.last_evt_block_number = %I.wallet_token_balances_current.last_evt_block_number
        AND COALESCE(EXCLUDED.last_evt_block_time, 'epoch'::timestamp) >= COALESCE(%I.wallet_token_balances_current.last_evt_block_time, 'epoch'::timestamp)
      );
  $sql$, target_schema, target_schema, source_table, target_schema, target_schema, target_schema);
END $$;

