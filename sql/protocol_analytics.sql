-- Analytics objects on top of raw indexer tables.
-- Run in the target schema after `schema.sql` is applied.

CREATE TABLE IF NOT EXISTS "cfg_indexer_config" (
  "key" TEXT PRIMARY KEY,
  "value" TEXT NOT NULL
);

-- Default only; override per schema/chain as needed.
INSERT INTO "cfg_indexer_config" ("key", "value")
VALUES ('usd_token_address', '0xED0E8956D5e7b04560460BE6B3811B0b31cEe8E1')
ON CONFLICT ("key") DO NOTHING;
INSERT INTO "cfg_indexer_config" ("key", "value")
VALUES ('usd_token_decimals', '6')
ON CONFLICT ("key") DO NOTHING;
INSERT INTO "cfg_indexer_config" ("key", "value")
VALUES ('launchpad_usd_decimals', '18')
ON CONFLICT ("key") DO NOTHING;
INSERT INTO "cfg_indexer_config" ("key", "value")
VALUES ('default_token_decimals', '18')
ON CONFLICT ("key") DO NOTHING;
INSERT INTO "cfg_indexer_config" ("key", "value")
VALUES ('default_token_supply', '1000000000')
ON CONFLICT ("key") DO NOTHING;

-- Canonical token dimension for relationship joins and GraphQL-friendly modeling.
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
CREATE UNIQUE INDEX IF NOT EXISTS "idx_dim_token_token_address_lower_uq" ON "dim_token" ((lower("token_address"))) WHERE "token_address" IS NOT NULL;
CREATE INDEX IF NOT EXISTS "idx_dim_token_token_address" ON "dim_token" ("token_address");
CREATE INDEX IF NOT EXISTS "idx_dim_token_symbol" ON "dim_token" ("symbol");

WITH token_src AS (
  SELECT
    t.token_id::text AS token_layer_id,
    t.token_address::text AS token_address,
    t.name::text AS name,
    t.symbol::text AS symbol,
    t.decimals::numeric AS decimals,
    t.token_uri::text AS token_uri,
    'registry_token_created'::text AS source_event,
    t.evt_block_number::numeric AS evt_block_number,
    t.evt_block_time AS evt_block_time
  FROM "raw_registry_token_created" t
  WHERE t.token_id IS NOT NULL AND t.token_id <> ''
  UNION ALL
  SELECT
    t.token_id::text,
    t.token_address::text,
    t.name::text,
    t.symbol::text,
    NULL::numeric,
    NULL::text,
    'registry_external_token_created'::text,
    t.evt_block_number::numeric,
    t.evt_block_time
  FROM "raw_registry_external_token_created" t
  WHERE t.token_id IS NOT NULL AND t.token_id <> ''
  UNION ALL
  SELECT
    t.token_id::text,
    t.token_address::text,
    t.name::text,
    t.symbol::text,
    NULL::numeric,
    NULL::text,
    'registry_token_registered'::text,
    t.evt_block_number::numeric,
    t.evt_block_time
  FROM "raw_registry_token_registered" t
  WHERE t.token_id IS NOT NULL AND t.token_id <> ''
),
token_latest AS (
  SELECT DISTINCT ON (token_layer_id)
    token_layer_id, token_address, name, symbol, decimals, token_uri, source_event, evt_block_number, evt_block_time
  FROM token_src
  ORDER BY token_layer_id, evt_block_number DESC, evt_block_time DESC
)
INSERT INTO "dim_token" (
  "token_layer_id", "token_address", "name", "symbol", "decimals", "token_uri", "source_event",
  "created_evt_block_number", "created_evt_block_time", "updated_evt_block_number", "updated_evt_block_time"
)
SELECT
  token_layer_id, token_address, name, symbol, decimals, token_uri, source_event,
  evt_block_number, evt_block_time, evt_block_number, evt_block_time
FROM token_latest
ON CONFLICT ("token_layer_id") DO UPDATE
SET
  "token_address" = COALESCE(EXCLUDED."token_address", "dim_token"."token_address"),
  "name" = COALESCE(EXCLUDED."name", "dim_token"."name"),
  "symbol" = COALESCE(EXCLUDED."symbol", "dim_token"."symbol"),
  "decimals" = COALESCE(EXCLUDED."decimals", "dim_token"."decimals"),
  "token_uri" = COALESCE(EXCLUDED."token_uri", "dim_token"."token_uri"),
  "source_event" = COALESCE(EXCLUDED."source_event", "dim_token"."source_event"),
  "updated_evt_block_number" = GREATEST(COALESCE("dim_token"."updated_evt_block_number", 0), COALESCE(EXCLUDED."updated_evt_block_number", 0)),
  "updated_evt_block_time" = COALESCE(EXCLUDED."updated_evt_block_time", "dim_token"."updated_evt_block_time");

DO $$
DECLARE
  t TEXT;
  cname TEXT;
  rec RECORD;
BEGIN
  FOR rec IN
    SELECT conname, conrelid::regclass AS relname
    FROM pg_constraint
    WHERE conname LIKE 'fk_tlid_%' OR conname LIKE 'fk_tid_%'
  LOOP
    EXECUTE format('ALTER TABLE %s DROP CONSTRAINT IF EXISTS %I', rec.relname, rec.conname);
  END LOOP;

  FOR t IN
    SELECT unnest(ARRAY[
      'agg_token_trade',
      'agg_wallet_token_balance',
      'cur_wallet_token_balance',
      'raw_token_coin_approval',
      'raw_token_coin_enforced_option_set',
      'raw_token_coin_initialized',
      'raw_token_coin_msg_inspector_set',
      'raw_token_coin_oft_received',
      'raw_token_coin_oft_sent',
      'raw_token_coin_ownership_transferred',
      'raw_token_coin_peer_set',
      'raw_token_coin_pre_crime_set',
      'raw_token_coin_transfer',
      'raw_uniswap_v3_pool_created',
      'raw_uniswap_v3_swap',
      'raw_uniswap_v3_mint',
      'raw_uniswap_v3_burn',
      'raw_launchpad_graduation'
    ])
  LOOP
    IF to_regclass(format('%I', t)) IS NOT NULL THEN
      EXECUTE format($q$
        UPDATE %I f
        SET token_layer_id = d.token_layer_id
        FROM dim_token d
        WHERE (f.token_layer_id IS NULL OR f.token_layer_id = '')
          AND f.token_address IS NOT NULL
          AND lower(f.token_address) = lower(d.token_address)
      $q$, t);

      IF t = ANY (ARRAY['agg_token_trade', 'agg_wallet_token_balance', 'cur_wallet_token_balance']) THEN
        cname := 'fk_tlid_' || substr(md5(t), 1, 10);
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = cname) THEN
          EXECUTE format(
            'ALTER TABLE %I ADD CONSTRAINT %I FOREIGN KEY (token_layer_id) REFERENCES dim_token(token_layer_id) DEFERRABLE INITIALLY DEFERRED NOT VALID',
            t, cname
          );
        END IF;
      END IF;
    END IF;
  END LOOP;

  FOR t IN SELECT unnest(ARRAY['raw_launchpad_buy', 'raw_launchpad_sell', 'raw_launchpad_graduation'])
  LOOP
    IF to_regclass(format('%I', t)) IS NOT NULL THEN
      cname := 'fk_tid_' || substr(md5(t), 1, 10);
      IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = cname) THEN
        EXECUTE format(
          'ALTER TABLE %I ADD CONSTRAINT %I FOREIGN KEY (token_id) REFERENCES dim_token(token_layer_id) DEFERRABLE INITIALLY DEFERRED NOT VALID',
          t, cname
        );
      END IF;
    END IF;
  END LOOP;
END $$;

CREATE OR REPLACE VIEW "vw_launchpad_pool_state_latest" AS
WITH launchpad_events AS (
  SELECT
    "token_id",
    "price"::numeric AS price,
    "supply"::numeric AS supply,
    "tokens_left"::numeric AS tokens_left,
    "liquidity_wei"::numeric AS liquidity_wei,
    "evt_block_number"::numeric AS evt_block_number,
    "evt_index"::numeric AS evt_index,
    "evt_block_time"
  FROM "raw_launchpad_buy"
  UNION ALL
  SELECT
    "token_id",
    "price"::numeric AS price,
    "supply"::numeric AS supply,
    "tokens_left"::numeric AS tokens_left,
    "liquidity_wei"::numeric AS liquidity_wei,
    "evt_block_number"::numeric AS evt_block_number,
    "evt_index"::numeric AS evt_index,
    "evt_block_time"
  FROM "raw_launchpad_sell"
),
ranked AS (
  SELECT
    *,
    ROW_NUMBER() OVER (
      PARTITION BY token_id
      ORDER BY evt_block_number DESC, evt_index DESC
    ) AS rn
  FROM launchpad_events
)
SELECT
  token_id,
  price,
  supply,
  tokens_left,
  liquidity_wei,
  evt_block_number,
  evt_block_time
FROM ranked
WHERE rn = 1;

CREATE OR REPLACE VIEW "vw_token_trades" AS
SELECT
  venue,
  trade_type,
  evt_block_number,
  evt_block_time,
  evt_tx_hash AS tx_hash,
  evt_index,
  wallet,
  token_address,
  token_layer_id,
  token_amount,
  usd_amount,
  price_usd,
  market_cap_usd,
  pool
FROM "agg_token_trade";

CREATE OR REPLACE VIEW "vw_uniswap_v3_lp_deposits" AS
SELECT
  evt_block_number,
  evt_block_time,
  evt_tx_hash AS tx_hash,
  evt_index,
  pool,
  owner,
  sender,
  tick_lower,
  tick_upper,
  amount,
  amount0,
  amount1,
  token_address,
  token_layer_id
FROM "raw_uniswap_v3_mint";

CREATE OR REPLACE VIEW "vw_uniswap_v3_lp_withdrawals" AS
SELECT
  evt_block_number,
  evt_block_time,
  evt_tx_hash AS tx_hash,
  evt_index,
  pool,
  owner,
  tick_lower,
  tick_upper,
  amount,
  amount0,
  amount1,
  token_address,
  token_layer_id
FROM "raw_uniswap_v3_burn";

CREATE OR REPLACE VIEW "vw_launchpad_graduations" AS
SELECT
  evt_block_number,
  evt_block_time,
  evt_tx_hash AS tx_hash,
  evt_index,
  token_layer_id,
  token_id,
  token_address,
  is_external,
  final_supply,
  final_reserves
FROM "raw_launchpad_graduation";

CREATE OR REPLACE VIEW "vw_token_activity" AS
WITH activity_base AS (
  SELECT
    'trade'::text AS activity_type,
    t.trade_type::text AS activity_subtype,
    t.evt_block_number::numeric AS evt_block_number,
    t.evt_block_time AS evt_block_time,
    t.evt_tx_hash::text AS tx_hash,
    t.evt_index::numeric AS evt_index,
    t.token_layer_id::text AS token_layer_id,
    NULL::text AS token_id,
    t.token_address::text AS token_address,
    t.wallet::text AS wallet,
    NULL::text AS from_address,
    NULL::text AS to_address,
    t.token_amount::numeric AS token_amount,
    t.token_amount_raw::numeric AS token_amount_raw,
    t.usd_amount::numeric AS usd_amount,
    t.usd_amount_raw::numeric AS usd_amount_raw,
    t.price_usd::numeric AS price_usd,
    t.market_cap_usd::numeric AS market_cap_usd,
    t.pool::text AS pool,
    NULL::numeric AS amount0,
    NULL::numeric AS amount1,
    NULL::text AS guid,
    NULL::numeric AS src_eid,
    NULL::numeric AS dst_eid,
    NULL::boolean AS is_external,
    NULL::numeric AS final_supply,
    NULL::numeric AS final_reserves
  FROM "agg_token_trade" t

  UNION ALL

  SELECT
    'transfer'::text,
    'local'::text,
    t.evt_block_number::numeric,
    t.evt_block_time,
    t.evt_tx_hash::text,
    t.evt_index::numeric,
    t.token_layer_id::text,
    NULL::text,
    t.token_address::text,
    NULL::text,
    t."from"::text,
    t."to"::text,
    t.amount::numeric,
    t.amount::numeric,
    NULL::numeric,
    NULL::numeric,
    NULL::numeric,
    NULL::numeric,
    NULL::text,
    NULL::numeric,
    NULL::numeric,
    NULL::text,
    NULL::numeric,
    NULL::numeric,
    NULL::boolean,
    NULL::numeric,
    NULL::numeric
  FROM "raw_token_coin_transfer" t

  UNION ALL

  SELECT
    'transfer'::text,
    'cross_chain_sent'::text,
    t.evt_block_number::numeric,
    t.evt_block_time,
    t.evt_tx_hash::text,
    t.evt_index::numeric,
    t.token_layer_id::text,
    NULL::text,
    t.token_address::text,
    NULL::text,
    t.from_address::text,
    NULL::text,
    t.amount_sent_ld::numeric,
    t.amount_sent_ld::numeric,
    NULL::numeric,
    NULL::numeric,
    NULL::numeric,
    NULL::numeric,
    NULL::text,
    NULL::numeric,
    t.amount_received_ld::numeric,
    t.guid::text,
    NULL::numeric,
    t.dst_eid::numeric,
    NULL::boolean,
    NULL::numeric,
    NULL::numeric
  FROM "raw_token_coin_oft_sent" t

  UNION ALL

  SELECT
    'transfer'::text,
    'cross_chain_received'::text,
    t.evt_block_number::numeric,
    t.evt_block_time,
    t.evt_tx_hash::text,
    t.evt_index::numeric,
    t.token_layer_id::text,
    NULL::text,
    t.token_address::text,
    NULL::text,
    NULL::text,
    t.to_address::text,
    t.amount_received_ld::numeric,
    t.amount_received_ld::numeric,
    NULL::numeric,
    NULL::numeric,
    NULL::numeric,
    NULL::numeric,
    NULL::text,
    NULL::numeric,
    t.amount_received_ld::numeric,
    t.guid::text,
    t.src_eid::numeric,
    NULL::numeric,
    NULL::boolean,
    NULL::numeric,
    NULL::numeric
  FROM "raw_token_coin_oft_received" t

  UNION ALL

  SELECT
    'lp'::text,
    'deposit'::text,
    t.evt_block_number::numeric,
    t.evt_block_time,
    t.evt_tx_hash::text,
    t.evt_index::numeric,
    t.token_layer_id::text,
    NULL::text,
    t.token_address::text,
    t.owner::text,
    t.sender::text,
    NULL::text,
    t.amount::numeric,
    t.amount::numeric,
    NULL::numeric,
    NULL::numeric,
    NULL::numeric,
    NULL::numeric,
    t.pool::text,
    t.amount0::numeric,
    t.amount1::numeric,
    NULL::text,
    NULL::numeric,
    NULL::numeric,
    NULL::boolean,
    NULL::numeric,
    NULL::numeric
  FROM "raw_uniswap_v3_mint" t

  UNION ALL

  SELECT
    'lp'::text,
    'withdrawal'::text,
    t.evt_block_number::numeric,
    t.evt_block_time,
    t.evt_tx_hash::text,
    t.evt_index::numeric,
    t.token_layer_id::text,
    NULL::text,
    t.token_address::text,
    t.owner::text,
    NULL::text,
    NULL::text,
    t.amount::numeric,
    t.amount::numeric,
    NULL::numeric,
    NULL::numeric,
    NULL::numeric,
    NULL::numeric,
    t.pool::text,
    t.amount0::numeric,
    t.amount1::numeric,
    NULL::text,
    NULL::numeric,
    NULL::numeric,
    NULL::boolean,
    NULL::numeric,
    NULL::numeric
  FROM "raw_uniswap_v3_burn" t

  UNION ALL

  SELECT
    'lifecycle'::text,
    'graduation'::text,
    t.evt_block_number::numeric,
    t.evt_block_time,
    t.evt_tx_hash::text,
    t.evt_index::numeric,
    COALESCE(NULLIF(t.token_layer_id::text, ''), t.token_id::text),
    t.token_id::text,
    t.token_address::text,
    NULL::text,
    NULL::text,
    NULL::text,
    NULL::numeric,
    NULL::numeric,
    NULL::numeric,
    NULL::numeric,
    NULL::numeric,
    NULL::numeric,
    NULL::text,
    NULL::numeric,
    NULL::numeric,
    NULL::text,
    NULL::numeric,
    NULL::numeric,
    t.is_external,
    t.final_supply::numeric,
    t.final_reserves::numeric
  FROM "raw_launchpad_graduation" t
),
cfg AS (
  SELECT COALESCE(MAX(CASE WHEN key = 'default_token_decimals' THEN value END)::numeric, 18::numeric) AS default_token_decimals
  FROM "cfg_indexer_config"
),
activity_with_decimals AS (
  SELECT
    a.*,
    COALESCE(dt.decimals, cfg.default_token_decimals) AS token_decimals
  FROM activity_base a
  CROSS JOIN cfg
  LEFT JOIN "dim_token" dt
    ON a.token_layer_id IS NOT NULL
   AND a.token_layer_id <> ''
   AND dt.token_layer_id = a.token_layer_id
)
SELECT
  a.*,
  CASE
    WHEN a.token_amount IS NULL THEN NULL::numeric
    WHEN a.activity_type = 'trade' THEN a.token_amount
    ELSE a.token_amount / power(10::numeric, a.token_decimals)
  END AS token_amount_decimal,
  CASE WHEN a.amount0 IS NULL THEN NULL::numeric
       ELSE a.amount0 / power(10::numeric, a.token_decimals) END AS amount0_decimal,
  CASE WHEN a.amount1 IS NULL THEN NULL::numeric
       ELSE a.amount1 / power(10::numeric, a.token_decimals) END AS amount1_decimal,
  COALESCE(a.price_usd, p.price_usd) AS price_usd_at_event,
  CASE
    WHEN a.token_amount IS NULL THEN NULL::numeric
    WHEN a.activity_type = 'trade' THEN a.token_amount * COALESCE(a.price_usd, p.price_usd)
    ELSE (a.token_amount / power(10::numeric, a.token_decimals)) * COALESCE(a.price_usd, p.price_usd)
  END AS usd_value
FROM activity_with_decimals a
LEFT JOIN LATERAL (
  SELECT pr.price_usd
  FROM "agg_token_price_usd" pr
  WHERE (
    (
      a.token_layer_id IS NOT NULL
      AND a.token_layer_id <> ''
      AND pr.token_layer_id = a.token_layer_id
    )
    OR (
      (a.token_layer_id IS NULL OR a.token_layer_id = '')
      AND a.token_address IS NOT NULL
      AND pr.token_address = a.token_address
    )
  )
    AND pr.evt_block_number <= a.evt_block_number
  ORDER BY pr.evt_block_number DESC, pr.evt_index DESC
  LIMIT 1
) p ON TRUE;

CREATE OR REPLACE VIEW "vw_token_activity_desc" AS
SELECT *
FROM "vw_token_activity"
ORDER BY evt_block_number DESC, evt_index DESC;

CREATE TABLE IF NOT EXISTS "cur_token_stats" (
  "token_layer_id" TEXT PRIMARY KEY,
  "token_address" TEXT,
  "price_usd" NUMERIC,
  "price_change_1h_pct" NUMERIC,
  "price_change_6h_pct" NUMERIC,
  "price_change_12h_pct" NUMERIC,
  "price_change_24h_pct" NUMERIC,
  "price_change_1h_abs" NUMERIC,
  "price_change_6h_abs" NUMERIC,
  "price_change_12h_abs" NUMERIC,
  "price_change_24h_abs" NUMERIC,
  "volume_usd_1h" NUMERIC,
  "volume_usd_6h" NUMERIC,
  "volume_usd_12h" NUMERIC,
  "volume_usd_24h" NUMERIC,
  "holder_count" NUMERIC,
  "evt_block_number" NUMERIC,
  "updated_at" TIMESTAMP
);
CREATE INDEX IF NOT EXISTS "idx_cur_token_stats_token_address" ON "cur_token_stats" ("token_address");
CREATE INDEX IF NOT EXISTS "idx_cur_token_stats_evt_block_number" ON "cur_token_stats" ("evt_block_number");

CREATE OR REPLACE FUNCTION "refresh_cur_token_stats"(p_now TIMESTAMP DEFAULT now())
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO "cur_token_stats" (
    "token_layer_id",
    "token_address",
    "price_usd",
    "price_change_1h_pct",
    "price_change_6h_pct",
    "price_change_12h_pct",
    "price_change_24h_pct",
    "price_change_1h_abs",
    "price_change_6h_abs",
    "price_change_12h_abs",
    "price_change_24h_abs",
    "volume_usd_1h",
    "volume_usd_6h",
    "volume_usd_12h",
    "volume_usd_24h",
    "holder_count",
    "evt_block_number",
    "updated_at"
  )
  SELECT
    d.token_layer_id,
    d.token_address,
    cp.price_usd,
    CASE WHEN p1h.price_usd IS NULL OR p1h.price_usd = 0 OR cp.price_usd IS NULL THEN NULL
         ELSE ((cp.price_usd - p1h.price_usd) / p1h.price_usd) * 100 END AS price_change_1h_pct,
    CASE WHEN p6h.price_usd IS NULL OR p6h.price_usd = 0 OR cp.price_usd IS NULL THEN NULL
         ELSE ((cp.price_usd - p6h.price_usd) / p6h.price_usd) * 100 END AS price_change_6h_pct,
    CASE WHEN p12h.price_usd IS NULL OR p12h.price_usd = 0 OR cp.price_usd IS NULL THEN NULL
         ELSE ((cp.price_usd - p12h.price_usd) / p12h.price_usd) * 100 END AS price_change_12h_pct,
    CASE WHEN p24h.price_usd IS NULL OR p24h.price_usd = 0 OR cp.price_usd IS NULL THEN NULL
         ELSE ((cp.price_usd - p24h.price_usd) / p24h.price_usd) * 100 END AS price_change_24h_pct,
    CASE WHEN cp.price_usd IS NULL OR p1h.price_usd IS NULL THEN NULL ELSE cp.price_usd - p1h.price_usd END AS price_change_1h_abs,
    CASE WHEN cp.price_usd IS NULL OR p6h.price_usd IS NULL THEN NULL ELSE cp.price_usd - p6h.price_usd END AS price_change_6h_abs,
    CASE WHEN cp.price_usd IS NULL OR p12h.price_usd IS NULL THEN NULL ELSE cp.price_usd - p12h.price_usd END AS price_change_12h_abs,
    CASE WHEN cp.price_usd IS NULL OR p24h.price_usd IS NULL THEN NULL ELSE cp.price_usd - p24h.price_usd END AS price_change_24h_abs,
    COALESCE(v1h.volume_usd, 0),
    COALESCE(v6h.volume_usd, 0),
    COALESCE(v12h.volume_usd, 0),
    COALESCE(v24h.volume_usd, 0),
    COALESCE(h.holder_count, 0),
    cp.evt_block_number,
    p_now
  FROM "dim_token" d
  LEFT JOIN LATERAL (
    SELECT p.price_usd, p.evt_block_number
    FROM "agg_token_price_usd" p
    WHERE p.token_layer_id = d.token_layer_id
    ORDER BY p.evt_block_number DESC, p.evt_index DESC
    LIMIT 1
  ) cp ON TRUE
  LEFT JOIN LATERAL (
    SELECT p.price_usd
    FROM "agg_token_price_usd" p
    WHERE p.token_layer_id = d.token_layer_id
      AND p.evt_block_time <= p_now - INTERVAL '1 hour'
    ORDER BY p.evt_block_number DESC, p.evt_index DESC
    LIMIT 1
  ) p1h ON TRUE
  LEFT JOIN LATERAL (
    SELECT p.price_usd
    FROM "agg_token_price_usd" p
    WHERE p.token_layer_id = d.token_layer_id
      AND p.evt_block_time <= p_now - INTERVAL '6 hour'
    ORDER BY p.evt_block_number DESC, p.evt_index DESC
    LIMIT 1
  ) p6h ON TRUE
  LEFT JOIN LATERAL (
    SELECT p.price_usd
    FROM "agg_token_price_usd" p
    WHERE p.token_layer_id = d.token_layer_id
      AND p.evt_block_time <= p_now - INTERVAL '12 hour'
    ORDER BY p.evt_block_number DESC, p.evt_index DESC
    LIMIT 1
  ) p12h ON TRUE
  LEFT JOIN LATERAL (
    SELECT p.price_usd
    FROM "agg_token_price_usd" p
    WHERE p.token_layer_id = d.token_layer_id
      AND p.evt_block_time <= p_now - INTERVAL '24 hour'
    ORDER BY p.evt_block_number DESC, p.evt_index DESC
    LIMIT 1
  ) p24h ON TRUE
  LEFT JOIN LATERAL (
    SELECT SUM(t.usd_amount)::numeric AS volume_usd
    FROM "agg_token_trade" t
    WHERE t.token_layer_id = d.token_layer_id
      AND t.evt_block_time > p_now - INTERVAL '1 hour'
      AND t.evt_block_time <= p_now
  ) v1h ON TRUE
  LEFT JOIN LATERAL (
    SELECT SUM(t.usd_amount)::numeric AS volume_usd
    FROM "agg_token_trade" t
    WHERE t.token_layer_id = d.token_layer_id
      AND t.evt_block_time > p_now - INTERVAL '6 hour'
      AND t.evt_block_time <= p_now
  ) v6h ON TRUE
  LEFT JOIN LATERAL (
    SELECT SUM(t.usd_amount)::numeric AS volume_usd
    FROM "agg_token_trade" t
    WHERE t.token_layer_id = d.token_layer_id
      AND t.evt_block_time > p_now - INTERVAL '12 hour'
      AND t.evt_block_time <= p_now
  ) v12h ON TRUE
  LEFT JOIN LATERAL (
    SELECT SUM(t.usd_amount)::numeric AS volume_usd
    FROM "agg_token_trade" t
    WHERE t.token_layer_id = d.token_layer_id
      AND t.evt_block_time > p_now - INTERVAL '24 hour'
      AND t.evt_block_time <= p_now
  ) v24h ON TRUE
  LEFT JOIN LATERAL (
    SELECT COUNT(*)::numeric AS holder_count
    FROM "cur_wallet_token_balance" b
    WHERE b.token_layer_id = d.token_layer_id
      AND b.balance > 0
  ) h ON TRUE
  WHERE d.token_layer_id IS NOT NULL
    AND d.token_layer_id <> ''
  ON CONFLICT ("token_layer_id") DO UPDATE
  SET
    "token_address" = EXCLUDED."token_address",
    "price_usd" = EXCLUDED."price_usd",
    "price_change_1h_pct" = EXCLUDED."price_change_1h_pct",
    "price_change_6h_pct" = EXCLUDED."price_change_6h_pct",
    "price_change_12h_pct" = EXCLUDED."price_change_12h_pct",
    "price_change_24h_pct" = EXCLUDED."price_change_24h_pct",
    "price_change_1h_abs" = EXCLUDED."price_change_1h_abs",
    "price_change_6h_abs" = EXCLUDED."price_change_6h_abs",
    "price_change_12h_abs" = EXCLUDED."price_change_12h_abs",
    "price_change_24h_abs" = EXCLUDED."price_change_24h_abs",
    "volume_usd_1h" = EXCLUDED."volume_usd_1h",
    "volume_usd_6h" = EXCLUDED."volume_usd_6h",
    "volume_usd_12h" = EXCLUDED."volume_usd_12h",
    "volume_usd_24h" = EXCLUDED."volume_usd_24h",
    "holder_count" = EXCLUDED."holder_count",
    "evt_block_number" = EXCLUDED."evt_block_number",
    "updated_at" = EXCLUDED."updated_at";
END;
$$;

SELECT "refresh_cur_token_stats"();

CREATE OR REPLACE VIEW "vw_fee_ledger" AS
SELECT
  fd."evt_block_number"::numeric AS evt_block_number,
  fd."evt_block_time" AS evt_block_time,
  fd."evt_tx_hash" AS tx_hash,
  fd."evt_index"::numeric AS evt_index,
  lower(fd."currency") AS currency,
  lower(fd."recipient") AS account,
  fd."amount"::numeric AS amount_delta,
  false AS is_protocol,
  fd."activity_id"::numeric AS activity_id,
  CASE fd."activity_id"
    WHEN 0 THEN 'BondingCurveTrade'
    WHEN 1 THEN 'DEXTrade'
    WHEN 2 THEN 'TokenCreation'
    WHEN 3 THEN 'Graduation'
    WHEN 4 THEN 'ExternalTokenCreation'
    WHEN 5 THEN 'CrossChainRegistration'
    ELSE 'Unknown'
  END AS activity_name,
  fd."distribution_type"::numeric AS distribution_type,
  CASE fd."distribution_type"
    WHEN 0 THEN 'Owner'
    WHEN 1 THEN 'Builder'
    WHEN 2 THEN 'Referral'
    WHEN 3 THEN 'ProtocolReferral'
    WHEN 4 THEN 'ProtocolReferralCashback'
    ELSE 'Unknown'
  END AS distribution_name
FROM "raw_fees_fee_distributed" fd
UNION ALL
SELECT
  fw."evt_block_number"::numeric,
  fw."evt_block_time",
  fw."evt_tx_hash",
  fw."evt_index"::numeric,
  lower(fw."currency"),
  lower(fw."recipient"),
  -fw."amount"::numeric,
  false,
  NULL::numeric,
  NULL::text,
  NULL::numeric,
  NULL::text
FROM "raw_fees_withdrawn" fw
UNION ALL
SELECT
  pd."evt_block_number"::numeric,
  pd."evt_block_time",
  pd."evt_tx_hash",
  pd."evt_index"::numeric,
  lower(pd."currency"),
  NULL::text,
  pd."amount"::numeric,
  true,
  pd."activity_id"::numeric,
  CASE pd."activity_id"
    WHEN 0 THEN 'BondingCurveTrade'
    WHEN 1 THEN 'DEXTrade'
    WHEN 2 THEN 'TokenCreation'
    WHEN 3 THEN 'Graduation'
    WHEN 4 THEN 'ExternalTokenCreation'
    WHEN 5 THEN 'CrossChainRegistration'
    ELSE 'Unknown'
  END,
  NULL::numeric,
  NULL::text
FROM "raw_fees_protocol_fee_distributed" pd
UNION ALL
SELECT
  pw."evt_block_number"::numeric,
  pw."evt_block_time",
  pw."evt_tx_hash",
  pw."evt_index"::numeric,
  lower(pw."currency"),
  NULL::text,
  -pw."amount"::numeric,
  true,
  NULL::numeric,
  NULL::text,
  NULL::numeric,
  NULL::text
FROM "raw_fees_protocol_withdrawn" pw;

DROP TRIGGER IF EXISTS "trg_fees_fee_distributed_apply" ON "raw_fees_fee_distributed";
DROP TRIGGER IF EXISTS "trg_fees_withdrawn_apply" ON "raw_fees_withdrawn";
DROP TRIGGER IF EXISTS "trg_fees_protocol_fee_distributed_apply" ON "raw_fees_protocol_fee_distributed";
DROP TRIGGER IF EXISTS "trg_fees_protocol_withdrawn_apply" ON "raw_fees_protocol_withdrawn";

DROP FUNCTION IF EXISTS "trg_apply_fees_fee_distributed"();
DROP FUNCTION IF EXISTS "trg_apply_fees_withdrawn"();
DROP FUNCTION IF EXISTS "trg_apply_fees_protocol_fee_distributed"();
DROP FUNCTION IF EXISTS "trg_apply_fees_protocol_withdrawn"();
DROP FUNCTION IF EXISTS "apply_user_fee_delta"(TEXT, TEXT, NUMERIC);
DROP FUNCTION IF EXISTS "apply_protocol_fee_delta"(TEXT, NUMERIC);
DROP FUNCTION IF EXISTS "rebuild_fee_balance_currents"();

DROP TABLE IF EXISTS "user_fee_balances_current";
DROP TABLE IF EXISTS "protocol_fee_balances_current";

CREATE OR REPLACE VIEW "vw_user_fee_balances_current" AS
SELECT
  "account",
  "currency",
  "balance"::numeric AS balance,
  "evt_block_number",
  "evt_block_time"
FROM "cur_user_fee_balance";

CREATE OR REPLACE VIEW "vw_protocol_fee_balances_current" AS
SELECT
  "currency",
  "balance"::numeric AS balance,
  "evt_block_number",
  "evt_block_time"
FROM "cur_protocol_fee_balance";

CREATE OR REPLACE VIEW "vw_ip_owner_current" AS
WITH ranked AS (
  SELECT
    "id",
    lower("to") AS owner,
    "evt_block_number"::numeric AS evt_block_number,
    "evt_index"::numeric AS evt_index,
    "evt_block_time",
    ROW_NUMBER() OVER (
      PARTITION BY "id"
      ORDER BY "evt_block_number"::numeric DESC, "evt_index"::numeric DESC
    ) AS rn
  FROM "raw_ip_transfer"
)
SELECT
  "id",
  CASE
    WHEN owner = '0x0000000000000000000000000000000000000000' THEN NULL
    ELSE owner
  END AS owner,
  evt_block_number,
  evt_block_time
FROM ranked
WHERE rn = 1;

CREATE OR REPLACE VIEW "vw_roles_account_balances_current" AS
WITH role_ledger AS (
  SELECT
    lower("account") AS account,
    "id" AS role_id,
    1::numeric AS delta
  FROM "raw_roles_role_granted"
  UNION ALL
  SELECT
    lower("account") AS account,
    "id" AS role_id,
    -1::numeric AS delta
  FROM "raw_roles_role_revoked"
  UNION ALL
  SELECT
    lower("account") AS account,
    "id" AS role_id,
    -1::numeric AS delta
  FROM "raw_roles_role_renounced"
  UNION ALL
  SELECT
    lower("to") AS account,
    "id" AS role_id,
    COALESCE("amount", 0::numeric) AS delta
  FROM "raw_roles_transfer"
  UNION ALL
  SELECT
    lower("from") AS account,
    "id" AS role_id,
    -COALESCE("amount", 0::numeric) AS delta
  FROM "raw_roles_transfer"
)
SELECT
  account,
  role_id,
  SUM(delta) AS balance
FROM role_ledger
GROUP BY account, role_id
HAVING SUM(delta) > 0;
