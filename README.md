# token_layer Substreams modules

This package was initialized via `substreams init`, using the `evm-events-calls` template.

## Usage

```bash
substreams build
substreams auth
substreams gui       			  # Get streaming!
```

Optionally, you can publish your Substreams to the [Substreams Registry](https://substreams.dev).

```bash
substreams registry login         # Login to substreams.dev
substreams registry publish       # Publish your Substreams to substreams.dev
```

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


