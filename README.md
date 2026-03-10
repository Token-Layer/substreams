# token_layer Substreams modules

This package was initialized via `substreams init`, using the `evm-events-calls` template.

## Usage

```bash
substreams build
substreams auth
substreams gui                # Get streaming!
```

Optionally, you can publish your Substreams to the [Substreams Registry](https://substreams.dev).

```bash
substreams registry login     # Login to substreams.dev
substreams registry publish   # Publish your Substreams to substreams.dev
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

Use dedicated scripts per chain to avoid a shared `.env` collision:

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

### Balance Tables

- `WalletTokenBalance`: append-only balance snapshots
- `WalletTokenBalanceCurrent`: strict one-row-per-`token_address+wallet` upsert table (maintained directly by `db_out`)

### Notes

- Default manifest is `./substreams.yaml` (Base Sepolia). Override with `MANIFEST=./substreams-bsc-testnet.yaml`.
- Sink module is defined in manifest `sink.module: db_out`.
- If you use your own endpoint, verify the exact hostname for your network in StreamingFast docs/account.

## Global Indexer + Token Metadata Worker

`./scripts/setup-indexer-global.sh` now applies:
- `sql/indexer_global_views.sql` (cross-chain `indexer.vw_*` views)
- `sql/indexer_token_metadata.sql` (token URI queue + parsed metadata tables/functions)

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
