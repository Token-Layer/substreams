# TokenLayer Protocol Substreams

This directory contains the **Substreams implementation for the TokenLayer protocol**.
It indexes TokenLayer protocol contracts, TokenCoin lifecycle events, Launchpad and Uniswap V3 trading activity, and emits:

- protocol event stream (`map_events`)
- database-ready `DatabaseChanges` stream (`db_out`) for PostgreSQL sinks

Primary purpose:
- reorg-safe, chain-specific indexing into Postgres schemas
- consistent raw + normalized analytics layers for API consumption

## What This Indexer Covers

- Protocol contracts: Registry, Manager, OApp, Launchpad, IP, LiquidityManager, Fees, Roles
- TokenCoin contracts created by Registry
- Launchpad trades and pool state updates
- Uniswap V3 pool create/swap/mint/burn (for tracked tokens)
- Aggregates and current-state tables for balances, prices, and token stats
- Cross-chain/global read views in `indexer` and `public` schemas

## Local Dev (Substreams CLI)

```bash
substreams build
substreams auth
substreams gui ./substreams.yaml map_events
```

Optional publishing:

```bash
substreams registry login
substreams registry publish
```

## PostgreSQL SQL Sink (DatabaseChanges)

This repo now includes helper scripts to stream `db_out` (`DatabaseChanges`) into PostgreSQL with `substreams-sink-sql`.
To avoid `sink.type` compatibility issues across CLI/sink versions:
- manifests stay sink-less (`substreams.yaml`, `substreams-bsc-testnet.yaml`)
- `setup` applies `schema.sql` through `psql` and creates sink system tables via `--system-tables-only`

1. Start local Postgres (optional if using your own remote DB):

```bash
docker compose up -d postgres pgweb
```

2. Configure chain-first env files (recommended):

```bash
cp .env.shared.sink.example .env.shared.sink
cp .env.base-sepolia.sink.example .env.base-sepolia.sink
cp .env.bnb-testnet.sink.example .env.bnb-testnet.sink
```

Set at minimum:
- `DATABASE_URL_BASE` in `.env.shared.sink`
- per-chain `SUBSTREAMS_ENDPOINT`
- provider auth (`PINAX_*` or `STREAMINGFAST_*`, or explicit `SUBSTREAMS_API_*`)

3. Build the package:

```bash
substreams build
```

4. Setup schema + system tables (chain wrappers):

```bash
./scripts/sink-sql-base-sepolia.sh setup
./scripts/sink-sql-bnb-testnet.sh setup
```

5. Run initial backfill (bounded with `STOP_BLOCK` if needed):

```bash
./scripts/sink-sql-base-sepolia.sh backfill
./scripts/sink-sql-bnb-testnet.sh backfill
```

6. Keep syncing new blocks:

```bash
./scripts/sink-sql-base-sepolia.sh live
./scripts/sink-sql-bnb-testnet.sh live
```

### Chain-specific runners

Use dedicated scripts per chain (recommended):

```bash
cp .env.shared.sink.example .env.shared.sink
cp .env.base-sepolia.sink.example .env.base-sepolia.sink
./scripts/sink-sql-base-sepolia.sh setup
./scripts/sink-sql-base-sepolia.sh backfill
./scripts/sink-sql-base-sepolia.sh live
```

```bash
cp .env.shared.sink.example .env.shared.sink
cp .env.bnb-testnet.sink.example .env.bnb-testnet.sink
./scripts/sink-sql-bnb-testnet.sh setup
./scripts/sink-sql-bnb-testnet.sh backfill
./scripts/sink-sql-bnb-testnet.sh live
```

Notes:
- `DATABASE_URL_BASE` in `.env.shared.sink` should omit `schemaName`; chain scripts append `schemaName` automatically.
- `START_BLOCK` is now optional. If omitted, Substreams uses module `initialBlock` from the manifest.
- `SUBSTREAMS_PARALLEL_WORKERS` is consumed by backfill only.

### Adding A New Chain

The flow is now registry-driven. A chain schema is still created per chain, but the shared `indexer.vw_*` views and `ws-gateway` triggers are rebuilt from `indexer.indexer_chains` instead of hand-editing SQL unions.

1. Create the per-chain env file:

```bash
cp .env.ethereum.sink .env.ethereum.sink.local  # or edit the tracked .env.<chain>.sink directly
```

At minimum set:
- `TOKENLAYER_CHAIN`
- `SUBSTREAMS_ENDPOINT`
- either shared auth in `.env.shared.sink` or per-chain `SUBSTREAMS_API_KEY` / `SUBSTREAMS_API_TOKEN`
- optional `START_BLOCK` / `STOP_BLOCK`

2. Run per-chain setup:

```bash
./scripts/sink-sql-chain.sh ethereum setup
```

What `setup` now does:
- creates the target schema if it does not exist
- applies `schema.sql`
- applies per-schema analytics SQL
- creates sink system tables
- registers the chain in `indexer.indexer_chains` automatically for the EVM chain wrapper flow

3. Run backfill or live sync:

```bash
./scripts/sink-sql-chain.sh ethereum backfill
./scripts/sink-sql-chain.sh ethereum live
```

4. Rebuild shared indexer views and gateway triggers:

```bash
./scripts/setup-indexer-global.sh
```

That script now:
- ensures `indexer.indexer_chains` exists
- reads enabled chains from the registry
- generates and applies the global `indexer.vw_*` views
- regenerates `indexer.vw_indexing_progress_by_chain` / `public.vw_indexing_progress_by_chain`
- reapplies `indexer_token_metadata.sql`
- reapplies `packages/ws-gateway/sql/gateway.sql` by default so trigger installs match the same registry

### Registering Existing Schemas

Older schemas created before registry auto-registration need a one-time manual registration.

Example:

```bash
./scripts/register-indexer-chain.sh base-sepolia indexer_evm_base_sepolia evm 10
./scripts/register-indexer-chain.sh bnb-testnet indexer_evm_bnb_testnet evm 20
./scripts/register-indexer-chain.sh solana-devnet indexer_sol_solana_devnet solana 30
./scripts/setup-indexer-global.sh
```

Notes:
- the 4th argument is `sort_order`; it only controls registry ordering for generated unions and trigger install order
- rerunning `register-indexer-chain.sh` updates the existing row, so you can change `sort_order` later
- after changing registry rows, rerun `./scripts/setup-indexer-global.sh`

### Registry

Source of truth for global bootstrap:
- table `indexer.indexer_chains`
- definition in [`sql/indexer_registry.sql`](/Users/chrisciszak/Documents/Projects/Thrust/Thrust%20Web%20App/substreams/token_layer/sql/indexer_registry.sql)

Useful helpers:
- [`scripts/register-indexer-chain.sh`](/Users/chrisciszak/Documents/Projects/Thrust/Thrust%20Web%20App/substreams/token_layer/scripts/register-indexer-chain.sh) for manual registration or non-EVM flows
- [`scripts/setup-indexer-global.sh`](/Users/chrisciszak/Documents/Projects/Thrust/Thrust%20Web%20App/substreams/token_layer/scripts/setup-indexer-global.sh) to regenerate global views and reapply gateway bootstrap
- [`scripts/generate-indexer-global-sql.mjs`](/Users/chrisciszak/Documents/Projects/Thrust/Thrust%20Web%20App/substreams/token_layer/scripts/generate-indexer-global-sql.mjs) generates the SQL applied by the global setup script

Indexing progress:
- `indexer.vw_indexing_progress_by_chain` exposes one row per enabled registered chain
- it reads the latest row from each schema's `indexing_progress` table
- useful columns are `last_seen_block`, `last_seen_at`, and `seconds_since_last_seen`

## Railway Deployment

Railway should run this as one service per chain, using the same image:
- service `tokenlayer-substreams-base-sepolia`
- service `tokenlayer-substreams-bnb-testnet`
- later, one additional service per new chain

Recommended service setup:
1. Connect the repo to Railway.
2. Set the service root directory to `substreams/token_layer`.
3. Let Railway build from [Dockerfile](/Users/chrisciszak/Documents/Projects/Thrust/Thrust%20Web%20App/substreams/token_layer/Dockerfile).
4. Keep the default container command, which runs [scripts/railway-run-chain.sh](/Users/chrisciszak/Documents/Projects/Thrust/Thrust%20Web%20App/substreams/token_layer/scripts/railway-run-chain.sh).

Suggested shared variables for the Railway project:
- `DATABASE_URL_BASE`
- `PINAX_API_KEY` or `PINAX_API_TOKEN`
- `STREAMINGFAST_API_KEY` or `STREAMINGFAST_API_TOKEN`
- `HANDLE_REORGS=1`
- `UNDO_BUFFER_SIZE=200`

Per-service variables:
- `TOKENLAYER_CHAIN=base-sepolia` or `TOKENLAYER_CHAIN=bnb-testnet`
- `TOKENLAYER_ACTION=live`
- `TOKENLAYER_AUTO_SETUP=1`
- optional `START_BLOCK`
- optional `STOP_BLOCK` for bounded backfills
- optional `SUBSTREAMS_PARALLEL_WORKERS` for backfills

Notes for Railway:
- Railway documents that Dockerfile auto-detection looks for `Dockerfile` in the root of the service source directory, so point the service root at `substreams/token_layer`.
- Railway supports shared variables and service-specific variables, which maps cleanly to `.env.shared.sink` and `.env.<chain>.sink`.
- If Railway gives you a `postgres://` or `postgresql://` URL, the chain wrapper normalizes it to `psql://` for `substreams-sink-sql`.

Operational pattern:
- live sync: normal long-running service with `TOKENLAYER_ACTION=live`
- backfill: duplicate a service temporarily and set `TOKENLAYER_ACTION=backfill`
- schema setup: handled automatically on container start when `TOKENLAYER_AUTO_SETUP=1`

Example Railway mapping:

```text
Shared variables
  DATABASE_URL_BASE=postgresql://...
  PINAX_API_KEY=...

Service: tokenlayer-substreams-base-sepolia
  TOKENLAYER_CHAIN=base-sepolia
  TOKENLAYER_ACTION=live

Service: tokenlayer-substreams-bnb-testnet
  TOKENLAYER_CHAIN=bnb-testnet
  TOKENLAYER_ACTION=live
```

### Balance Tables

- `WalletTokenBalance`: append-only balance snapshots
- `WalletTokenBalanceCurrent`: strict one-row-per-`token_address+wallet` upsert table (maintained directly by `db_out`)

### Notes

- Default manifest is `./substreams.yaml` (Base Sepolia). Override with `MANIFEST=./substreams-bsc-testnet.yaml`.
- Sink module is defined in manifest `sink.module: db_out`.
- If you use your own endpoint, verify the exact hostname for your network in StreamingFast docs/account.

## Global Indexer + Token Metadata Worker

`./scripts/setup-indexer-global.sh` now applies:
- `sql/indexer_registry.sql` (shared chain registry used by the bootstrap)
- `sql/indexer_global_views.sql` (cross-chain `indexer.vw_*` views)
- `sql/indexer_token_metadata.sql` (token URI queue + parsed metadata tables/functions)
- `../packages/ws-gateway/sql/gateway.sql` by default, unless `APPLY_GATEWAY_SQL=0`

Token metadata pipeline:
1. `indexer.sync_token_uri_sources()` collects token URIs from `indexer.vw_tokens_created` and enqueues missing jobs.
2. Edge function `indexer-token-metadata` claims jobs with `indexer.claim_token_metadata_jobs(limit)`.
3. Worker resolves IPFS/http metadata URI, parses JSON, normalizes tags, uploads image to Supabase Storage (`tokens/token-metadata/...`), writes `indexer.token_metadata`.
4. Job status tracked in `indexer.token_metadata_jobs` and `indexer.vw_token_metadata_job_status`.

To schedule the metadata worker every 60 seconds (cron backstop):

```bash
./scripts/setup-indexer-metadata-cron.sh
```

Environment used by the cron setup script:
- `DATABASE_URL` (or `DATABASE_URL_BASE`)
- `SUPABASE_URL` (or `SB_URL`)
- optional: `INDEXER_METADATA_WORKER_TOKEN`
- optional: `INDEXER_METADATA_CRON_LIMIT` (default `25`)

## Modules

All of these modules produce data filtered by these contracts:
- _registry_ at **0x000000194d2afe38a20707cb96ed1583038bf02f**
- _oapp_ at **0xf132f6224dad58568c54780c14e1d3b97a5f672a**
- _manager_ at **0x0000007E56E19A085a31F27AA61C8671c12d2BB7**
- _launchpad_ at **0x00060EB62a2C042D00E29fDDc092f9eD1F25DeF1**
- _ip_ at **0x00089428a12cd4a6064be0125ced1f6a1066deed**
- _liquidity_mananager_ at **0xe60159a9831ed8c8a8832da1b9a10c03d737dcb2**
- _fees_ at **0xfeeeba1dcc3abbd045e8b824d9699e735de49fee**
- _roles_ at **0xff582c406d037ac7aaddbb203d74bde112791d51**
- token_coin contracts created from _registry_

### `map_events`

This module gets you only events that matched.
