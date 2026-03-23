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
FROM indexer_evm_bnb_testnet.cur_wallet_token_balance t

UNION ALL

SELECT
  'solana-devnet'::text AS chain,
  t.evt_block_number,
  t.evt_block_time,
  t.wallet,
  t.token_address,
  t.token_layer_id,
  t.balance::text AS balance,
  t.balance::text AS balance_raw
FROM indexer_sol_solana_devnet.cur_wallet_token_balance t;

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

CREATE OR REPLACE VIEW indexer.vw_cross_chain_transaction_progress AS
WITH source_events AS (
  SELECT
    'base-sepolia'::text AS chain,
    'token_registered_externally'::text AS operation_type,
    t.evt_block_number,
    t.evt_block_time,
    t.evt_tx_hash AS src_trx,
    t.evt_index,
    t.token_id,
    t.src_eid::text AS src_eid,
    t.dst_eid::text AS dst_eid,
    NULL::text AS amount,
    NULL::text AS price_in_wei,
    t.operation_id::text AS operation_id
  FROM indexer_evm_base_sepolia.raw_oapp_token_registered_externally t

  UNION ALL

  SELECT
    'base-sepolia'::text AS chain,
    'token_liquidity_initialized_externally'::text AS operation_type,
    t.evt_block_number,
    t.evt_block_time,
    t.evt_tx_hash AS src_trx,
    t.evt_index,
    t.token_id,
    t.src_eid::text AS src_eid,
    t.dst_eid::text AS dst_eid,
    t.amount::text AS amount,
    t.price_in_wei::text AS price_in_wei,
    NULL::text AS operation_id
  FROM indexer_evm_base_sepolia.raw_oapp_token_liquidity_initialized_externally t

  UNION ALL

  SELECT
    'bnb-testnet'::text AS chain,
    'token_registered_externally'::text AS operation_type,
    t.evt_block_number,
    t.evt_block_time,
    t.evt_tx_hash AS src_trx,
    t.evt_index,
    t.token_id,
    t.src_eid::text AS src_eid,
    t.dst_eid::text AS dst_eid,
    NULL::text AS amount,
    NULL::text AS price_in_wei,
    t.operation_id::text AS operation_id
  FROM indexer_evm_bnb_testnet.raw_oapp_token_registered_externally t

  UNION ALL

  SELECT
    'bnb-testnet'::text AS chain,
    'token_liquidity_initialized_externally'::text AS operation_type,
    t.evt_block_number,
    t.evt_block_time,
    t.evt_tx_hash AS src_trx,
    t.evt_index,
    t.token_id,
    t.src_eid::text AS src_eid,
    t.dst_eid::text AS dst_eid,
    t.amount::text AS amount,
    t.price_in_wei::text AS price_in_wei,
    NULL::text AS operation_id
  FROM indexer_evm_bnb_testnet.raw_oapp_token_liquidity_initialized_externally t
)
SELECT
  s.chain,
  s.operation_type,
  s.evt_block_number,
  s.evt_block_time,
  s.src_trx,
  s.evt_index,
  s.token_id,
  s.src_eid,
  s.dst_eid,
  s.amount,
  s.price_in_wei,
  s.operation_id,
  (c.id IS NOT NULL) AS is_tracked,
  c.id AS cross_chain_transaction_id,
  c.status AS progress_status,
  c.sent_at,
  c.last_checked_at,
  c.last_clearing_attempt_at,
  c.clearing_attempts,
  c.delivered_tx_hash,
  c.cleared_tx_signature,
  c.lz_guid,
  c.lz_nonce,
  c.error_message,
  c.payload_size,
  c.compute_units_used,
  c.created_at AS tracked_created_at,
  c.updated_at AS tracked_updated_at
FROM source_events s
LEFT JOIN public.cross_chain_transactions c
  ON lower(c.src_tx_hash) = lower(s.src_trx)
 AND c.src_eid::text = s.src_eid
 AND c.dst_eid::text = s.dst_eid;

REVOKE ALL ON TABLE indexer.vw_cross_chain_transaction_progress FROM anon;
REVOKE ALL ON TABLE indexer.vw_cross_chain_transaction_progress FROM authenticated;
GRANT SELECT ON TABLE indexer.vw_cross_chain_transaction_progress TO service_role;

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
FROM indexer_evm_bnb_testnet.raw_registry_token_registered t

UNION ALL

SELECT
  'solana-devnet'::text AS chain,
  t.block_slot::numeric AS evt_block_number,
  t.evt_block_time,
  t.trx_hash AS evt_tx_hash,
  t.row_index::numeric AS evt_index,
  t.token_layer_id AS token_id,
  (t.message_decoded_json::jsonb -> 'token_key' ->> 'token_address_hex')::text AS token_address,
  NULL::text AS template_id,
  (t.message_decoded_json::jsonb ->> 'name')::text AS name,
  (t.message_decoded_json::jsonb ->> 'symbol')::text AS symbol
FROM indexer_sol_solana_devnet.raw_registry_lzreceive_instruction t
WHERE t.message_type_label = 'register_token'
  AND t.token_layer_id IS NOT NULL
  AND btrim(t.token_layer_id) <> '';

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

DROP VIEW IF EXISTS public.vw_launchpad_graduations;
DROP VIEW IF EXISTS indexer.vw_launchpad_graduations;

CREATE VIEW indexer.vw_launchpad_graduations AS
SELECT
  'base-sepolia'::text AS chain,
  t.evt_block_number,
  t.evt_block_time,
  t.evt_tx_hash,
  t.evt_index,
  t.token_layer_id,
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

CREATE OR REPLACE VIEW indexer.vw_dex_pools AS
SELECT
  'base-sepolia'::text AS chain,
  'uniswap_v3'::text AS dex,
  t.evt_block_number,
  t.evt_block_time,
  t.evt_tx_hash AS tx_hash,
  t.evt_index,
  t.pool AS contract_address,
  t.pool AS pool_address,
  t.token_layer_id,
  t.token_address,
  t.token0 AS token_a_address,
  t.token1 AS token_b_address,
  NULL::text AS token_a_token_layer_id,
  NULL::text AS token_b_token_layer_id,
  t.fee::text AS fee,
  t.sqrt_price_x96::text AS initial_price
FROM indexer_evm_base_sepolia.raw_uniswap_v3_pool_created t

UNION ALL

SELECT
  'bnb-testnet'::text AS chain,
  'pancakeswap_v3'::text AS dex,
  t.evt_block_number,
  t.evt_block_time,
  t.evt_tx_hash AS tx_hash,
  t.evt_index,
  t.pool AS contract_address,
  t.pool AS pool_address,
  t.token_layer_id,
  t.token_address,
  t.token0 AS token_a_address,
  t.token1 AS token_b_address,
  NULL::text AS token_a_token_layer_id,
  NULL::text AS token_b_token_layer_id,
  t.fee::text AS fee,
  t.sqrt_price_x96::text AS initial_price
FROM indexer_evm_bnb_testnet.raw_uniswap_v3_pool_created t

UNION ALL

SELECT
  'solana-devnet'::text AS chain,
  'meteora_damm_v2'::text AS dex,
  t.block_slot::numeric AS evt_block_number,
  t.evt_block_time,
  t.trx_hash AS tx_hash,
  t.row_index::numeric AS evt_index,
  t.pool AS contract_address,
  t.pool AS pool_address,
  t.token_layer_id,
  t.token_mint AS token_address,
  t.token_a_mint AS token_a_address,
  t.token_b_mint AS token_b_address,
  t.token_a_token_layer_id,
  t.token_b_token_layer_id,
  NULL::text AS fee,
  t.sqrt_price AS initial_price
FROM indexer_sol_solana_devnet.raw_meteora_damm_v2_pool_created t;

REVOKE ALL ON TABLE indexer.vw_dex_pools FROM anon;
REVOKE ALL ON TABLE indexer.vw_dex_pools FROM authenticated;
GRANT SELECT ON TABLE indexer.vw_dex_pools TO service_role;

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
  l.evt_block_time,
  uw.user_id,
  up.username,
  up.profile_picture
FROM indexer_evm_base_sepolia.vw_fee_leaderboard_current l
LEFT JOIN public.user_wallets uw
  ON lower(uw.address) = lower(l.wallet)
LEFT JOIN public.user_profiles up
  ON up.id = uw.user_id

UNION ALL

SELECT
  'bnb-testnet'::text AS chain,
  l.rank,
  l.wallet,
  l.currency,
  l.balance::text AS balance,
  l.balance_raw::text AS balance_raw,
  l.evt_block_number,
  l.evt_block_time,
  uw.user_id,
  up.username,
  up.profile_picture
FROM indexer_evm_bnb_testnet.vw_fee_leaderboard_current l
LEFT JOIN public.user_wallets uw
  ON lower(uw.address) = lower(l.wallet)
LEFT JOIN public.user_profiles up
  ON up.id = uw.user_id;

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
  evt_block_time,
  uw.user_id,
  up.username,
  up.profile_picture
FROM ranked
LEFT JOIN public.user_wallets uw
  ON lower(uw.address) = lower(ranked.wallet)
LEFT JOIN public.user_profiles up
  ON up.id = uw.user_id;

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
  s.total_volume_token::text AS total_volume_token,
  s.total_volume_token_raw::text AS total_volume_token_raw,
  s.total_volume_usd::text AS total_volume_usd,
  s.total_volume_usd_raw::text AS total_volume_usd_raw,
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
  s.total_volume_token::text AS total_volume_token,
  s.total_volume_token_raw::text AS total_volume_token_raw,
  s.total_volume_usd::text AS total_volume_usd,
  s.total_volume_usd_raw::text AS total_volume_usd_raw,
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

DROP VIEW IF EXISTS public.vw_token_activity_desc;
DROP VIEW IF EXISTS indexer.vw_token_activity_desc;
DROP VIEW IF EXISTS public.vw_token_activity;
DROP VIEW IF EXISTS indexer.vw_token_activity;

CREATE VIEW indexer.vw_token_activity AS
WITH activity_union AS (
SELECT
  'base-sepolia'::text AS chain,
  a.activity_type,
  a.activity_subtype,
  a.evt_block_number,
  a.evt_block_time,
  a.tx_hash,
  a.evt_index,
  a.token_layer_id,
  a.token_address,
  a.wallet,
  a.trader,
  a.receiver,
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
  a.token_address,
  a.wallet,
  a.trader,
  a.receiver,
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
FROM indexer_evm_bnb_testnet.vw_token_activity a

UNION ALL

SELECT
  'solana-devnet'::text AS chain,
  a.activity_type,
  a.activity_subtype,
  a.evt_block_number,
  a.evt_block_time,
  a.tx_hash,
  a.evt_index,
  a.token_layer_id,
  a.token_address,
  a.wallet,
  NULL::text AS trader,
  NULL::text AS receiver,
  a.from_address,
  a.to_address,
  a.token_amount::text AS token_amount,
  a.token_amount_raw::text AS token_amount_raw,
  a.usd_amount::text AS usd_amount,
  a.usd_amount_raw::text AS usd_amount_raw,
  a.price_usd::text AS price_usd,
  a.price_usd::text AS price_usd_raw,
  a.market_cap_usd::text AS market_cap_usd,
  a.market_cap_usd::text AS market_cap_usd_raw,
  a.pool,
  a.liquidity_amount::text AS liquidity_amount,
  a.liquidity_amount::text AS liquidity_amount_raw,
  a.amount0::text AS amount0,
  a.amount0::text AS amount0_raw,
  a.amount1::text AS amount1,
  a.amount1::text AS amount1_raw,
  a.guid,
  a.src_eid::text AS src_eid,
  a.dst_eid::text AS dst_eid,
  NULL::boolean AS is_external,
  NULL::text AS final_supply,
  NULL::text AS final_supply_raw,
  NULL::text AS final_reserves,
  NULL::text AS final_reserves_raw,
  NULL::text AS token_decimals,
  a.price_usd_at_event::text AS price_usd_at_event,
  a.price_usd_at_event::text AS price_usd_at_event_raw,
  a.usd_value::text AS usd_value,
  a.usd_value::text AS usd_value_raw
FROM indexer_sol_solana_devnet.vw_token_activity a
)
SELECT
  CASE
    WHEN activity_type = 'trade' THEN
      concat_ws(':', chain, tx_hash, evt_index::text, COALESCE(activity_subtype, ''), COALESCE(token_layer_id, ''))
    WHEN activity_type = 'transfer' AND activity_subtype = 'local' THEN
      concat_ws(':', chain, tx_hash, evt_index::text, COALESCE(token_layer_id, ''), COALESCE(token_address, ''))
    WHEN activity_type = 'transfer' AND activity_subtype = 'cross_chain_sent' THEN
      concat_ws(':', chain, tx_hash, evt_index::text, COALESCE(guid, ''), 'sent')
    WHEN activity_type = 'transfer' AND activity_subtype = 'cross_chain_received' THEN
      concat_ws(':', chain, tx_hash, evt_index::text, COALESCE(guid, ''), 'received')
    WHEN activity_type = 'lp' AND activity_subtype = 'deposit' THEN
      concat_ws(':', chain, tx_hash, evt_index::text, COALESCE(pool, ''), 'mint')
    WHEN activity_type = 'lp' AND activity_subtype = 'withdrawal' THEN
      concat_ws(':', chain, tx_hash, evt_index::text, COALESCE(pool, ''), 'burn')
    WHEN activity_type = 'lifecycle' AND activity_subtype = 'token_created' THEN
      concat_ws(':', chain, tx_hash, evt_index::text, COALESCE(token_layer_id, ''), 'token_created')
    WHEN activity_type = 'lifecycle' AND activity_subtype = 'token_registered' THEN
      concat_ws(':', chain, tx_hash, evt_index::text, COALESCE(token_layer_id, ''), 'token_registered')
    WHEN activity_type = 'lifecycle' AND activity_subtype = 'external_token_created' THEN
      concat_ws(':', chain, tx_hash, evt_index::text, COALESCE(token_layer_id, ''), 'external_token_created')
    WHEN activity_type = 'lifecycle' AND activity_subtype = 'graduation' THEN
      concat_ws(':', chain, tx_hash, evt_index::text, COALESCE(token_layer_id, ''), 'graduation')
    ELSE
      concat_ws(':', chain, COALESCE(activity_type, ''), COALESCE(activity_subtype, ''), COALESCE(tx_hash, ''), evt_index::text)
  END AS pk,
  activity_union.*
FROM activity_union
ORDER BY evt_block_time DESC NULLS LAST, chain ASC, evt_block_number DESC, evt_index DESC, tx_hash DESC;

REVOKE ALL ON TABLE indexer.vw_token_activity FROM anon;
REVOKE ALL ON TABLE indexer.vw_token_activity FROM authenticated;
GRANT SELECT ON TABLE indexer.vw_token_activity TO service_role;

CREATE OR REPLACE VIEW indexer.vw_token_about
WITH (security_invoker = false) AS
SELECT
  t.id,
  t.id AS token_id,
  t.external_id,
  t.external_provider_id,
  t.name,
  t.symbol,
  t.slug,
  t.description,
  t.logo,
  t.banner_url,
  t.video_url,
  t.graduated,
  t.graduated_at,
  t.token_layer_id,
  t.origin_endpoint_id,
  t.origin_chain,
  t.builder_code,
  t.created_at,
  t.updated_at,
  address_summary.primary_evm_address,
  address_summary.primary_solana_address,
  COALESCE(token_addresses.token_addresses, '[]'::jsonb) AS token_addresses,
  COALESCE(registered_chains.registered_chains, '[]'::jsonb) AS registered_chains,
  COALESCE(dex_pools.dex_pools, '[]'::jsonb) AS dex_pools,
  COALESCE(token_addresses.token_address_count, 0) AS token_address_count,
  COALESCE(registered_chains.registered_chain_count, 0) AS registered_chain_count,
  COALESCE(dex_pools.dex_pool_count, 0) AS dex_pool_count
FROM public.tokens t
LEFT JOIN LATERAL (
  SELECT
    MAX(CASE WHEN ta.address_type = 'evm' THEN COALESCE(ta.address_display, ta.address) END) AS primary_evm_address,
    MAX(CASE WHEN ta.address_type = 'sol' THEN ta.address END) AS primary_solana_address
  FROM public.token_addresses ta
  WHERE ta.token_id = t.id
) address_summary ON TRUE
LEFT JOIN LATERAL (
  WITH indexer_registered_chains AS (
    SELECT DISTINCT chain
    FROM (
      SELECT c.chain
      FROM indexer.vw_tokens_created c
      WHERE t.token_layer_id IS NOT NULL
        AND c.token_id = t.token_layer_id

      UNION

      SELECT r.chain
      FROM indexer.vw_tokens_registered r
      WHERE t.token_layer_id IS NOT NULL
        AND r.token_id = t.token_layer_id
    ) chains
  )
  SELECT
    COUNT(*)::integer AS token_address_count,
    jsonb_agg(
      jsonb_build_object(
        'id', ta.id,
        'token_id', ta.token_id,
        'chain', ta.chain,
        'platform_name', ta.platform_name,
        'address', ta.address,
        'address_display', ta.address_display,
        'address_type', ta.address_type,
        'decimals', ta.decimals,
        'confirmed', ta.confirmed,
        'is_internal', ta.is_internal,
        'is_registered', (irc.chain IS NOT NULL),
        'stored_is_registered', ta.is_registered,
        'eid', ta.eid,
        'dex_name', ta.dex_name,
        'dex_address', ta.dex_address,
        'metadata', ta.metadata,
        'metadata_updated_at', ta.metadata_updated_at,
        'created_at', ta.created_at
      )
      ORDER BY ta.chain, ta.created_at, ta.id
    ) AS token_addresses
  FROM public.token_addresses ta
  LEFT JOIN indexer_registered_chains irc
    ON irc.chain = ta.chain
  WHERE ta.token_id = t.id
) token_addresses ON TRUE
LEFT JOIN LATERAL (
  WITH registration_rows AS (
    SELECT
      c.chain,
      INITCAP(REPLACE(c.chain, '-', ' ')) AS platform_name,
      LOWER(c.token_address) AS address,
      c.token_address AS address_display,
      CASE WHEN c.chain LIKE 'solana%' THEN 'sol' ELSE 'evm' END AS address_type,
      NULL::integer AS eid,
      TRUE AS is_registered,
      TRUE AS is_origin_chain,
      c.source_event,
      'indexer.vw_tokens_created'::text AS source
    FROM indexer.vw_tokens_created c
    WHERE t.token_layer_id IS NOT NULL
      AND c.token_id = t.token_layer_id

    UNION ALL

    SELECT
      r.chain,
      INITCAP(REPLACE(r.chain, '-', ' ')) AS platform_name,
      LOWER(r.token_address) AS address,
      r.token_address AS address_display,
      CASE WHEN r.chain LIKE 'solana%' THEN 'sol' ELSE 'evm' END AS address_type,
      NULL::integer AS eid,
      TRUE AS is_registered,
      FALSE AS is_origin_chain,
      'registry_token_registered'::text AS source_event,
      'indexer.vw_tokens_registered'::text AS source
    FROM indexer.vw_tokens_registered r
    WHERE t.token_layer_id IS NOT NULL
      AND r.token_id = t.token_layer_id
  ),
  grouped AS (
    SELECT
      rr.chain,
      MAX(rr.platform_name) AS platform_name,
      MAX(rr.address) AS address,
      MAX(rr.address_display) AS address_display,
      MAX(rr.address_type) AS address_type,
      MAX(rr.eid) AS eid,
      BOOL_OR(rr.is_registered) AS is_registered,
      BOOL_OR(rr.is_origin_chain) AS is_origin_chain,
      to_jsonb(ARRAY_AGG(DISTINCT rr.source ORDER BY rr.source)) AS sources,
      to_jsonb(ARRAY_AGG(DISTINCT rr.source_event ORDER BY rr.source_event)) AS source_events
    FROM registration_rows rr
    GROUP BY rr.chain
  )
  SELECT
    COUNT(*)::integer AS registered_chain_count,
    jsonb_agg(
      jsonb_build_object(
        'chain', g.chain,
        'platform_name', g.platform_name,
        'address', g.address,
        'address_display', g.address_display,
        'address_type', g.address_type,
        'eid', g.eid,
        'is_registered', g.is_registered,
        'is_origin_chain', g.is_origin_chain,
        'sources', g.sources,
        'source_events', g.source_events
      )
      ORDER BY g.chain
    ) AS registered_chains
  FROM grouped g
) registered_chains ON TRUE
LEFT JOIN LATERAL (
  SELECT
    COUNT(*)::integer AS dex_pool_count,
    jsonb_agg(
      jsonb_build_object(
        'chain', dp.chain,
        'dex', dp.dex,
        'contract_address', dp.contract_address,
        'pool_address', dp.pool_address,
        'token_layer_id', dp.token_layer_id,
        'token_address', dp.token_address,
        'token_a_address', dp.token_a_address,
        'token_b_address', dp.token_b_address,
        'token_a_token_layer_id', dp.token_a_token_layer_id,
        'token_b_token_layer_id', dp.token_b_token_layer_id,
        'fee', dp.fee,
        'initial_price', dp.initial_price,
        'tx_hash', dp.tx_hash,
        'evt_block_number', dp.evt_block_number,
        'evt_block_time', dp.evt_block_time,
        'evt_index', dp.evt_index
      )
      ORDER BY dp.chain, dp.dex, dp.evt_block_time, dp.pool_address
    ) AS dex_pools
  FROM indexer.vw_dex_pools dp
  WHERE t.token_layer_id IS NOT NULL
    AND dp.token_layer_id = t.token_layer_id
) dex_pools ON TRUE;

REVOKE ALL ON TABLE indexer.vw_token_about FROM anon;
REVOKE ALL ON TABLE indexer.vw_token_about FROM authenticated;
GRANT SELECT ON TABLE indexer.vw_token_about TO service_role;

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

CREATE OR REPLACE VIEW public.vw_cross_chain_transaction_progress AS
SELECT * FROM indexer.vw_cross_chain_transaction_progress;
REVOKE ALL ON TABLE public.vw_cross_chain_transaction_progress FROM anon;
REVOKE ALL ON TABLE public.vw_cross_chain_transaction_progress FROM authenticated;
GRANT SELECT ON TABLE public.vw_cross_chain_transaction_progress TO service_role;

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

CREATE OR REPLACE VIEW public.vw_dex_pools AS
SELECT * FROM indexer.vw_dex_pools;
REVOKE ALL ON TABLE public.vw_dex_pools FROM anon;
REVOKE ALL ON TABLE public.vw_dex_pools FROM authenticated;
GRANT SELECT ON TABLE public.vw_dex_pools TO service_role;

CREATE VIEW public.vw_token_candles AS
SELECT * FROM indexer.vw_token_candles;
REVOKE ALL ON TABLE public.vw_token_candles FROM anon;
REVOKE ALL ON TABLE public.vw_token_candles FROM authenticated;
GRANT SELECT ON TABLE public.vw_token_candles TO service_role;

CREATE OR REPLACE FUNCTION public.get_token_candles_dense(
  p_token_id TEXT,
  p_candle_interval TEXT DEFAULT '15m',
  p_venue TEXT DEFAULT NULL,
  p_from_timestamp TIMESTAMPTZ DEFAULT NULL,
  p_to_timestamp TIMESTAMPTZ DEFAULT NULL,
  p_limit INTEGER DEFAULT 500,
  p_offset INTEGER DEFAULT 0,
  p_ascending BOOLEAN DEFAULT TRUE
) RETURNS TABLE (
  chain TEXT,
  token_layer_id TEXT,
  token_address TEXT,
  venue TEXT,
  candle_interval TEXT,
  bucket_start TIMESTAMP,
  bucket_end TIMESTAMP,
  open_price_usd TEXT,
  open_price_usd_raw TEXT,
  high_price_usd TEXT,
  high_price_usd_raw TEXT,
  low_price_usd TEXT,
  low_price_usd_raw TEXT,
  close_price_usd TEXT,
  close_price_usd_raw TEXT,
  volume_token TEXT,
  volume_token_raw TEXT,
  volume_usd TEXT,
  volume_usd_raw TEXT,
  trade_count TEXT,
  trade_count_raw TEXT
)
LANGUAGE sql
STABLE
AS $$
WITH params AS (
  SELECT
    lower(btrim(p_token_id)) AS token_identifier,
    COALESCE(NULLIF(btrim(p_candle_interval), ''), '15m') AS candle_interval,
    NULLIF(btrim(p_venue), '') AS venue,
    p_from_timestamp AS from_timestamp,
    p_to_timestamp AS to_timestamp,
    GREATEST(COALESCE(p_limit, 500), 1) AS limit_rows,
    GREATEST(COALESCE(p_offset, 0), 0) AS offset_rows,
    COALESCE(p_ascending, TRUE) AS ascending
),
interval_config AS (
  SELECT
    params.*,
    CASE
      WHEN params.from_timestamp IS NULL THEN NULL::timestamp
      ELSE params.from_timestamp AT TIME ZONE 'UTC'
    END AS from_timestamp_utc,
    CASE
      WHEN params.to_timestamp IS NULL THEN NULL::timestamp
      ELSE params.to_timestamp AT TIME ZONE 'UTC'
    END AS to_timestamp_utc,
    CASE params.candle_interval
      WHEN '1m' THEN INTERVAL '1 minute'
      WHEN '5m' THEN INTERVAL '5 minutes'
      WHEN '15m' THEN INTERVAL '15 minutes'
      WHEN '1h' THEN INTERVAL '1 hour'
      WHEN '4h' THEN INTERVAL '4 hours'
      WHEN '1d' THEN INTERVAL '1 day'
      ELSE INTERVAL '15 minutes'
    END AS bucket_size
  FROM params
),
filtered AS (
  SELECT c.*
  FROM public.vw_token_candles c
  CROSS JOIN interval_config ic
  WHERE c.candle_interval = ic.candle_interval
    AND (
      lower(COALESCE(c.token_layer_id, '')) = ic.token_identifier
      OR lower(COALESCE(c.token_address, '')) = ic.token_identifier
    )
    AND (ic.venue IS NULL OR c.venue = ic.venue)
),
partitions AS (
  SELECT
    f.chain,
    f.token_layer_id,
    f.token_address,
    f.venue,
    f.candle_interval,
    MIN(f.bucket_start) AS min_bucket_start,
    MAX(f.bucket_start) AS max_bucket_start
  FROM filtered f
  GROUP BY f.chain, f.token_layer_id, f.token_address, f.venue, f.candle_interval
),
bounds AS (
  SELECT
    p.chain,
    p.token_layer_id,
    p.token_address,
    p.venue,
    p.candle_interval,
    ic.bucket_size,
    CASE
      WHEN ic.from_timestamp_utc IS NOT NULL THEN GREATEST(
        date_bin(ic.bucket_size, ic.from_timestamp_utc, TIMESTAMP '2001-01-01'),
        p.min_bucket_start
      )
      WHEN ic.ascending THEN p.min_bucket_start + (ic.offset_rows * ic.bucket_size)
      ELSE GREATEST(
        p.max_bucket_start - ((ic.offset_rows + ic.limit_rows - 1) * ic.bucket_size),
        p.min_bucket_start
      )
    END AS start_bucket,
    CASE
      WHEN ic.to_timestamp_utc IS NOT NULL THEN LEAST(
        date_bin(ic.bucket_size, ic.to_timestamp_utc, TIMESTAMP '2001-01-01'),
        p.max_bucket_start
      )
      WHEN ic.ascending THEN LEAST(
        p.min_bucket_start + ((ic.offset_rows + ic.limit_rows - 1) * ic.bucket_size),
        p.max_bucket_start
      )
      ELSE p.max_bucket_start - (ic.offset_rows * ic.bucket_size)
    END AS end_bucket,
    ic.ascending,
    ic.limit_rows,
    ic.offset_rows,
    (ic.from_timestamp IS NULL AND ic.to_timestamp IS NULL) AS paging_baked_into_bounds
  FROM partitions p
  CROSS JOIN interval_config ic
),
series AS (
  SELECT
    b.chain,
    b.token_layer_id,
    b.token_address,
    b.venue,
    b.candle_interval,
    b.bucket_size,
    b.ascending,
    b.limit_rows,
    b.offset_rows,
    b.paging_baked_into_bounds,
    gs.bucket_start
  FROM bounds b
  CROSS JOIN LATERAL generate_series(b.start_bucket, b.end_bucket, b.bucket_size) AS gs(bucket_start)
  WHERE b.start_bucket <= b.end_bucket
),
resolved AS (
  SELECT
    s.chain,
    s.token_layer_id,
    s.token_address,
    s.venue,
    s.candle_interval,
    s.bucket_start,
    (s.bucket_start + s.bucket_size)::timestamp AS bucket_end,
    COALESCE(cur.open_price_usd, prev.close_price_usd) AS open_price_usd,
    COALESCE(cur.high_price_usd, prev.close_price_usd) AS high_price_usd,
    COALESCE(cur.low_price_usd, prev.close_price_usd) AS low_price_usd,
    COALESCE(cur.close_price_usd, prev.close_price_usd) AS close_price_usd,
    COALESCE(cur.volume_token, '0') AS volume_token,
    COALESCE(cur.volume_usd, '0') AS volume_usd,
    COALESCE(cur.trade_count, '0') AS trade_count,
    s.ascending,
    s.limit_rows,
    s.offset_rows,
    s.paging_baked_into_bounds
  FROM series s
  LEFT JOIN filtered cur
    ON cur.chain = s.chain
   AND cur.token_layer_id IS NOT DISTINCT FROM s.token_layer_id
   AND cur.token_address IS NOT DISTINCT FROM s.token_address
   AND cur.venue IS NOT DISTINCT FROM s.venue
   AND cur.candle_interval = s.candle_interval
   AND cur.bucket_start = s.bucket_start
  LEFT JOIN LATERAL (
    SELECT f.close_price_usd
    FROM filtered f
    WHERE f.chain = s.chain
      AND f.token_layer_id IS NOT DISTINCT FROM s.token_layer_id
      AND f.token_address IS NOT DISTINCT FROM s.token_address
      AND f.venue IS NOT DISTINCT FROM s.venue
      AND f.candle_interval = s.candle_interval
      AND f.bucket_start <= s.bucket_start
    ORDER BY f.bucket_start DESC
    LIMIT 1
  ) prev ON TRUE
),
ordered AS (
  SELECT
    r.*,
    ROW_NUMBER() OVER (
      ORDER BY
        CASE WHEN r.ascending THEN r.bucket_start END ASC,
        CASE WHEN NOT r.ascending THEN r.bucket_start END DESC
    ) AS row_num
  FROM resolved r
  WHERE r.open_price_usd IS NOT NULL
)
SELECT
  r.chain,
  r.token_layer_id,
  r.token_address,
  r.venue,
  r.candle_interval,
  r.bucket_start,
  r.bucket_end,
  r.open_price_usd,
  r.open_price_usd AS open_price_usd_raw,
  r.high_price_usd,
  r.high_price_usd AS high_price_usd_raw,
  r.low_price_usd,
  r.low_price_usd AS low_price_usd_raw,
  r.close_price_usd,
  r.close_price_usd AS close_price_usd_raw,
  r.volume_token,
  r.volume_token AS volume_token_raw,
  r.volume_usd,
  r.volume_usd AS volume_usd_raw,
  r.trade_count,
  r.trade_count AS trade_count_raw
FROM ordered r
WHERE r.paging_baked_into_bounds
   OR (
     r.row_num > (SELECT offset_rows FROM params)
     AND r.row_num <= ((SELECT offset_rows FROM params) + (SELECT limit_rows FROM params))
   )
ORDER BY
  CASE WHEN r.ascending THEN r.bucket_start END ASC,
  CASE WHEN NOT r.ascending THEN r.bucket_start END DESC;
$$;

REVOKE ALL ON FUNCTION public.get_token_candles_dense(TEXT, TEXT, TEXT, TIMESTAMPTZ, TIMESTAMPTZ, INTEGER, INTEGER, BOOLEAN) FROM anon;
REVOKE ALL ON FUNCTION public.get_token_candles_dense(TEXT, TEXT, TEXT, TIMESTAMPTZ, TIMESTAMPTZ, INTEGER, INTEGER, BOOLEAN) FROM authenticated;
GRANT EXECUTE ON FUNCTION public.get_token_candles_dense(TEXT, TEXT, TEXT, TIMESTAMPTZ, TIMESTAMPTZ, INTEGER, INTEGER, BOOLEAN) TO service_role;

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

CREATE OR REPLACE VIEW public.vw_token_about
WITH (security_invoker = false) AS
SELECT * FROM indexer.vw_token_about;
REVOKE ALL ON TABLE public.vw_token_about FROM anon;
REVOKE ALL ON TABLE public.vw_token_about FROM authenticated;
GRANT SELECT ON TABLE public.vw_token_about TO service_role;

CREATE VIEW public.vw_token_stats_current AS
SELECT * FROM indexer.vw_token_stats_current;
REVOKE ALL ON TABLE public.vw_token_stats_current FROM anon;
REVOKE ALL ON TABLE public.vw_token_stats_current FROM authenticated;
GRANT SELECT ON TABLE public.vw_token_stats_current TO service_role;
