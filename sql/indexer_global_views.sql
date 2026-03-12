CREATE SCHEMA IF NOT EXISTS indexer;

ALTER TABLE IF EXISTS indexer_evm_base_sepolia.agg_token_trade
  ADD COLUMN IF NOT EXISTS token_layer_id TEXT;
ALTER TABLE IF EXISTS indexer_evm_bnb_testnet.agg_token_trade
  ADD COLUMN IF NOT EXISTS token_layer_id TEXT;
DO $$
BEGIN
  IF to_regclass('indexer_evm_base_sepolia.agg_token_trade') IS NOT NULL THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_agg_token_trade_token_layer_id_base_sepolia ON indexer_evm_base_sepolia.agg_token_trade (token_layer_id)';
  END IF;
  IF to_regclass('indexer_evm_bnb_testnet.agg_token_trade') IS NOT NULL THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_agg_token_trade_token_layer_id_bnb_testnet ON indexer_evm_bnb_testnet.agg_token_trade (token_layer_id)';
  END IF;
END $$;

CREATE OR REPLACE VIEW indexer.vw_token_trades AS
SELECT
  'base-sepolia'::text AS chain,
  t.evt_block_number,
  t.evt_block_time,
  t.evt_tx_hash,
  t.evt_index,
  t.venue,
  t.trade_type,
  t.wallet,
  t.token_address,
  t.token_layer_id,
  t.pool,
  t.token_amount::text AS token_amount,
  t.token_amount_raw::text AS token_amount_raw,
  t.usd_amount::text AS usd_amount,
  t.usd_amount_raw::text AS usd_amount_raw,
  t.price_usd::text AS price_usd,
  t.price_usd::text AS price_usd_raw,
  t.market_cap_usd::text AS market_cap_usd,
  t.market_cap_usd::text AS market_cap_usd_raw,
  t.token_decimals::text AS token_decimals,
  t.quote_decimals::text AS quote_decimals,
  t.token_decimals_source,
  t.quote_decimals_source
FROM indexer_evm_base_sepolia.agg_token_trade t

UNION ALL

SELECT
  'bnb-testnet'::text AS chain,
  t.evt_block_number,
  t.evt_block_time,
  t.evt_tx_hash,
  t.evt_index,
  t.venue,
  t.trade_type,
  t.wallet,
  t.token_address,
  t.token_layer_id,
  t.pool,
  t.token_amount::text AS token_amount,
  t.token_amount_raw::text AS token_amount_raw,
  t.usd_amount::text AS usd_amount,
  t.usd_amount_raw::text AS usd_amount_raw,
  t.price_usd::text AS price_usd,
  t.price_usd::text AS price_usd_raw,
  t.market_cap_usd::text AS market_cap_usd,
  t.market_cap_usd::text AS market_cap_usd_raw,
  t.token_decimals::text AS token_decimals,
  t.quote_decimals::text AS quote_decimals,
  t.token_decimals_source,
  t.quote_decimals_source
FROM indexer_evm_bnb_testnet.agg_token_trade t;

-- Service-role-only access
REVOKE ALL ON TABLE indexer.vw_token_trades FROM anon;
REVOKE ALL ON TABLE indexer.vw_token_trades FROM authenticated;
GRANT SELECT ON TABLE indexer.vw_token_trades TO service_role;

CREATE OR REPLACE VIEW indexer.vw_wallet_token_balances_current AS
SELECT
  'base-sepolia'::text AS chain,
  t.evt_block_number,
  t.evt_block_time,
  t.wallet,
  t.token_address,
  t.token_layer_id,
  t.balance::text AS balance,
  t.balance::text AS balance_raw
FROM indexer_evm_base_sepolia.cur_wallet_token_balance t

UNION ALL

SELECT
  'bnb-testnet'::text AS chain,
  t.evt_block_number,
  t.evt_block_time,
  t.wallet,
  t.token_address,
  t.token_layer_id,
  t.balance::text AS balance,
  t.balance::text AS balance_raw
FROM indexer_evm_bnb_testnet.cur_wallet_token_balance t;

-- Service-role-only access
REVOKE ALL ON TABLE indexer.vw_wallet_token_balances_current FROM anon;
REVOKE ALL ON TABLE indexer.vw_wallet_token_balances_current FROM authenticated;
GRANT SELECT ON TABLE indexer.vw_wallet_token_balances_current TO service_role;

CREATE OR REPLACE VIEW indexer.vw_token_transfers_local AS
SELECT
  'base-sepolia'::text AS chain,
  t.evt_block_number,
  t.evt_block_time,
  t.evt_tx_hash,
  t.evt_index,
  t.token_layer_id,
  t.token_address,
  t."from" AS from_address,
  t."to" AS to_address,
  t.amount::text AS amount,
  t.amount::text AS amount_raw
FROM indexer_evm_base_sepolia.raw_token_coin_transfer t

UNION ALL

SELECT
  'bnb-testnet'::text AS chain,
  t.evt_block_number,
  t.evt_block_time,
  t.evt_tx_hash,
  t.evt_index,
  t.token_layer_id,
  t.token_address,
  t."from" AS from_address,
  t."to" AS to_address,
  t.amount::text AS amount,
  t.amount::text AS amount_raw
FROM indexer_evm_bnb_testnet.raw_token_coin_transfer t;

-- Service-role-only access
REVOKE ALL ON TABLE indexer.vw_token_transfers_local FROM anon;
REVOKE ALL ON TABLE indexer.vw_token_transfers_local FROM authenticated;
GRANT SELECT ON TABLE indexer.vw_token_transfers_local TO service_role;

CREATE OR REPLACE VIEW indexer.vw_token_transfers_cross_chain AS
SELECT
  'base-sepolia'::text AS chain,
  'oft_sent'::text AS transfer_type,
  t.evt_block_number,
  t.evt_block_time,
  t.evt_tx_hash,
  t.evt_index,
  t.token_layer_id,
  t.token_address,
  t.from_address AS from_address,
  NULL::text AS to_address,
  t.amount_sent_ld::text AS amount,
  t.amount_sent_ld::text AS amount_raw,
  t.amount_received_ld::text AS amount_received_ld,
  t.amount_received_ld::text AS amount_received_ld_raw,
  t.guid,
  NULL::text AS src_eid,
  t.dst_eid::text AS dst_eid
FROM indexer_evm_base_sepolia.raw_token_coin_oft_sent t

UNION ALL

SELECT
  'base-sepolia'::text AS chain,
  'oft_received'::text AS transfer_type,
  t.evt_block_number,
  t.evt_block_time,
  t.evt_tx_hash,
  t.evt_index,
  t.token_layer_id,
  t.token_address,
  NULL::text AS from_address,
  t.to_address AS to_address,
  t.amount_received_ld::text AS amount,
  t.amount_received_ld::text AS amount_raw,
  t.amount_received_ld::text AS amount_received_ld,
  t.amount_received_ld::text AS amount_received_ld_raw,
  t.guid,
  t.src_eid::text AS src_eid,
  NULL::text AS dst_eid
FROM indexer_evm_base_sepolia.raw_token_coin_oft_received t

UNION ALL

SELECT
  'bnb-testnet'::text AS chain,
  'oft_sent'::text AS transfer_type,
  t.evt_block_number,
  t.evt_block_time,
  t.evt_tx_hash,
  t.evt_index,
  t.token_layer_id,
  t.token_address,
  t.from_address AS from_address,
  NULL::text AS to_address,
  t.amount_sent_ld::text AS amount,
  t.amount_sent_ld::text AS amount_raw,
  t.amount_received_ld::text AS amount_received_ld,
  t.amount_received_ld::text AS amount_received_ld_raw,
  t.guid,
  NULL::text AS src_eid,
  t.dst_eid::text AS dst_eid
FROM indexer_evm_bnb_testnet.raw_token_coin_oft_sent t

UNION ALL

SELECT
  'bnb-testnet'::text AS chain,
  'oft_received'::text AS transfer_type,
  t.evt_block_number,
  t.evt_block_time,
  t.evt_tx_hash,
  t.evt_index,
  t.token_layer_id,
  t.token_address,
  NULL::text AS from_address,
  t.to_address AS to_address,
  t.amount_received_ld::text AS amount,
  t.amount_received_ld::text AS amount_raw,
  t.amount_received_ld::text AS amount_received_ld,
  t.amount_received_ld::text AS amount_received_ld_raw,
  t.guid,
  t.src_eid::text AS src_eid,
  NULL::text AS dst_eid
FROM indexer_evm_bnb_testnet.raw_token_coin_oft_received t;

-- Service-role-only access
REVOKE ALL ON TABLE indexer.vw_token_transfers_cross_chain FROM anon;
REVOKE ALL ON TABLE indexer.vw_token_transfers_cross_chain FROM authenticated;
GRANT SELECT ON TABLE indexer.vw_token_transfers_cross_chain TO service_role;

CREATE OR REPLACE VIEW indexer.vw_token_transfers AS
SELECT
  chain,
  'local'::text AS transfer_type,
  evt_block_number,
  evt_block_time,
  evt_tx_hash,
  evt_index,
  token_layer_id,
  token_address,
  from_address,
  to_address,
  amount,
  amount_raw,
  NULL::text AS amount_received_ld,
  NULL::text AS amount_received_ld_raw,
  NULL::text AS guid,
  NULL::text AS src_eid,
  NULL::text AS dst_eid
FROM indexer.vw_token_transfers_local

UNION ALL

SELECT
  chain,
  transfer_type,
  evt_block_number,
  evt_block_time,
  evt_tx_hash,
  evt_index,
  token_layer_id,
  token_address,
  from_address,
  to_address,
  amount,
  amount_raw,
  amount_received_ld,
  amount_received_ld_raw,
  guid,
  src_eid,
  dst_eid
FROM indexer.vw_token_transfers_cross_chain;

-- Service-role-only access
REVOKE ALL ON TABLE indexer.vw_token_transfers FROM anon;
REVOKE ALL ON TABLE indexer.vw_token_transfers FROM authenticated;
GRANT SELECT ON TABLE indexer.vw_token_transfers TO service_role;

CREATE OR REPLACE VIEW indexer.vw_tokens_created AS
SELECT
  'base-sepolia'::text AS chain,
  'registry_token_created'::text AS source_event,
  t.evt_block_number,
  t.evt_block_time,
  t.evt_tx_hash,
  t.evt_index,
  t.token_id,
  t.token_address,
  t.ip_id,
  t.name,
  t.symbol,
  t.decimals::text AS decimals,
  t.decimals::text AS decimals_raw,
  t.token_uri
FROM indexer_evm_base_sepolia.raw_registry_token_created t

UNION ALL

SELECT
  'base-sepolia'::text AS chain,
  'registry_external_token_created'::text AS source_event,
  t.evt_block_number,
  t.evt_block_time,
  t.evt_tx_hash,
  t.evt_index,
  t.token_id,
  t.token_address,
  NULL::text AS ip_id,
  t.name,
  t.symbol,
  NULL::text AS decimals,
  NULL::text AS decimals_raw,
  NULL::text AS token_uri
FROM indexer_evm_base_sepolia.raw_registry_external_token_created t

UNION ALL

SELECT
  'bnb-testnet'::text AS chain,
  'registry_token_created'::text AS source_event,
  t.evt_block_number,
  t.evt_block_time,
  t.evt_tx_hash,
  t.evt_index,
  t.token_id,
  t.token_address,
  t.ip_id,
  t.name,
  t.symbol,
  t.decimals::text AS decimals,
  t.decimals::text AS decimals_raw,
  t.token_uri
FROM indexer_evm_bnb_testnet.raw_registry_token_created t

UNION ALL

SELECT
  'bnb-testnet'::text AS chain,
  'registry_external_token_created'::text AS source_event,
  t.evt_block_number,
  t.evt_block_time,
  t.evt_tx_hash,
  t.evt_index,
  t.token_id,
  t.token_address,
  NULL::text AS ip_id,
  t.name,
  t.symbol,
  NULL::text AS decimals,
  NULL::text AS decimals_raw,
  NULL::text AS token_uri
FROM indexer_evm_bnb_testnet.raw_registry_external_token_created t;

-- Service-role-only access
REVOKE ALL ON TABLE indexer.vw_tokens_created FROM anon;
REVOKE ALL ON TABLE indexer.vw_tokens_created FROM authenticated;
GRANT SELECT ON TABLE indexer.vw_tokens_created TO service_role;

CREATE OR REPLACE VIEW indexer.vw_tokens_registered AS
SELECT
  'base-sepolia'::text AS chain,
  t.evt_block_number,
  t.evt_block_time,
  t.evt_tx_hash,
  t.evt_index,
  t.token_id,
  t.token_address,
  t.template_id,
  t.name,
  t.symbol
FROM indexer_evm_base_sepolia.raw_registry_token_registered t

UNION ALL

SELECT
  'bnb-testnet'::text AS chain,
  t.evt_block_number,
  t.evt_block_time,
  t.evt_tx_hash,
  t.evt_index,
  t.token_id,
  t.token_address,
  t.template_id,
  t.name,
  t.symbol
FROM indexer_evm_bnb_testnet.raw_registry_token_registered t;

-- Service-role-only access
REVOKE ALL ON TABLE indexer.vw_tokens_registered FROM anon;
REVOKE ALL ON TABLE indexer.vw_tokens_registered FROM authenticated;
GRANT SELECT ON TABLE indexer.vw_tokens_registered TO service_role;

CREATE OR REPLACE VIEW indexer.vw_uniswap_v3_lp_deposits AS
SELECT
  'base-sepolia'::text AS chain,
  t.evt_block_number,
  t.evt_block_time,
  t.evt_tx_hash,
  t.evt_index,
  t.pool,
  t.owner,
  t.sender,
  t.tick_lower::text AS tick_lower,
  t.tick_upper::text AS tick_upper,
  t.amount::text AS liquidity_amount,
  t.amount::text AS liquidity_amount_raw,
  t.amount0::text AS amount0,
  t.amount0::text AS amount0_raw,
  t.amount1::text AS amount1,
  t.amount1::text AS amount1_raw,
  t.token_address,
  t.token_layer_id
FROM indexer_evm_base_sepolia.raw_uniswap_v3_mint t

UNION ALL

SELECT
  'bnb-testnet'::text AS chain,
  t.evt_block_number,
  t.evt_block_time,
  t.evt_tx_hash,
  t.evt_index,
  t.pool,
  t.owner,
  t.sender,
  t.tick_lower::text AS tick_lower,
  t.tick_upper::text AS tick_upper,
  t.amount::text AS liquidity_amount,
  t.amount::text AS liquidity_amount_raw,
  t.amount0::text AS amount0,
  t.amount0::text AS amount0_raw,
  t.amount1::text AS amount1,
  t.amount1::text AS amount1_raw,
  t.token_address,
  t.token_layer_id
FROM indexer_evm_bnb_testnet.raw_uniswap_v3_mint t;

REVOKE ALL ON TABLE indexer.vw_uniswap_v3_lp_deposits FROM anon;
REVOKE ALL ON TABLE indexer.vw_uniswap_v3_lp_deposits FROM authenticated;
GRANT SELECT ON TABLE indexer.vw_uniswap_v3_lp_deposits TO service_role;

CREATE OR REPLACE VIEW indexer.vw_uniswap_v3_lp_withdrawals AS
SELECT
  'base-sepolia'::text AS chain,
  t.evt_block_number,
  t.evt_block_time,
  t.evt_tx_hash,
  t.evt_index,
  t.pool,
  t.owner,
  t.tick_lower::text AS tick_lower,
  t.tick_upper::text AS tick_upper,
  t.amount::text AS liquidity_amount,
  t.amount::text AS liquidity_amount_raw,
  t.amount0::text AS amount0,
  t.amount0::text AS amount0_raw,
  t.amount1::text AS amount1,
  t.amount1::text AS amount1_raw,
  t.token_address,
  t.token_layer_id
FROM indexer_evm_base_sepolia.raw_uniswap_v3_burn t

UNION ALL

SELECT
  'bnb-testnet'::text AS chain,
  t.evt_block_number,
  t.evt_block_time,
  t.evt_tx_hash,
  t.evt_index,
  t.pool,
  t.owner,
  t.tick_lower::text AS tick_lower,
  t.tick_upper::text AS tick_upper,
  t.amount::text AS liquidity_amount,
  t.amount::text AS liquidity_amount_raw,
  t.amount0::text AS amount0,
  t.amount0::text AS amount0_raw,
  t.amount1::text AS amount1,
  t.amount1::text AS amount1_raw,
  t.token_address,
  t.token_layer_id
FROM indexer_evm_bnb_testnet.raw_uniswap_v3_burn t;

REVOKE ALL ON TABLE indexer.vw_uniswap_v3_lp_withdrawals FROM anon;
REVOKE ALL ON TABLE indexer.vw_uniswap_v3_lp_withdrawals FROM authenticated;
GRANT SELECT ON TABLE indexer.vw_uniswap_v3_lp_withdrawals TO service_role;

CREATE OR REPLACE VIEW indexer.vw_launchpad_graduations AS
SELECT
  'base-sepolia'::text AS chain,
  t.evt_block_number,
  t.evt_block_time,
  t.evt_tx_hash,
  t.evt_index,
  t.token_layer_id,
  t.token_id,
  t.token_address,
  t.is_external,
  t.final_supply::text AS final_supply,
  t.final_supply::text AS final_supply_raw,
  t.final_reserves::text AS final_reserves,
  t.final_reserves::text AS final_reserves_raw
FROM indexer_evm_base_sepolia.raw_launchpad_graduation t

UNION ALL

SELECT
  'bnb-testnet'::text AS chain,
  t.evt_block_number,
  t.evt_block_time,
  t.evt_tx_hash,
  t.evt_index,
  t.token_layer_id,
  t.token_id,
  t.token_address,
  t.is_external,
  t.final_supply::text AS final_supply,
  t.final_supply::text AS final_supply_raw,
  t.final_reserves::text AS final_reserves,
  t.final_reserves::text AS final_reserves_raw
FROM indexer_evm_bnb_testnet.raw_launchpad_graduation t;

REVOKE ALL ON TABLE indexer.vw_launchpad_graduations FROM anon;
REVOKE ALL ON TABLE indexer.vw_launchpad_graduations FROM authenticated;
GRANT SELECT ON TABLE indexer.vw_launchpad_graduations TO service_role;

DROP VIEW IF EXISTS public.vw_token_candles;
DROP VIEW IF EXISTS public.vw_token_stats_current;
DROP VIEW IF EXISTS indexer.vw_token_candles;
DROP VIEW IF EXISTS indexer.vw_token_stats_current;

CREATE VIEW indexer.vw_token_candles AS
SELECT
  'base-sepolia'::text AS chain,
  c.token_layer_id,
  c.token_address,
  c.venue,
  c.candle_interval,
  c.bucket_start,
  c.bucket_end,
  c.open_price_usd::text AS open_price_usd,
  c.open_price_usd::text AS open_price_usd_raw,
  c.high_price_usd::text AS high_price_usd,
  c.high_price_usd::text AS high_price_usd_raw,
  c.low_price_usd::text AS low_price_usd,
  c.low_price_usd::text AS low_price_usd_raw,
  c.close_price_usd::text AS close_price_usd,
  c.close_price_usd::text AS close_price_usd_raw,
  c.volume_token::text AS volume_token,
  c.volume_token::text AS volume_token_raw,
  c.volume_usd::text AS volume_usd,
  c.volume_usd::text AS volume_usd_raw,
  c.trade_count::text AS trade_count,
  c.trade_count::text AS trade_count_raw
FROM indexer_evm_base_sepolia.vw_token_candles c

UNION ALL

SELECT
  'bnb-testnet'::text AS chain,
  c.token_layer_id,
  c.token_address,
  c.venue,
  c.candle_interval,
  c.bucket_start,
  c.bucket_end,
  c.open_price_usd::text AS open_price_usd,
  c.open_price_usd::text AS open_price_usd_raw,
  c.high_price_usd::text AS high_price_usd,
  c.high_price_usd::text AS high_price_usd_raw,
  c.low_price_usd::text AS low_price_usd,
  c.low_price_usd::text AS low_price_usd_raw,
  c.close_price_usd::text AS close_price_usd,
  c.close_price_usd::text AS close_price_usd_raw,
  c.volume_token::text AS volume_token,
  c.volume_token::text AS volume_token_raw,
  c.volume_usd::text AS volume_usd,
  c.volume_usd::text AS volume_usd_raw,
  c.trade_count::text AS trade_count,
  c.trade_count::text AS trade_count_raw
FROM indexer_evm_bnb_testnet.vw_token_candles c;

REVOKE ALL ON TABLE indexer.vw_token_candles FROM anon;
REVOKE ALL ON TABLE indexer.vw_token_candles FROM authenticated;
GRANT SELECT ON TABLE indexer.vw_token_candles TO service_role;

CREATE OR REPLACE VIEW indexer.vw_fee_leaderboard_by_chain AS
SELECT
  'base-sepolia'::text AS chain,
  l.rank,
  l.wallet,
  l.currency,
  l.balance::text AS balance,
  l.balance_raw::text AS balance_raw,
  l.evt_block_number,
  l.evt_block_time
FROM indexer_evm_base_sepolia.vw_fee_leaderboard_current l

UNION ALL

SELECT
  'bnb-testnet'::text AS chain,
  l.rank,
  l.wallet,
  l.currency,
  l.balance::text AS balance,
  l.balance_raw::text AS balance_raw,
  l.evt_block_number,
  l.evt_block_time
FROM indexer_evm_bnb_testnet.vw_fee_leaderboard_current l;

REVOKE ALL ON TABLE indexer.vw_fee_leaderboard_by_chain FROM anon;
REVOKE ALL ON TABLE indexer.vw_fee_leaderboard_by_chain FROM authenticated;
GRANT SELECT ON TABLE indexer.vw_fee_leaderboard_by_chain TO service_role;

CREATE OR REPLACE VIEW indexer.vw_fee_leaderboard_current AS
WITH wallet_balances AS (
  SELECT
    wallet,
    MIN(currency) AS currency,
    SUM(balance::numeric)::numeric AS balance,
    SUM(balance_raw::numeric)::numeric AS balance_raw,
    MAX(evt_block_number)::numeric AS evt_block_number,
    MAX(evt_block_time) AS evt_block_time
  FROM indexer.vw_fee_leaderboard_by_chain
  GROUP BY wallet
),
ranked AS (
  SELECT
    ROW_NUMBER() OVER (
      ORDER BY balance_raw DESC, evt_block_time DESC NULLS LAST, wallet ASC
    ) AS rank,
    wallet,
    currency,
    balance,
    balance_raw,
    evt_block_number,
    evt_block_time
  FROM wallet_balances
)
SELECT
  rank,
  wallet,
  currency,
  balance::text AS balance,
  balance_raw::text AS balance_raw,
  evt_block_number,
  evt_block_time
FROM ranked;

REVOKE ALL ON TABLE indexer.vw_fee_leaderboard_current FROM anon;
REVOKE ALL ON TABLE indexer.vw_fee_leaderboard_current FROM authenticated;
GRANT SELECT ON TABLE indexer.vw_fee_leaderboard_current TO service_role;

CREATE VIEW indexer.vw_token_stats_current AS
SELECT
  'base-sepolia'::text AS chain,
  s.token_layer_id,
  s.token_address,
  s.price_usd::text AS price_usd,
  s.market_cap_usd::text AS market_cap_usd,
  s.market_cap_change_5m_pct::text AS market_cap_change_5m_pct,
  s.market_cap_change_5m_abs::text AS market_cap_change_5m_abs,
  s.market_cap_change_1h_pct::text AS market_cap_change_1h_pct,
  s.market_cap_change_6h_pct::text AS market_cap_change_6h_pct,
  s.market_cap_change_24h_pct::text AS market_cap_change_24h_pct,
  s.market_cap_change_1h_abs::text AS market_cap_change_1h_abs,
  s.market_cap_change_6h_abs::text AS market_cap_change_6h_abs,
  s.market_cap_change_24h_abs::text AS market_cap_change_24h_abs,
  s.price_change_5m_pct::text AS price_change_5m_pct,
  s.price_change_1h_pct::text AS price_change_1h_pct,
  s.price_change_6h_pct::text AS price_change_6h_pct,
  s.price_change_24h_pct::text AS price_change_24h_pct,
  s.price_change_5m_abs::text AS price_change_5m_abs,
  s.price_change_1h_abs::text AS price_change_1h_abs,
  s.price_change_6h_abs::text AS price_change_6h_abs,
  s.price_change_24h_abs::text AS price_change_24h_abs,
  s.volume_usd_5m::text AS volume_usd_5m,
  s.volume_usd_1h::text AS volume_usd_1h,
  s.volume_usd_6h::text AS volume_usd_6h,
  s.volume_usd_24h::text AS volume_usd_24h,
  s.volume_change_5m_abs::text AS volume_change_5m_abs,
  s.volume_change_1h_abs::text AS volume_change_1h_abs,
  s.volume_change_6h_abs::text AS volume_change_6h_abs,
  s.volume_change_24h_abs::text AS volume_change_24h_abs,
  s.volume_change_5m_pct::text AS volume_change_5m_pct,
  s.volume_change_1h_pct::text AS volume_change_1h_pct,
  s.volume_change_6h_pct::text AS volume_change_6h_pct,
  s.volume_change_24h_pct::text AS volume_change_24h_pct,
  s.holder_count::text AS holder_count,
  s.holder_count_change_5m_abs::text AS holder_count_change_5m_abs,
  s.holder_count_change_1h_abs::text AS holder_count_change_1h_abs,
  s.holder_count_change_6h_abs::text AS holder_count_change_6h_abs,
  s.holder_count_change_24h_abs::text AS holder_count_change_24h_abs,
  s.holder_count_change_5m_pct::text AS holder_count_change_5m_pct,
  s.holder_count_change_1h_pct::text AS holder_count_change_1h_pct,
  s.holder_count_change_6h_pct::text AS holder_count_change_6h_pct,
  s.holder_count_change_24h_pct::text AS holder_count_change_24h_pct,
  s.last_trade_at,
  s.last_trade_venue,
  s.launchpad_price_usd::text AS launchpad_price_usd,
  s.launchpad_supply::text AS launchpad_supply,
  s.launchpad_supply_raw::text AS launchpad_supply_raw,
  s.launchpad_tokens_left::text AS launchpad_tokens_left,
  s.launchpad_tokens_left_raw::text AS launchpad_tokens_left_raw,
  s.launchpad_liquidity_usd::text AS launchpad_liquidity_usd,
  s.launchpad_liquidity_usd_raw::text AS launchpad_liquidity_usd_raw,
  s.launchpad_progress_pct::text AS launchpad_progress_pct,
  s.launchpad_progress_change_5m_abs::text AS launchpad_progress_change_5m_abs,
  s.launchpad_progress_change_1h_abs::text AS launchpad_progress_change_1h_abs,
  s.launchpad_progress_change_6h_abs::text AS launchpad_progress_change_6h_abs,
  s.launchpad_progress_change_24h_abs::text AS launchpad_progress_change_24h_abs,
  s.launchpad_progress_change_5m_pct::text AS launchpad_progress_change_5m_pct,
  s.launchpad_progress_change_1h_pct::text AS launchpad_progress_change_1h_pct,
  s.launchpad_progress_change_6h_pct::text AS launchpad_progress_change_6h_pct,
  s.launchpad_progress_change_24h_pct::text AS launchpad_progress_change_24h_pct,
  s.evt_block_number,
  s.updated_at
FROM indexer_evm_base_sepolia.vw_token_market_current s

UNION ALL

SELECT
  'bnb-testnet'::text AS chain,
  s.token_layer_id,
  s.token_address,
  s.price_usd::text AS price_usd,
  s.market_cap_usd::text AS market_cap_usd,
  s.market_cap_change_5m_pct::text AS market_cap_change_5m_pct,
  s.market_cap_change_5m_abs::text AS market_cap_change_5m_abs,
  s.market_cap_change_1h_pct::text AS market_cap_change_1h_pct,
  s.market_cap_change_6h_pct::text AS market_cap_change_6h_pct,
  s.market_cap_change_24h_pct::text AS market_cap_change_24h_pct,
  s.market_cap_change_1h_abs::text AS market_cap_change_1h_abs,
  s.market_cap_change_6h_abs::text AS market_cap_change_6h_abs,
  s.market_cap_change_24h_abs::text AS market_cap_change_24h_abs,
  s.price_change_5m_pct::text AS price_change_5m_pct,
  s.price_change_1h_pct::text AS price_change_1h_pct,
  s.price_change_6h_pct::text AS price_change_6h_pct,
  s.price_change_24h_pct::text AS price_change_24h_pct,
  s.price_change_5m_abs::text AS price_change_5m_abs,
  s.price_change_1h_abs::text AS price_change_1h_abs,
  s.price_change_6h_abs::text AS price_change_6h_abs,
  s.price_change_24h_abs::text AS price_change_24h_abs,
  s.volume_usd_5m::text AS volume_usd_5m,
  s.volume_usd_1h::text AS volume_usd_1h,
  s.volume_usd_6h::text AS volume_usd_6h,
  s.volume_usd_24h::text AS volume_usd_24h,
  s.volume_change_5m_abs::text AS volume_change_5m_abs,
  s.volume_change_1h_abs::text AS volume_change_1h_abs,
  s.volume_change_6h_abs::text AS volume_change_6h_abs,
  s.volume_change_24h_abs::text AS volume_change_24h_abs,
  s.volume_change_5m_pct::text AS volume_change_5m_pct,
  s.volume_change_1h_pct::text AS volume_change_1h_pct,
  s.volume_change_6h_pct::text AS volume_change_6h_pct,
  s.volume_change_24h_pct::text AS volume_change_24h_pct,
  s.holder_count::text AS holder_count,
  s.holder_count_change_5m_abs::text AS holder_count_change_5m_abs,
  s.holder_count_change_1h_abs::text AS holder_count_change_1h_abs,
  s.holder_count_change_6h_abs::text AS holder_count_change_6h_abs,
  s.holder_count_change_24h_abs::text AS holder_count_change_24h_abs,
  s.holder_count_change_5m_pct::text AS holder_count_change_5m_pct,
  s.holder_count_change_1h_pct::text AS holder_count_change_1h_pct,
  s.holder_count_change_6h_pct::text AS holder_count_change_6h_pct,
  s.holder_count_change_24h_pct::text AS holder_count_change_24h_pct,
  s.last_trade_at,
  s.last_trade_venue,
  s.launchpad_price_usd::text AS launchpad_price_usd,
  s.launchpad_supply::text AS launchpad_supply,
  s.launchpad_supply_raw::text AS launchpad_supply_raw,
  s.launchpad_tokens_left::text AS launchpad_tokens_left,
  s.launchpad_tokens_left_raw::text AS launchpad_tokens_left_raw,
  s.launchpad_liquidity_usd::text AS launchpad_liquidity_usd,
  s.launchpad_liquidity_usd_raw::text AS launchpad_liquidity_usd_raw,
  s.launchpad_progress_pct::text AS launchpad_progress_pct,
  s.launchpad_progress_change_5m_abs::text AS launchpad_progress_change_5m_abs,
  s.launchpad_progress_change_1h_abs::text AS launchpad_progress_change_1h_abs,
  s.launchpad_progress_change_6h_abs::text AS launchpad_progress_change_6h_abs,
  s.launchpad_progress_change_24h_abs::text AS launchpad_progress_change_24h_abs,
  s.launchpad_progress_change_5m_pct::text AS launchpad_progress_change_5m_pct,
  s.launchpad_progress_change_1h_pct::text AS launchpad_progress_change_1h_pct,
  s.launchpad_progress_change_6h_pct::text AS launchpad_progress_change_6h_pct,
  s.launchpad_progress_change_24h_pct::text AS launchpad_progress_change_24h_pct,
  s.evt_block_number,
  s.updated_at
FROM indexer_evm_bnb_testnet.vw_token_market_current s;

REVOKE ALL ON TABLE indexer.vw_token_stats_current FROM anon;
REVOKE ALL ON TABLE indexer.vw_token_stats_current FROM authenticated;
GRANT SELECT ON TABLE indexer.vw_token_stats_current TO service_role;

CREATE OR REPLACE VIEW indexer.vw_token_activity AS
SELECT
  'base-sepolia'::text AS chain,
  a.activity_type,
  a.activity_subtype,
  a.evt_block_number,
  a.evt_block_time,
  a.tx_hash,
  a.evt_index,
  a.token_layer_id,
  a.token_id,
  a.token_address,
  a.wallet,
  a.from_address,
  a.to_address,
  a.token_amount_decimal::text AS token_amount,
  a.token_amount_raw::text AS token_amount_raw,
  a.usd_amount::text AS usd_amount,
  a.usd_amount_raw::text AS usd_amount_raw,
  a.price_usd::text AS price_usd,
  a.price_usd::text AS price_usd_raw,
  a.market_cap_usd::text AS market_cap_usd,
  a.market_cap_usd::text AS market_cap_usd_raw,
  a.pool,
  a.liquidity_amount::text AS liquidity_amount,
  a.liquidity_amount_raw::text AS liquidity_amount_raw,
  a.amount0_decimal::text AS amount0,
  a.amount0::text AS amount0_raw,
  a.amount1_decimal::text AS amount1,
  a.amount1::text AS amount1_raw,
  a.guid,
  a.src_eid::text AS src_eid,
  a.dst_eid::text AS dst_eid,
  a.is_external,
  a.final_supply::text AS final_supply,
  a.final_supply::text AS final_supply_raw,
  a.final_reserves::text AS final_reserves,
  a.final_reserves::text AS final_reserves_raw,
  a.token_decimals::text AS token_decimals,
  a.price_usd_at_event::text AS price_usd_at_event,
  a.price_usd_at_event::text AS price_usd_at_event_raw,
  a.usd_value::text AS usd_value,
  a.usd_value::text AS usd_value_raw
FROM indexer_evm_base_sepolia.vw_token_activity a

UNION ALL

SELECT
  'bnb-testnet'::text AS chain,
  a.activity_type,
  a.activity_subtype,
  a.evt_block_number,
  a.evt_block_time,
  a.tx_hash,
  a.evt_index,
  a.token_layer_id,
  a.token_id,
  a.token_address,
  a.wallet,
  a.from_address,
  a.to_address,
  a.token_amount_decimal::text AS token_amount,
  a.token_amount_raw::text AS token_amount_raw,
  a.usd_amount::text AS usd_amount,
  a.usd_amount_raw::text AS usd_amount_raw,
  a.price_usd::text AS price_usd,
  a.price_usd::text AS price_usd_raw,
  a.market_cap_usd::text AS market_cap_usd,
  a.market_cap_usd::text AS market_cap_usd_raw,
  a.pool,
  a.liquidity_amount::text AS liquidity_amount,
  a.liquidity_amount_raw::text AS liquidity_amount_raw,
  a.amount0_decimal::text AS amount0,
  a.amount0::text AS amount0_raw,
  a.amount1_decimal::text AS amount1,
  a.amount1::text AS amount1_raw,
  a.guid,
  a.src_eid::text AS src_eid,
  a.dst_eid::text AS dst_eid,
  a.is_external,
  a.final_supply::text AS final_supply,
  a.final_supply::text AS final_supply_raw,
  a.final_reserves::text AS final_reserves,
  a.final_reserves::text AS final_reserves_raw,
  a.token_decimals::text AS token_decimals,
  a.price_usd_at_event::text AS price_usd_at_event,
  a.price_usd_at_event::text AS price_usd_at_event_raw,
  a.usd_value::text AS usd_value,
  a.usd_value::text AS usd_value_raw
FROM indexer_evm_bnb_testnet.vw_token_activity a;

REVOKE ALL ON TABLE indexer.vw_token_activity FROM anon;
REVOKE ALL ON TABLE indexer.vw_token_activity FROM authenticated;
GRANT SELECT ON TABLE indexer.vw_token_activity TO service_role;

CREATE OR REPLACE VIEW indexer.vw_token_activity_desc AS
SELECT *
FROM indexer.vw_token_activity
ORDER BY evt_block_number DESC, evt_index DESC;

REVOKE ALL ON TABLE indexer.vw_token_activity_desc FROM anon;
REVOKE ALL ON TABLE indexer.vw_token_activity_desc FROM authenticated;
GRANT SELECT ON TABLE indexer.vw_token_activity_desc TO service_role;

-- Public-schema mirrors (same shape, single-source logic from indexer schema)
CREATE OR REPLACE VIEW public.vw_token_trades AS
SELECT * FROM indexer.vw_token_trades;
REVOKE ALL ON TABLE public.vw_token_trades FROM anon;
REVOKE ALL ON TABLE public.vw_token_trades FROM authenticated;
GRANT SELECT ON TABLE public.vw_token_trades TO service_role;

CREATE OR REPLACE VIEW public.vw_wallet_token_balances_current AS
SELECT * FROM indexer.vw_wallet_token_balances_current;
REVOKE ALL ON TABLE public.vw_wallet_token_balances_current FROM anon;
REVOKE ALL ON TABLE public.vw_wallet_token_balances_current FROM authenticated;
GRANT SELECT ON TABLE public.vw_wallet_token_balances_current TO service_role;

CREATE OR REPLACE VIEW public.vw_token_transfers_local AS
SELECT * FROM indexer.vw_token_transfers_local;
REVOKE ALL ON TABLE public.vw_token_transfers_local FROM anon;
REVOKE ALL ON TABLE public.vw_token_transfers_local FROM authenticated;
GRANT SELECT ON TABLE public.vw_token_transfers_local TO service_role;

CREATE OR REPLACE VIEW public.vw_token_transfers_cross_chain AS
SELECT * FROM indexer.vw_token_transfers_cross_chain;
REVOKE ALL ON TABLE public.vw_token_transfers_cross_chain FROM anon;
REVOKE ALL ON TABLE public.vw_token_transfers_cross_chain FROM authenticated;
GRANT SELECT ON TABLE public.vw_token_transfers_cross_chain TO service_role;

CREATE OR REPLACE VIEW public.vw_token_transfers AS
SELECT * FROM indexer.vw_token_transfers;
REVOKE ALL ON TABLE public.vw_token_transfers FROM anon;
REVOKE ALL ON TABLE public.vw_token_transfers FROM authenticated;
GRANT SELECT ON TABLE public.vw_token_transfers TO service_role;

CREATE OR REPLACE VIEW public.vw_tokens_created AS
SELECT * FROM indexer.vw_tokens_created;
REVOKE ALL ON TABLE public.vw_tokens_created FROM anon;
REVOKE ALL ON TABLE public.vw_tokens_created FROM authenticated;
GRANT SELECT ON TABLE public.vw_tokens_created TO service_role;

CREATE OR REPLACE VIEW public.vw_tokens_registered AS
SELECT * FROM indexer.vw_tokens_registered;
REVOKE ALL ON TABLE public.vw_tokens_registered FROM anon;
REVOKE ALL ON TABLE public.vw_tokens_registered FROM authenticated;
GRANT SELECT ON TABLE public.vw_tokens_registered TO service_role;

CREATE OR REPLACE VIEW public.vw_uniswap_v3_lp_deposits AS
SELECT * FROM indexer.vw_uniswap_v3_lp_deposits;
REVOKE ALL ON TABLE public.vw_uniswap_v3_lp_deposits FROM anon;
REVOKE ALL ON TABLE public.vw_uniswap_v3_lp_deposits FROM authenticated;
GRANT SELECT ON TABLE public.vw_uniswap_v3_lp_deposits TO service_role;

CREATE OR REPLACE VIEW public.vw_uniswap_v3_lp_withdrawals AS
SELECT * FROM indexer.vw_uniswap_v3_lp_withdrawals;
REVOKE ALL ON TABLE public.vw_uniswap_v3_lp_withdrawals FROM anon;
REVOKE ALL ON TABLE public.vw_uniswap_v3_lp_withdrawals FROM authenticated;
GRANT SELECT ON TABLE public.vw_uniswap_v3_lp_withdrawals TO service_role;

CREATE OR REPLACE VIEW public.vw_launchpad_graduations AS
SELECT * FROM indexer.vw_launchpad_graduations;
REVOKE ALL ON TABLE public.vw_launchpad_graduations FROM anon;
REVOKE ALL ON TABLE public.vw_launchpad_graduations FROM authenticated;
GRANT SELECT ON TABLE public.vw_launchpad_graduations TO service_role;

CREATE VIEW public.vw_token_candles AS
SELECT * FROM indexer.vw_token_candles;
REVOKE ALL ON TABLE public.vw_token_candles FROM anon;
REVOKE ALL ON TABLE public.vw_token_candles FROM authenticated;
GRANT SELECT ON TABLE public.vw_token_candles TO service_role;

CREATE OR REPLACE VIEW public.vw_fee_leaderboard_by_chain AS
SELECT * FROM indexer.vw_fee_leaderboard_by_chain;
REVOKE ALL ON TABLE public.vw_fee_leaderboard_by_chain FROM anon;
REVOKE ALL ON TABLE public.vw_fee_leaderboard_by_chain FROM authenticated;
GRANT SELECT ON TABLE public.vw_fee_leaderboard_by_chain TO service_role;

CREATE OR REPLACE VIEW public.vw_fee_leaderboard_current AS
SELECT * FROM indexer.vw_fee_leaderboard_current;
REVOKE ALL ON TABLE public.vw_fee_leaderboard_current FROM anon;
REVOKE ALL ON TABLE public.vw_fee_leaderboard_current FROM authenticated;
GRANT SELECT ON TABLE public.vw_fee_leaderboard_current TO service_role;

CREATE OR REPLACE VIEW public.vw_token_activity AS
SELECT * FROM indexer.vw_token_activity;
REVOKE ALL ON TABLE public.vw_token_activity FROM anon;
REVOKE ALL ON TABLE public.vw_token_activity FROM authenticated;
GRANT SELECT ON TABLE public.vw_token_activity TO service_role;

CREATE OR REPLACE VIEW public.vw_token_activity_desc AS
SELECT * FROM indexer.vw_token_activity_desc;
REVOKE ALL ON TABLE public.vw_token_activity_desc FROM anon;
REVOKE ALL ON TABLE public.vw_token_activity_desc FROM authenticated;
GRANT SELECT ON TABLE public.vw_token_activity_desc TO service_role;

CREATE VIEW public.vw_token_stats_current AS
SELECT * FROM indexer.vw_token_stats_current;
REVOKE ALL ON TABLE public.vw_token_stats_current FROM anon;
REVOKE ALL ON TABLE public.vw_token_stats_current FROM authenticated;
GRANT SELECT ON TABLE public.vw_token_stats_current TO service_role;
