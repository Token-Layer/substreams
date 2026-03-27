#!/usr/bin/env node

import fs from "node:fs";

const [registryPath, templatePath] = process.argv.slice(2);

if (!registryPath || !templatePath) {
  console.error(
    "Usage: node scripts/generate-indexer-global-sql.mjs <registry-json> <template-sql>",
  );
  process.exit(1);
}

const chains = JSON.parse(fs.readFileSync(registryPath, "utf8"));
const templateSql = fs.readFileSync(templatePath, "utf8");
const tailMarker = "CREATE OR REPLACE VIEW indexer.vw_token_about";
const tailIndex = templateSql.indexOf(tailMarker);

if (tailIndex === -1) {
  console.error(`Could not find marker "${tailMarker}" in ${templatePath}`);
  process.exit(1);
}

const staticTail = templateSql.slice(tailIndex).trimStart();
const activeChains = chains.filter((chain) => chain.enabled !== false);
const evmChains = activeChains.filter((chain) => chain.chain_type === "evm");
const solanaChains = activeChains.filter((chain) => chain.chain_type === "solana");

if (activeChains.length === 0) {
  console.error("No enabled indexer chains found in registry.");
  process.exit(1);
}

function lit(value) {
  return `'${String(value).replaceAll("'", "''")}'`;
}

function emptyView(columns) {
  return `SELECT\n${columns
    .map(([expr, alias]) => `  ${expr} AS ${alias}`)
    .join(",\n")}\nWHERE FALSE`;
}

function unionOrEmpty(selects, columns) {
  return selects.length > 0 ? selects.join("\n\nUNION ALL\n\n") : emptyView(columns);
}

function grantIndexerView(viewName) {
  return `REVOKE ALL ON TABLE indexer.${viewName} FROM anon;
REVOKE ALL ON TABLE indexer.${viewName} FROM authenticated;
GRANT SELECT ON TABLE indexer.${viewName} TO service_role;`;
}

const statements = [];
const generatedViewNames = [
  "vw_indexing_progress_by_chain",
  "vw_token_trades",
  "vw_wallet_token_balances_current",
  "vw_token_transfers_local",
  "vw_token_transfers_cross_chain",
  "vw_cross_chain_transaction_progress",
  "vw_token_transfers",
  "vw_tokens_created",
  "vw_tokens_registered",
  "vw_uniswap_v3_lp_deposits",
  "vw_uniswap_v3_lp_withdrawals",
  "vw_launchpad_graduations",
  "vw_dex_pools",
  "vw_token_candles",
  "vw_fee_leaderboard_by_chain",
  "vw_fee_leaderboard_current",
  "vw_user_fee_balances_by_chain",
  "vw_user_fee_balances_current",
  "vw_user_fee_distribution_history_by_chain",
  "vw_token_stats_current",
  "vw_token_activity_desc",
  "vw_token_activity",
  "vw_token_about",
];

statements.push("CREATE SCHEMA IF NOT EXISTS indexer;");
statements.push(
  ...generatedViewNames
    .map((name) => `DROP VIEW IF EXISTS public.${name};`)
    .concat(
      [...generatedViewNames]
        .reverse()
        .map((name) => `DROP VIEW IF EXISTS indexer.${name};`),
    ),
);

const indexingProgressSelects = activeChains.map((chain) => `SELECT
  ${lit(chain.chain)}::text AS chain,
  ${lit(chain.schema_name)}::text AS schema_name,
  ${lit(chain.chain_type)}::text AS chain_type,
  ${Number.isFinite(chain.sort_order) ? chain.sort_order : 1000}::integer AS sort_order,
  p.module,
  p.last_seen_block,
  p.last_seen_block_hash,
  p.last_seen_at,
  CASE
    WHEN p.last_seen_at IS NULL THEN NULL::double precision
    ELSE EXTRACT(EPOCH FROM (now() - p.last_seen_at))
  END AS seconds_since_last_seen
FROM (
  SELECT
    i.module,
    i.last_seen_block,
    i.last_seen_block_hash,
    i.last_seen_at
  FROM ${chain.schema_name}.indexing_progress i
  ORDER BY i.last_seen_block DESC NULLS LAST, i.last_seen_at DESC NULLS LAST, i.module ASC
  LIMIT 1
) p
RIGHT JOIN (
  SELECT 1 AS registered_chain
) r ON TRUE`);

statements.push(`CREATE OR REPLACE VIEW indexer.vw_indexing_progress_by_chain AS
${unionOrEmpty(indexingProgressSelects, [
  ["NULL::text", "chain"],
  ["NULL::text", "schema_name"],
  ["NULL::text", "chain_type"],
  ["NULL::integer", "sort_order"],
  ["NULL::text", "module"],
  ["NULL::numeric", "last_seen_block"],
  ["NULL::text", "last_seen_block_hash"],
  ["NULL::timestamp", "last_seen_at"],
  ["NULL::double precision", "seconds_since_last_seen"],
])};`);
statements.push(grantIndexerView("vw_indexing_progress_by_chain"));
statements.push(`CREATE OR REPLACE VIEW public.vw_indexing_progress_by_chain AS
SELECT * FROM indexer.vw_indexing_progress_by_chain;
REVOKE ALL ON TABLE public.vw_indexing_progress_by_chain FROM anon;
REVOKE ALL ON TABLE public.vw_indexing_progress_by_chain FROM authenticated;
GRANT SELECT ON TABLE public.vw_indexing_progress_by_chain TO service_role;`);

for (const chain of evmChains) {
  statements.push(
    `ALTER TABLE IF EXISTS ${chain.schema_name}.agg_token_trade
  ADD COLUMN IF NOT EXISTS token_layer_id TEXT;`,
  );
}

statements.push(`DO $$
BEGIN
${evmChains
  .map(
    (chain) => `  IF to_regclass(${lit(`${chain.schema_name}.agg_token_trade`)}) IS NOT NULL THEN
    EXECUTE ${lit(
      `CREATE INDEX IF NOT EXISTS idx_agg_token_trade_token_layer_id_${chain.chain.replaceAll("-", "_")} ON ${chain.schema_name}.agg_token_trade (token_layer_id)`,
    )};
  END IF;`,
  )
  .join("\n")}
END $$;`);

const tokenTradesSelects = evmChains.map((chain) => `SELECT
  ${lit(chain.chain)}::text AS chain,
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
FROM ${chain.schema_name}.agg_token_trade t`);

statements.push(`CREATE OR REPLACE VIEW indexer.vw_token_trades AS
${unionOrEmpty(tokenTradesSelects, [
  ["NULL::text", "chain"],
  ["NULL::numeric", "evt_block_number"],
  ["NULL::timestamp", "evt_block_time"],
  ["NULL::text", "evt_tx_hash"],
  ["NULL::numeric", "evt_index"],
  ["NULL::text", "venue"],
  ["NULL::text", "trade_type"],
  ["NULL::text", "wallet"],
  ["NULL::text", "token_address"],
  ["NULL::text", "token_layer_id"],
  ["NULL::text", "pool"],
  ["NULL::text", "token_amount"],
  ["NULL::text", "token_amount_raw"],
  ["NULL::text", "usd_amount"],
  ["NULL::text", "usd_amount_raw"],
  ["NULL::text", "price_usd"],
  ["NULL::text", "price_usd_raw"],
  ["NULL::text", "market_cap_usd"],
  ["NULL::text", "market_cap_usd_raw"],
  ["NULL::text", "token_decimals"],
  ["NULL::text", "quote_decimals"],
  ["NULL::text", "token_decimals_source"],
  ["NULL::text", "quote_decimals_source"],
])};`);
statements.push(grantIndexerView("vw_token_trades"));

const walletBalanceSelects = [
  ...evmChains.map((chain) => `SELECT
  ${lit(chain.chain)}::text AS chain,
  t.evt_block_number,
  t.evt_block_time,
  t.wallet,
  t.token_address,
  t.token_layer_id,
  t.balance::text AS balance,
  t.balance::text AS balance_raw
FROM ${chain.schema_name}.cur_wallet_token_balance t`),
  ...solanaChains.map((chain) => `SELECT
  ${lit(chain.chain)}::text AS chain,
  t.evt_block_number,
  t.evt_block_time,
  t.wallet,
  t.token_address,
  t.token_layer_id,
  t.balance::text AS balance,
  t.balance::text AS balance_raw
FROM ${chain.schema_name}.cur_wallet_token_balance t`),
];

statements.push(`CREATE OR REPLACE VIEW indexer.vw_wallet_token_balances_current AS
${unionOrEmpty(walletBalanceSelects, [
  ["NULL::text", "chain"],
  ["NULL::numeric", "evt_block_number"],
  ["NULL::timestamp", "evt_block_time"],
  ["NULL::text", "wallet"],
  ["NULL::text", "token_address"],
  ["NULL::text", "token_layer_id"],
  ["NULL::text", "balance"],
  ["NULL::text", "balance_raw"],
])};`);
statements.push(grantIndexerView("vw_wallet_token_balances_current"));

const localTransferSelects = [
  ...evmChains.map((chain) => `SELECT
  ${lit(chain.chain)}::text AS chain,
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
FROM ${chain.schema_name}.raw_token_coin_transfer t`),
  ...solanaChains.map((chain) => `SELECT
  ${lit(chain.chain)}::text AS chain,
  t.block_slot::numeric AS evt_block_number,
  t.evt_block_time,
  t.trx_hash AS evt_tx_hash,
  t.row_index::numeric AS evt_index,
  t.token_layer_id,
  t.token_mint AS token_address,
  t.from_owner AS from_address,
  t.to_owner AS to_address,
  t.amount::text AS amount,
  t.amount::text AS amount_raw
FROM ${chain.schema_name}.raw_token_transfer t`),
];

statements.push(`CREATE OR REPLACE VIEW indexer.vw_token_transfers_local AS
${unionOrEmpty(localTransferSelects, [
  ["NULL::text", "chain"],
  ["NULL::numeric", "evt_block_number"],
  ["NULL::timestamp", "evt_block_time"],
  ["NULL::text", "evt_tx_hash"],
  ["NULL::numeric", "evt_index"],
  ["NULL::text", "token_layer_id"],
  ["NULL::text", "token_address"],
  ["NULL::text", "from_address"],
  ["NULL::text", "to_address"],
  ["NULL::text", "amount"],
  ["NULL::text", "amount_raw"],
])};`);
statements.push(grantIndexerView("vw_token_transfers_local"));

const crossChainTransferSelects = evmChains.flatMap((chain) => [
  `SELECT
  ${lit(chain.chain)}::text AS chain,
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
FROM ${chain.schema_name}.raw_token_coin_oft_sent t`,
  `SELECT
  ${lit(chain.chain)}::text AS chain,
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
FROM ${chain.schema_name}.raw_token_coin_oft_received t`,
]);

statements.push(`CREATE OR REPLACE VIEW indexer.vw_token_transfers_cross_chain AS
${unionOrEmpty(crossChainTransferSelects, [
  ["NULL::text", "chain"],
  ["NULL::text", "transfer_type"],
  ["NULL::numeric", "evt_block_number"],
  ["NULL::timestamp", "evt_block_time"],
  ["NULL::text", "evt_tx_hash"],
  ["NULL::numeric", "evt_index"],
  ["NULL::text", "token_layer_id"],
  ["NULL::text", "token_address"],
  ["NULL::text", "from_address"],
  ["NULL::text", "to_address"],
  ["NULL::text", "amount"],
  ["NULL::text", "amount_raw"],
  ["NULL::text", "amount_received_ld"],
  ["NULL::text", "amount_received_ld_raw"],
  ["NULL::text", "guid"],
  ["NULL::text", "src_eid"],
  ["NULL::text", "dst_eid"],
])};`);
statements.push(grantIndexerView("vw_token_transfers_cross_chain"));

const progressSourceSelects = evmChains.flatMap((chain) => [
  `SELECT
    ${lit(chain.chain)}::text AS chain,
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
  FROM ${chain.schema_name}.raw_oapp_token_registered_externally t`,
  `SELECT
    ${lit(chain.chain)}::text AS chain,
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
  FROM ${chain.schema_name}.raw_oapp_token_liquidity_initialized_externally t`,
]);

statements.push(`CREATE OR REPLACE VIEW indexer.vw_cross_chain_transaction_progress AS
WITH source_events AS (
${unionOrEmpty(progressSourceSelects, [
  ["NULL::text", "chain"],
  ["NULL::text", "operation_type"],
  ["NULL::numeric", "evt_block_number"],
  ["NULL::timestamp", "evt_block_time"],
  ["NULL::text", "src_trx"],
  ["NULL::numeric", "evt_index"],
  ["NULL::text", "token_id"],
  ["NULL::text", "src_eid"],
  ["NULL::text", "dst_eid"],
  ["NULL::text", "amount"],
  ["NULL::text", "price_in_wei"],
  ["NULL::text", "operation_id"],
])}
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
 AND c.dst_eid::text = s.dst_eid;`);
statements.push(grantIndexerView("vw_cross_chain_transaction_progress"));

statements.push(`CREATE OR REPLACE VIEW indexer.vw_token_transfers AS
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
FROM indexer.vw_token_transfers_cross_chain

UNION ALL

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
FROM indexer.vw_token_transfers_local;`);
statements.push(grantIndexerView("vw_token_transfers"));

const tokensCreatedSelects = evmChains.flatMap((chain) => [
  `SELECT
  ${lit(chain.chain)}::text AS chain,
  'registry_token_created'::text AS source_event,
  t.evt_block_number,
  t.evt_block_time,
  t.evt_tx_hash,
  t.evt_index,
  t.token_id,
  t.token_address,
  NULL::text AS template_id,
  t.ip_id,
  t.name,
  t.symbol,
  t.decimals::text AS decimals,
  t.decimals::text AS decimals_raw,
  t.token_uri
FROM ${chain.schema_name}.raw_registry_token_created t`,
  `SELECT
  ${lit(chain.chain)}::text AS chain,
  'registry_external_token_created'::text AS source_event,
  t.evt_block_number,
  t.evt_block_time,
  t.evt_tx_hash,
  t.evt_index,
  t.token_id,
  t.token_address,
  NULL::text AS template_id,
  NULL::text AS ip_id,
  t.name,
  t.symbol,
  NULL::text AS decimals,
  NULL::text AS decimals_raw,
  NULL::text AS token_uri
FROM ${chain.schema_name}.raw_registry_external_token_created t`,
]);

statements.push(`CREATE OR REPLACE VIEW indexer.vw_tokens_created AS
${unionOrEmpty(tokensCreatedSelects, [
  ["NULL::text", "chain"],
  ["NULL::text", "source_event"],
  ["NULL::numeric", "evt_block_number"],
  ["NULL::timestamp", "evt_block_time"],
  ["NULL::text", "evt_tx_hash"],
  ["NULL::numeric", "evt_index"],
  ["NULL::text", "token_id"],
  ["NULL::text", "token_address"],
  ["NULL::text", "template_id"],
  ["NULL::text", "ip_id"],
  ["NULL::text", "name"],
  ["NULL::text", "symbol"],
  ["NULL::text", "decimals"],
  ["NULL::text", "decimals_raw"],
  ["NULL::text", "token_uri"],
])};`);
statements.push(grantIndexerView("vw_tokens_created"));

const tokensRegisteredSelects = [
  ...evmChains.map((chain) => `SELECT
  ${lit(chain.chain)}::text AS chain,
  t.evt_block_number,
  t.evt_block_time,
  t.evt_tx_hash,
  t.evt_index,
  t.token_id,
  t.token_address,
  NULL::text AS template_id,
  t.name,
  t.symbol
FROM ${chain.schema_name}.raw_registry_token_registered t`),
  ...solanaChains.map((chain) => `SELECT
  ${lit(chain.chain)}::text AS chain,
  t.block_slot::numeric AS evt_block_number,
  t.evt_block_time,
  t.trx_hash AS evt_tx_hash,
  t.row_index::numeric AS evt_index,
  t.token_layer_id AS token_id,
  (t.message_decoded_json::jsonb -> 'token_key' ->> 'token_address_hex')::text AS token_address,
  NULL::text AS template_id,
  (t.message_decoded_json::jsonb ->> 'name')::text AS name,
  (t.message_decoded_json::jsonb ->> 'symbol')::text AS symbol
FROM ${chain.schema_name}.raw_registry_lzreceive_instruction t
WHERE t.message_type_label = 'register_token'
  AND t.token_layer_id IS NOT NULL
  AND btrim(t.token_layer_id) <> ''`),
];

statements.push(`CREATE OR REPLACE VIEW indexer.vw_tokens_registered AS
${unionOrEmpty(tokensRegisteredSelects, [
  ["NULL::text", "chain"],
  ["NULL::numeric", "evt_block_number"],
  ["NULL::timestamp", "evt_block_time"],
  ["NULL::text", "evt_tx_hash"],
  ["NULL::numeric", "evt_index"],
  ["NULL::text", "token_id"],
  ["NULL::text", "token_address"],
  ["NULL::text", "template_id"],
  ["NULL::text", "name"],
  ["NULL::text", "symbol"],
])};`);
statements.push(grantIndexerView("vw_tokens_registered"));

const lpDepositSelects = evmChains.map((chain) => `SELECT
  ${lit(chain.chain)}::text AS chain,
  t.evt_block_number,
  t.evt_block_time,
  t.evt_tx_hash,
  t.evt_index,
  t.token_layer_id,
  t.token_address,
  t.pool,
  t.owner,
  t.sender,
  t.amount::text AS amount,
  t.amount0::text AS amount0,
  t.amount1::text AS amount1
FROM ${chain.schema_name}.raw_uniswap_v3_mint t`);

statements.push(`CREATE OR REPLACE VIEW indexer.vw_uniswap_v3_lp_deposits AS
${unionOrEmpty(lpDepositSelects, [
  ["NULL::text", "chain"],
  ["NULL::numeric", "evt_block_number"],
  ["NULL::timestamp", "evt_block_time"],
  ["NULL::text", "evt_tx_hash"],
  ["NULL::numeric", "evt_index"],
  ["NULL::text", "token_layer_id"],
  ["NULL::text", "token_address"],
  ["NULL::text", "pool"],
  ["NULL::text", "owner"],
  ["NULL::text", "sender"],
  ["NULL::text", "amount"],
  ["NULL::text", "amount0"],
  ["NULL::text", "amount1"],
])};`);
statements.push(grantIndexerView("vw_uniswap_v3_lp_deposits"));

const lpWithdrawalSelects = evmChains.map((chain) => `SELECT
  ${lit(chain.chain)}::text AS chain,
  t.evt_block_number,
  t.evt_block_time,
  t.evt_tx_hash,
  t.evt_index,
  t.token_layer_id,
  t.token_address,
  t.pool,
  t.owner,
  t.amount::text AS amount,
  t.amount0::text AS amount0,
  t.amount1::text AS amount1
FROM ${chain.schema_name}.raw_uniswap_v3_burn t`);

statements.push(`CREATE OR REPLACE VIEW indexer.vw_uniswap_v3_lp_withdrawals AS
${unionOrEmpty(lpWithdrawalSelects, [
  ["NULL::text", "chain"],
  ["NULL::numeric", "evt_block_number"],
  ["NULL::timestamp", "evt_block_time"],
  ["NULL::text", "evt_tx_hash"],
  ["NULL::numeric", "evt_index"],
  ["NULL::text", "token_layer_id"],
  ["NULL::text", "token_address"],
  ["NULL::text", "pool"],
  ["NULL::text", "owner"],
  ["NULL::text", "amount"],
  ["NULL::text", "amount0"],
  ["NULL::text", "amount1"],
])};`);
statements.push(grantIndexerView("vw_uniswap_v3_lp_withdrawals"));

statements.push(`DROP VIEW IF EXISTS public.vw_launchpad_graduations;
DROP VIEW IF EXISTS indexer.vw_launchpad_graduations;`);

const graduationSelects = evmChains.map((chain) => `SELECT
  ${lit(chain.chain)}::text AS chain,
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
FROM ${chain.schema_name}.raw_launchpad_graduation t`);

statements.push(`CREATE VIEW indexer.vw_launchpad_graduations AS
${unionOrEmpty(graduationSelects, [
  ["NULL::text", "chain"],
  ["NULL::numeric", "evt_block_number"],
  ["NULL::timestamp", "evt_block_time"],
  ["NULL::text", "evt_tx_hash"],
  ["NULL::numeric", "evt_index"],
  ["NULL::text", "token_layer_id"],
  ["NULL::text", "token_address"],
  ["NULL::boolean", "is_external"],
  ["NULL::text", "final_supply"],
  ["NULL::text", "final_supply_raw"],
  ["NULL::text", "final_reserves"],
  ["NULL::text", "final_reserves_raw"],
])};`);
statements.push(grantIndexerView("vw_launchpad_graduations"));

const dexPoolSelects = [
  ...evmChains.map((chain) => `SELECT
  ${lit(chain.chain)}::text AS chain,
  CASE
    WHEN ${lit(chain.chain)} IN ('bnb', 'bnb-testnet', 'op-bnb') THEN 'pancakeswap_v3'::text
    ELSE 'uniswap_v3'::text
  END AS dex,
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
FROM ${chain.schema_name}.raw_uniswap_v3_pool_created t`),
  ...solanaChains.map((chain) => `SELECT
  ${lit(chain.chain)}::text AS chain,
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
FROM ${chain.schema_name}.raw_meteora_damm_v2_pool_created t`),
];

statements.push(`CREATE OR REPLACE VIEW indexer.vw_dex_pools AS
${unionOrEmpty(dexPoolSelects, [
  ["NULL::text", "chain"],
  ["NULL::text", "dex"],
  ["NULL::numeric", "evt_block_number"],
  ["NULL::timestamp", "evt_block_time"],
  ["NULL::text", "tx_hash"],
  ["NULL::numeric", "evt_index"],
  ["NULL::text", "contract_address"],
  ["NULL::text", "pool_address"],
  ["NULL::text", "token_layer_id"],
  ["NULL::text", "token_address"],
  ["NULL::text", "token_a_address"],
  ["NULL::text", "token_b_address"],
  ["NULL::text", "token_a_token_layer_id"],
  ["NULL::text", "token_b_token_layer_id"],
  ["NULL::text", "fee"],
  ["NULL::text", "initial_price"],
])};`);
statements.push(grantIndexerView("vw_dex_pools"));

statements.push(`DROP VIEW IF EXISTS public.vw_token_candles;
DROP VIEW IF EXISTS public.vw_token_stats_current;
DROP VIEW IF EXISTS indexer.vw_token_candles;
DROP VIEW IF EXISTS indexer.vw_token_stats_current;`);

const tokenCandleSelects = evmChains.map((chain) => `SELECT
  ${lit(chain.chain)}::text AS chain,
  c.token_layer_id,
  c.token_address,
  c.venue,
  c.candle_interval,
  c.bucket_start,
  c.bucket_end,
  c.open_price_usd::text AS open_price_usd,
  c.high_price_usd::text AS high_price_usd,
  c.low_price_usd::text AS low_price_usd,
  c.close_price_usd::text AS close_price_usd,
  c.volume_token::text AS volume_token,
  NULL::text AS volume_token_raw,
  c.volume_usd::text AS volume_usd,
  NULL::text AS volume_usd_raw,
  c.trade_count::text AS trade_count,
  NULL::numeric AS last_evt_block_number,
  NULL::timestamp AS last_evt_block_time
FROM ${chain.schema_name}.vw_token_candles c`);

statements.push(`CREATE VIEW indexer.vw_token_candles AS
${unionOrEmpty(tokenCandleSelects, [
  ["NULL::text", "chain"],
  ["NULL::text", "token_layer_id"],
  ["NULL::text", "token_address"],
  ["NULL::text", "venue"],
  ["NULL::text", "candle_interval"],
  ["NULL::timestamp", "bucket_start"],
  ["NULL::timestamp", "bucket_end"],
  ["NULL::text", "open_price_usd"],
  ["NULL::text", "high_price_usd"],
  ["NULL::text", "low_price_usd"],
  ["NULL::text", "close_price_usd"],
  ["NULL::text", "volume_token"],
  ["NULL::text", "volume_token_raw"],
  ["NULL::text", "volume_usd"],
  ["NULL::text", "volume_usd_raw"],
  ["NULL::text", "trade_count"],
  ["NULL::numeric", "last_evt_block_number"],
  ["NULL::timestamp", "last_evt_block_time"],
])};`);
statements.push(grantIndexerView("vw_token_candles"));

const feeLeaderboardByChainSelects = evmChains.map((chain) => `SELECT
  ${lit(chain.chain)}::text AS chain,
  l.wallet,
  l.currency,
  l.balance::text AS balance,
  l.balance_raw::text AS balance_raw,
  l.evt_block_number,
  l.evt_block_time
FROM ${chain.schema_name}.vw_fee_leaderboard_current l`);

statements.push(`CREATE OR REPLACE VIEW indexer.vw_fee_leaderboard_by_chain AS
${unionOrEmpty(feeLeaderboardByChainSelects, [
  ["NULL::text", "chain"],
  ["NULL::text", "wallet"],
  ["NULL::text", "currency"],
  ["NULL::text", "balance"],
  ["NULL::text", "balance_raw"],
  ["NULL::numeric", "evt_block_number"],
  ["NULL::timestamp", "evt_block_time"],
])};`);
statements.push(grantIndexerView("vw_fee_leaderboard_by_chain"));

statements.push(`CREATE OR REPLACE VIEW indexer.vw_fee_leaderboard_current AS
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
  ON up.id = uw.user_id;`);
statements.push(grantIndexerView("vw_fee_leaderboard_current"));

const userFeeBalancesByChainSelects = evmChains.map((chain) => `SELECT
  ${lit(chain.chain)}::text AS chain,
  b.account,
  b.currency,
  b.token_layer_id,
  b.token_address,
  b.token_name,
  b.token_symbol,
  b.token_decimals,
  b.balance::text AS balance,
  b.balance_raw::text AS balance_raw,
  b.total_received::text AS total_received,
  b.total_received_raw::text AS total_received_raw,
  b.evt_block_number,
  b.evt_block_time
FROM ${chain.schema_name}.vw_user_fee_balances_current b`);

statements.push(`CREATE OR REPLACE VIEW indexer.vw_user_fee_balances_by_chain AS
${unionOrEmpty(userFeeBalancesByChainSelects, [
  ["NULL::text", "chain"],
  ["NULL::text", "account"],
  ["NULL::text", "currency"],
  ["NULL::text", "token_layer_id"],
  ["NULL::text", "token_address"],
  ["NULL::text", "token_name"],
  ["NULL::text", "token_symbol"],
  ["NULL::numeric", "token_decimals"],
  ["NULL::text", "balance"],
  ["NULL::text", "balance_raw"],
  ["NULL::text", "total_received"],
  ["NULL::text", "total_received_raw"],
  ["NULL::numeric", "evt_block_number"],
  ["NULL::timestamp", "evt_block_time"],
])};`);
statements.push(grantIndexerView("vw_user_fee_balances_by_chain"));

statements.push(`CREATE OR REPLACE VIEW indexer.vw_user_fee_balances_current AS
WITH grouped AS (
  SELECT
    account,
    COALESCE(token_layer_id, lower(currency)) AS token_key,
    MIN(token_layer_id) AS token_layer_id,
    MAX(token_name) AS token_name,
    MAX(token_symbol) AS token_symbol,
    CASE
      WHEN COUNT(*) FILTER (WHERE balance IS NULL) > 0 THEN NULL::numeric
      ELSE SUM(balance::numeric)::numeric
    END AS balance,
    CASE
      WHEN COUNT(*) FILTER (WHERE total_received IS NULL) > 0 THEN NULL::numeric
      ELSE SUM(total_received::numeric)::numeric
    END AS total_received,
    MAX(evt_block_time) AS last_updated_at
  FROM indexer.vw_user_fee_balances_by_chain
  GROUP BY account, COALESCE(token_layer_id, lower(currency))
),
per_chain AS (
  SELECT
    account,
    COALESCE(token_layer_id, lower(currency)) AS token_key,
    jsonb_object_agg(
      chain,
      jsonb_build_object(
        'currency', lower(currency),
        'token_decimals', token_decimals,
        'balance', balance,
        'balance_raw', balance_raw,
        'total_received', total_received,
        'total_received_raw', total_received_raw,
        'last_updated_at', evt_block_time
      )
      ORDER BY chain
    ) AS per_chain_balances
  FROM indexer.vw_user_fee_balances_by_chain
  GROUP BY account, COALESCE(token_layer_id, lower(currency))
)
SELECT
  g.account,
  g.token_key,
  g.token_layer_id,
  g.token_name,
  g.token_symbol,
  g.balance::text AS balance,
  g.total_received::text AS total_received,
  p.per_chain_balances,
  g.last_updated_at
FROM grouped g
LEFT JOIN per_chain p
  ON p.account = g.account
 AND p.token_key = g.token_key;`);
statements.push(grantIndexerView("vw_user_fee_balances_current"));

const feeHistoryByChainSelects = evmChains.map((chain) => `SELECT
  ${lit(chain.chain)}::text AS chain,
  h.account,
  h.currency,
  h.token_layer_id,
  h.token_address,
  h.token_name,
  h.token_symbol,
  h.token_decimals,
  h.amount::text AS amount,
  h.amount_raw::text AS amount_raw,
  h.distribution_type,
  h.distribution_name,
  h.tracking_id,
  h.activity_id,
  h.activity_name,
  h.evt_block_number,
  h.evt_block_time,
  h.evt_tx_hash,
  h.evt_index
FROM ${chain.schema_name}.vw_user_fee_distribution_history h`);

statements.push(`CREATE OR REPLACE VIEW indexer.vw_user_fee_distribution_history_by_chain AS
${unionOrEmpty(feeHistoryByChainSelects, [
  ["NULL::text", "chain"],
  ["NULL::text", "account"],
  ["NULL::text", "currency"],
  ["NULL::text", "token_layer_id"],
  ["NULL::text", "token_address"],
  ["NULL::text", "token_name"],
  ["NULL::text", "token_symbol"],
  ["NULL::numeric", "token_decimals"],
  ["NULL::text", "amount"],
  ["NULL::text", "amount_raw"],
  ["NULL::text", "distribution_type"],
  ["NULL::text", "distribution_name"],
  ["NULL::text", "tracking_id"],
  ["NULL::text", "activity_id"],
  ["NULL::text", "activity_name"],
  ["NULL::numeric", "evt_block_number"],
  ["NULL::timestamp", "evt_block_time"],
  ["NULL::text", "evt_tx_hash"],
  ["NULL::numeric", "evt_index"],
])};`);
statements.push(grantIndexerView("vw_user_fee_distribution_history_by_chain"));

const tokenStatsSelects = evmChains.map((chain) => `SELECT
  ${lit(chain.chain)}::text AS chain,
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
FROM ${chain.schema_name}.vw_token_market_current s`);

statements.push(`CREATE VIEW indexer.vw_token_stats_current AS
${unionOrEmpty(tokenStatsSelects, [
  ["NULL::text", "chain"],
  ["NULL::text", "token_layer_id"],
  ["NULL::text", "token_address"],
  ["NULL::text", "price_usd"],
  ["NULL::text", "market_cap_usd"],
  ["NULL::text", "market_cap_change_5m_pct"],
  ["NULL::text", "market_cap_change_5m_abs"],
  ["NULL::text", "market_cap_change_1h_pct"],
  ["NULL::text", "market_cap_change_6h_pct"],
  ["NULL::text", "market_cap_change_24h_pct"],
  ["NULL::text", "market_cap_change_1h_abs"],
  ["NULL::text", "market_cap_change_6h_abs"],
  ["NULL::text", "market_cap_change_24h_abs"],
  ["NULL::text", "price_change_5m_pct"],
  ["NULL::text", "price_change_1h_pct"],
  ["NULL::text", "price_change_6h_pct"],
  ["NULL::text", "price_change_24h_pct"],
  ["NULL::text", "price_change_5m_abs"],
  ["NULL::text", "price_change_1h_abs"],
  ["NULL::text", "price_change_6h_abs"],
  ["NULL::text", "price_change_24h_abs"],
  ["NULL::text", "total_volume_token"],
  ["NULL::text", "total_volume_token_raw"],
  ["NULL::text", "total_volume_usd"],
  ["NULL::text", "total_volume_usd_raw"],
  ["NULL::text", "volume_usd_5m"],
  ["NULL::text", "volume_usd_1h"],
  ["NULL::text", "volume_usd_6h"],
  ["NULL::text", "volume_usd_24h"],
  ["NULL::text", "volume_change_5m_abs"],
  ["NULL::text", "volume_change_1h_abs"],
  ["NULL::text", "volume_change_6h_abs"],
  ["NULL::text", "volume_change_24h_abs"],
  ["NULL::text", "volume_change_5m_pct"],
  ["NULL::text", "volume_change_1h_pct"],
  ["NULL::text", "volume_change_6h_pct"],
  ["NULL::text", "volume_change_24h_pct"],
  ["NULL::text", "holder_count"],
  ["NULL::text", "holder_count_change_5m_abs"],
  ["NULL::text", "holder_count_change_1h_abs"],
  ["NULL::text", "holder_count_change_6h_abs"],
  ["NULL::text", "holder_count_change_24h_abs"],
  ["NULL::text", "holder_count_change_5m_pct"],
  ["NULL::text", "holder_count_change_1h_pct"],
  ["NULL::text", "holder_count_change_6h_pct"],
  ["NULL::text", "holder_count_change_24h_pct"],
  ["NULL::timestamp", "last_trade_at"],
  ["NULL::text", "last_trade_venue"],
  ["NULL::text", "launchpad_price_usd"],
  ["NULL::text", "launchpad_supply"],
  ["NULL::text", "launchpad_supply_raw"],
  ["NULL::text", "launchpad_tokens_left"],
  ["NULL::text", "launchpad_tokens_left_raw"],
  ["NULL::text", "launchpad_liquidity_usd"],
  ["NULL::text", "launchpad_liquidity_usd_raw"],
  ["NULL::text", "launchpad_progress_pct"],
  ["NULL::text", "launchpad_progress_change_5m_abs"],
  ["NULL::text", "launchpad_progress_change_1h_abs"],
  ["NULL::text", "launchpad_progress_change_6h_abs"],
  ["NULL::text", "launchpad_progress_change_24h_abs"],
  ["NULL::text", "launchpad_progress_change_5m_pct"],
  ["NULL::text", "launchpad_progress_change_1h_pct"],
  ["NULL::text", "launchpad_progress_change_6h_pct"],
  ["NULL::text", "launchpad_progress_change_24h_pct"],
  ["NULL::numeric", "evt_block_number"],
  ["NULL::timestamp", "updated_at"],
])};`);
statements.push(grantIndexerView("vw_token_stats_current"));

statements.push(`DROP VIEW IF EXISTS public.vw_token_activity_desc;
DROP VIEW IF EXISTS indexer.vw_token_activity_desc;
DROP VIEW IF EXISTS public.vw_token_activity;
DROP VIEW IF EXISTS indexer.vw_token_activity;`);

const tokenActivitySelects = [
  ...evmChains.map((chain) => `SELECT
  ${lit(chain.chain)}::text AS chain,
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
FROM ${chain.schema_name}.vw_token_activity a`),
  ...solanaChains.map((chain) => `SELECT
  ${lit(chain.chain)}::text AS chain,
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
FROM ${chain.schema_name}.vw_token_activity a`),
];

statements.push(`CREATE VIEW indexer.vw_token_activity AS
WITH activity_union AS (
${unionOrEmpty(tokenActivitySelects, [
  ["NULL::text", "chain"],
  ["NULL::text", "activity_type"],
  ["NULL::text", "activity_subtype"],
  ["NULL::numeric", "evt_block_number"],
  ["NULL::timestamp", "evt_block_time"],
  ["NULL::text", "tx_hash"],
  ["NULL::numeric", "evt_index"],
  ["NULL::text", "token_layer_id"],
  ["NULL::text", "token_address"],
  ["NULL::text", "wallet"],
  ["NULL::text", "trader"],
  ["NULL::text", "receiver"],
  ["NULL::text", "from_address"],
  ["NULL::text", "to_address"],
  ["NULL::text", "token_amount"],
  ["NULL::text", "token_amount_raw"],
  ["NULL::text", "usd_amount"],
  ["NULL::text", "usd_amount_raw"],
  ["NULL::text", "price_usd"],
  ["NULL::text", "price_usd_raw"],
  ["NULL::text", "market_cap_usd"],
  ["NULL::text", "market_cap_usd_raw"],
  ["NULL::text", "pool"],
  ["NULL::text", "liquidity_amount"],
  ["NULL::text", "liquidity_amount_raw"],
  ["NULL::text", "amount0"],
  ["NULL::text", "amount0_raw"],
  ["NULL::text", "amount1"],
  ["NULL::text", "amount1_raw"],
  ["NULL::text", "guid"],
  ["NULL::text", "src_eid"],
  ["NULL::text", "dst_eid"],
  ["NULL::boolean", "is_external"],
  ["NULL::text", "final_supply"],
  ["NULL::text", "final_supply_raw"],
  ["NULL::text", "final_reserves"],
  ["NULL::text", "final_reserves_raw"],
  ["NULL::text", "token_decimals"],
  ["NULL::text", "price_usd_at_event"],
  ["NULL::text", "price_usd_at_event_raw"],
  ["NULL::text", "usd_value"],
  ["NULL::text", "usd_value_raw"],
])}
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
ORDER BY evt_block_time DESC NULLS LAST, chain ASC, evt_block_number DESC, evt_index DESC, tx_hash DESC;`);
statements.push(grantIndexerView("vw_token_activity"));

process.stdout.write(`${statements.join("\n\n")}\n\n${staticTail}\n`);
