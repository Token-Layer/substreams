// Generated from proto/contract.proto for DatabaseChanges sink
use crate::pb::contract::v1 as contract;
use substreams::Hex;
use substreams_database_change::pb::database::DatabaseChanges;
use substreams_database_change::tables::Tables;

fn bytes_to_hex_prefixed(value: &[u8]) -> String {
    format!("0x{}", Hex(value).to_string())
}

fn event_row_id(tx_hash: &str, evt_index: u32) -> String {
    format!("{}:{}", tx_hash, evt_index)
}

fn upsert_dim_token(
    tables: &mut Tables,
    token_layer_id: &str,
    token_address: Option<&str>,
    name: Option<&str>,
    symbol: Option<&str>,
    decimals: Option<i64>,
    token_uri: Option<&str>,
    source_event: Option<&str>,
    set_provenance: bool,
    evt_block_number: u64,
    evt_block_time: Option<prost_types::Timestamp>,
) {
    if token_layer_id.is_empty() {
        return;
    }

    let row = tables.upsert_row("dim_token", token_layer_id.to_string());
    row.set("token_layer_id", token_layer_id.to_string());
    if let Some(v) = token_address {
        if !v.is_empty() {
            row.set("token_address", v.to_string());
        }
    }
    if let Some(v) = name {
        if !v.is_empty() {
            row.set("name", v.to_string());
        }
    }
    if let Some(v) = symbol {
        if !v.is_empty() {
            row.set("symbol", v.to_string());
        }
    }
    if let Some(v) = decimals {
        row.set("decimals", v);
    }
    if let Some(v) = token_uri {
        if !v.is_empty() {
            row.set("token_uri", v.to_string());
        }
    }
    if set_provenance {
        if let Some(v) = source_event {
            row.set("source_event", v.to_string());
        }
        row.set("created_evt_block_number", evt_block_number as i64);
        if let Some(value) = evt_block_time.clone() { row.set("created_evt_block_time", value.clone()); }
    }
    row.set("updated_evt_block_number", evt_block_number as i64);
    if let Some(value) = evt_block_time.clone() { row.set("updated_evt_block_time", value); }
}

pub fn events_to_database_changes(events: contract::Events) -> DatabaseChanges {
    let mut tables = Tables::new();

    for evt in events.registry_adapter_deployeds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_registry_adapter_deployed", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("adapter", bytes_to_hex_prefixed(&evt.adapter));
        row.set("external_token", bytes_to_hex_prefixed(&evt.external_token));
        row.set("wrapped_token", bytes_to_hex_prefixed(&evt.wrapped_token));
        row.set("adapter_type", evt.adapter_type as i64);
    }

    for evt in events.registry_adapter_template_resets.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_registry_adapter_template_reset", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("template_id", bytes_to_hex_prefixed(&evt.template_id));
    }

    for evt in events.registry_adapter_template_sets.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_registry_adapter_template_set", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("template_id", bytes_to_hex_prefixed(&evt.template_id));
        row.set("adapter_type", evt.adapter_type as i64);
        row.set("implementation_address", bytes_to_hex_prefixed(&evt.implementation_address));
    }

    for evt in events.registry_builder_fees_approveds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_registry_builder_fees_approved", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("user", bytes_to_hex_prefixed(&evt.user));
        row.set("builder", bytes_to_hex_prefixed(&evt.builder));
    }

    for evt in events.registry_coin_createds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_registry_coin_created", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("coin_address", bytes_to_hex_prefixed(&evt.coin_address));
        row.set("hub_id", evt.hub_id);
        row.set("name", evt.name);
        row.set("symbol", evt.symbol);
        row.set("decimals", evt.decimals as i64);
        row.set("token_uri", evt.token_uri);
        row.set("total_supply", evt.total_supply);
    }

    for evt in events.registry_contract_address_overwrittens.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_registry_contract_address_overwritten", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("identifier", bytes_to_hex_prefixed(&evt.identifier));
        row.set("old_address", bytes_to_hex_prefixed(&evt.old_address));
        row.set("new_address", bytes_to_hex_prefixed(&evt.new_address));
    }

    for evt in events.registry_contract_deployeds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_registry_contract_deployed", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("name", bytes_to_hex_prefixed(&evt.name));
        row.set("contract_address", bytes_to_hex_prefixed(&evt.contract_address));
        row.set("salt", bytes_to_hex_prefixed(&evt.salt));
    }

    for evt in events.registry_external_token_createds.into_iter() {
        let token_address = bytes_to_hex_prefixed(&evt.token_address);
        upsert_dim_token(
            &mut tables,
            &evt.token_id,
            Some(&token_address),
            Some(&evt.name),
            Some(&evt.symbol),
            None,
            None,
            Some("registry_external_token_created"),
            true,
            evt.evt_block_number,
            evt.evt_block_time.clone(),
        );
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_registry_external_token_created", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("token_id", evt.token_id);
        row.set("token_address", token_address);
        row.set("adapter", bytes_to_hex_prefixed(&evt.adapter));
        row.set("external_token", bytes_to_hex_prefixed(&evt.external_token));
        row.set("name", evt.name);
        row.set("symbol", evt.symbol);
        row.set("adapter_type", evt.adapter_type as i64);
    }

    for evt in events.registry_hub_createds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_registry_hub_created", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("id", evt.id);
        row.set("creator", bytes_to_hex_prefixed(&evt.creator));
        row.set("receiver", bytes_to_hex_prefixed(&evt.receiver));
        row.set("is_private", evt.is_private);
    }

    for evt in events.registry_hubs_address_changeds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_registry_hubs_address_changed", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("new_address", bytes_to_hex_prefixed(&evt.new_address));
    }

    for evt in events.registry_initializeds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_registry_initialized", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("version", evt.version as i64);
    }

    for evt in events.registry_item_createds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_registry_item_created", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("id", evt.id);
        row.set("hub_id", evt.hub_id);
        row.set("symbol", bytes_to_hex_prefixed(&evt.symbol));
        row.set("name", evt.name);
        row.set("token_uri", evt.token_uri);
        row.set("decimals", evt.decimals as i64);
        row.set("pool_type", evt.pool_type);
    }

    for evt in events.registry_items_address_changeds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_registry_items_address_changed", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("new_address", bytes_to_hex_prefixed(&evt.new_address));
    }

    for evt in events.registry_launchpad_address_changeds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_registry_launchpad_address_changed", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("new_address", bytes_to_hex_prefixed(&evt.new_address));
    }

    for evt in events.registry_liquidity_manager_address_changeds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_registry_liquidity_manager_address_changed", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("new_address", bytes_to_hex_prefixed(&evt.new_address));
    }

    for evt in events.registry_liquidity_migrator_address_changeds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_registry_liquidity_migrator_address_changed", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("new_address", bytes_to_hex_prefixed(&evt.new_address));
    }

    for evt in events.registry_manager_updateds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_registry_manager_updated", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("manager", bytes_to_hex_prefixed(&evt.manager));
        row.set("authorized", evt.authorized);
    }

    for evt in events.registry_o_app_configureds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_registry_oapp_configured", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("endpoint_id", evt.endpoint_id as i64);
        row.set("token_id", bytes_to_hex_prefixed(&evt.token_id));
        row.set("token_address", bytes_to_hex_prefixed(&evt.token_address));
        row.set("send_library", bytes_to_hex_prefixed(&evt.send_library));
        row.set("receive_library", bytes_to_hex_prefixed(&evt.receive_library));
    }

    for evt in events.registry_ownership_transferreds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_registry_ownership_transferred", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("user", bytes_to_hex_prefixed(&evt.user));
        row.set("new_owner", bytes_to_hex_prefixed(&evt.new_owner));
    }

    for evt in events.registry_peer_sets.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_registry_peer_set", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("endpoint_id", evt.endpoint_id as i64);
        row.set("token_id", bytes_to_hex_prefixed(&evt.token_id));
        row.set("token_address", bytes_to_hex_prefixed(&evt.token_address));
        row.set("peer_address", bytes_to_hex_prefixed(&evt.peer_address));
    }

    for evt in events.registry_points_createds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_registry_points_created", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("id", evt.id);
        row.set("hub_id", evt.hub_id);
        row.set("name", evt.name);
        row.set("symbol", evt.symbol);
        row.set("uri", evt.uri);
        row.set("soulbound", evt.soulbound);
    }

    for evt in events.registry_protocol_bonus_config_sets.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_registry_protocol_bonus_config_set", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("duration_blocks", evt.duration_blocks as i64);
        row.set("start_percentage_bps", evt.start_percentage_bps as i64);
    }

    for evt in events.registry_protocol_fee_sets.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_registry_protocol_fee_set", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("activity", evt.activity as i64);
        row.set("fee_bps", evt.fee_bps as i64);
    }

    for evt in events.registry_protocol_limit_sets.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_registry_protocol_limit_set", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("activity", evt.activity as i64);
        row.set("max_fee_bps", evt.max_fee_bps as i64);
    }

    for evt in events.registry_referral_sets.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_registry_referral_set", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("referee", bytes_to_hex_prefixed(&evt.referee));
        row.set("referrer", bytes_to_hex_prefixed(&evt.referrer));
        row.set("reward_active", evt.reward_active);
        row.set("discount_active", evt.discount_active);
    }

    for evt in events.registry_referral_status_updateds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_registry_referral_status_updated", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("referee", bytes_to_hex_prefixed(&evt.referee));
        row.set("reward_active", evt.reward_active);
        row.set("discount_active", evt.discount_active);
    }

    for evt in events.registry_referrals_controller_updateds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_registry_referrals_controller_updated", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("old_controller", bytes_to_hex_prefixed(&evt.old_controller));
        row.set("new_controller", bytes_to_hex_prefixed(&evt.new_controller));
    }

    for evt in events.registry_registry_initializeds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_registry_registry_initialized", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("owner", bytes_to_hex_prefixed(&evt.owner));
        row.set("trusted_forwarder", bytes_to_hex_prefixed(&evt.trusted_forwarder));
        row.set("payment_token", bytes_to_hex_prefixed(&evt.payment_token));
        row.set("protocol_fee_to", bytes_to_hex_prefixed(&evt.protocol_fee_to));
        row.set("endpoint", bytes_to_hex_prefixed(&evt.endpoint));
        row.set("swap_router", bytes_to_hex_prefixed(&evt.swap_router));
    }

    for evt in events.registry_token_createds.into_iter() {
        upsert_dim_token(
            &mut tables,
            &evt.token_id,
            Some(&evt.token_address),
            Some(&evt.name),
            Some(&evt.symbol),
            Some(evt.decimals as i64),
            Some(&evt.token_uri),
            Some("registry_token_created"),
            true,
            evt.evt_block_number,
            evt.evt_block_time.clone(),
        );
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_registry_token_created", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("token_address", evt.token_address);
        row.set("token_id", evt.token_id);
        row.set("ip_id", evt.ip_id);
        row.set("symbol", evt.symbol);
        row.set("name", evt.name);
        row.set("token_uri", evt.token_uri);
        row.set("decimals", evt.decimals as i64);
    }

    for evt in events.registry_token_registereds.into_iter() {
        let token_address = bytes_to_hex_prefixed(&evt.token_address);
        upsert_dim_token(
            &mut tables,
            &evt.token_id,
            Some(&token_address),
            Some(&evt.name),
            Some(&evt.symbol),
            None,
            None,
            None,
            false,
            evt.evt_block_number,
            evt.evt_block_time.clone(),
        );
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_registry_token_registered", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("token_id", evt.token_id);
        row.set("token_address", token_address);
        row.set("template_id", bytes_to_hex_prefixed(&evt.template_id));
        row.set("name", evt.name);
        row.set("symbol", evt.symbol);
    }

    for evt in events.registry_token_template_resets.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_registry_token_template_reset", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("template_id", bytes_to_hex_prefixed(&evt.template_id));
    }

    for evt in events.registry_token_template_sets.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_registry_token_template_set", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("template_id", bytes_to_hex_prefixed(&evt.template_id));
        row.set("token_type", evt.token_type as i64);
        row.set("implementation_address", bytes_to_hex_prefixed(&evt.implementation_address));
        row.set("total_supply", evt.total_supply);
    }

    for evt in events.registry_whitelist_toggleds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_registry_whitelist_toggled", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("contract_address", bytes_to_hex_prefixed(&evt.contract_address));
        row.set("whitelisted", evt.whitelisted);
    }

    for evt in events.oapp_eth_withdrawns.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_oapp_eth_withdrawn", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("owner", bytes_to_hex_prefixed(&evt.owner));
        row.set("amount", evt.amount);
    }

    for evt in events.oapp_enforced_option_sets.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_oapp_enforced_option_set", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
    }

    for evt in events.oapp_message_receiveds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_oapp_message_received", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("guid", bytes_to_hex_prefixed(&evt.guid));
        row.set("src_eid", evt.src_eid as i64);
        row.set("msg_type", evt.msg_type as i64);
    }

    for evt in events.oapp_operation_createds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_oapp_operation_created", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("operation_id", evt.operation_id as i64);
        row.set("token_id", bytes_to_hex_prefixed(&evt.token_id));
        row.set("dst_eid", evt.dst_eid as i64);
        row.set("operation_type", evt.operation_type as i64);
        row.set("amount", evt.amount);
    }

    for evt in events.oapp_ownership_transferreds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_oapp_ownership_transferred", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("user", bytes_to_hex_prefixed(&evt.user));
        row.set("new_owner", bytes_to_hex_prefixed(&evt.new_owner));
    }

    for evt in events.oapp_peer_sets.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_oapp_peer_set", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("eid", evt.eid as i64);
        row.set("peer", bytes_to_hex_prefixed(&evt.peer));
    }

    for evt in events.oapp_solana_liquidity_manager_sets.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_oapp_solana_liquidity_manager_set", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("liquidity_manager", bytes_to_hex_prefixed(&evt.liquidity_manager));
    }

    for evt in events.oapp_token_liquidity_initialized_externallies.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_oapp_token_liquidity_initialized_externally", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("token_id", bytes_to_hex_prefixed(&evt.token_id));
        row.set("src_eid", evt.src_eid as i64);
        row.set("dst_eid", evt.dst_eid as i64);
        row.set("amount", evt.amount);
        row.set("price_in_wei", evt.price_in_wei);
    }

    for evt in events.oapp_token_registered_externallies.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_oapp_token_registered_externally", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("token_id", bytes_to_hex_prefixed(&evt.token_id));
        row.set("src_eid", evt.src_eid as i64);
        row.set("dst_eid", evt.dst_eid as i64);
        row.set("operation_id", evt.operation_id as i64);
    }

    for evt in events.oapp_token_registration_acks.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_oapp_token_registration_ack", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("guid", bytes_to_hex_prefixed(&evt.guid));
        row.set("success", evt.success);
    }

    for evt in events.oapp_token_registration_ack_processeds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_oapp_token_registration_ack_processed", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("token_id", bytes_to_hex_prefixed(&evt.token_id));
        row.set("src_eid", evt.src_eid as i64);
        row.set("dst_eid", evt.dst_eid as i64);
        row.set("success", evt.success);
        row.set("remote_token_address", bytes_to_hex_prefixed(&evt.remote_token_address));
        row.set("operation_id", evt.operation_id as i64);
    }

    for evt in events.oapp_token_registration_ack_sents.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_oapp_token_registration_ack_sent", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("token_id", bytes_to_hex_prefixed(&evt.token_id));
        row.set("dst_eid", evt.dst_eid as i64);
        row.set("success", evt.success);
        row.set("operation_id", evt.operation_id as i64);
    }

    for evt in events.oapp_token_registration_initiateds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_oapp_token_registration_initiated", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("token_id", bytes_to_hex_prefixed(&evt.token_id));
        row.set("dst_eid", evt.dst_eid as i64);
        row.set("operation_id", evt.operation_id as i64);
    }

    for evt in events.oapp_token_registration_receiveds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_oapp_token_registration_received", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("token_id", bytes_to_hex_prefixed(&evt.token_id));
        row.set("src_eid", evt.src_eid as i64);
        row.set("source_token_address", bytes_to_hex_prefixed(&evt.source_token_address));
        row.set("operation_id", evt.operation_id as i64);
    }

    for evt in events.manager_builder_activity_fee_sets.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_manager_builder_activity_fee_set", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("builder", bytes_to_hex_prefixed(&evt.builder));
        row.set("activity_id", bytes_to_hex_prefixed(&evt.activity_id));
        row.set("fee_percent", evt.fee_percent);
        row.set("flat_fee", evt.flat_fee);
    }

    for evt in events.manager_external_whitelist_changeds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_manager_external_whitelist_changed", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("token_id", bytes_to_hex_prefixed(&evt.token_id));
        row.set("signer", bytes_to_hex_prefixed(&evt.signer));
        row.set("status", evt.status);
    }

    for evt in events.manager_fees_paids.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_manager_fees_paid", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("hub_id", evt.hub_id);
        row.set("activity_id", bytes_to_hex_prefixed(&evt.activity_id));
        row.set("contract_address", bytes_to_hex_prefixed(&evt.contract_address));
        row.set("sender", bytes_to_hex_prefixed(&evt.sender));
        row.set("protocol_amount", evt.protocol_amount);
        row.set("hub_amount", evt.hub_amount);
        row.set("builder", bytes_to_hex_prefixed(&evt.builder));
        row.set("builder_amount", evt.builder_amount);
        row.set("payment_token", bytes_to_hex_prefixed(&evt.payment_token));
    }

    for evt in events.manager_initializeds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_manager_initialized", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("version", evt.version as i64);
    }

    for evt in events.manager_ownership_transferreds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_manager_ownership_transferred", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("user", bytes_to_hex_prefixed(&evt.user));
        row.set("new_owner", bytes_to_hex_prefixed(&evt.new_owner));
    }

    for evt in events.launchpad_buys.into_iter() {
        let token_id = bytes_to_hex_prefixed(&evt.token_id);
        upsert_dim_token(
            &mut tables,
            &token_id,
            Some(&evt.token_address),
            None,
            None,
            None,
            None,
            None,
            false,
            evt.evt_block_number,
            evt.evt_block_time.clone(),
        );
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_launchpad_buy", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("token_id", token_id);
        row.set("token_address", evt.token_address);
        row.set("trader", bytes_to_hex_prefixed(&evt.trader));
        row.set("receiver", bytes_to_hex_prefixed(&evt.receiver));
        row.set("amount_in", evt.amount_in);
        row.set("tokens_out", evt.tokens_out);
        row.set("price", evt.price);
        row.set("liquidity_wei", evt.liquidity_wei);
        row.set("supply", evt.supply);
        row.set("tokens_left", evt.tokens_left);
    }

    for evt in events.launchpad_new_pool_types.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_launchpad_new_pool_type", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("pool_type_id", evt.pool_type_id);
        row.set("migration_supply", evt.migration_supply);
        row.set("price_at_migration_supply", evt.price_at_migration_supply);
        row.set("initial_token_deposit_wad", evt.initial_token_deposit_wad);
        row.set("initial_reserve_deposit_wad", evt.initial_reserve_deposit_wad);
        row.set("creator_reward", evt.creator_reward);
        row.set("migration_reserve_supply", evt.migration_reserve_supply);
        row.set("migration_token_supply", evt.migration_token_supply);
        row.set("weight", evt.weight as i64);
    }

    for evt in events.launchpad_ownership_transferreds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_launchpad_ownership_transferred", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("user", bytes_to_hex_prefixed(&evt.user));
        row.set("new_owner", bytes_to_hex_prefixed(&evt.new_owner));
    }

    for evt in events.launchpad_phase_expiry_config_sets.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_launchpad_phase_expiry_config_set", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("phase1_expiry_blocks", evt.phase1_expiry_blocks as i64);
        row.set("phase2_expiry_blocks", evt.phase2_expiry_blocks as i64);
    }

    for evt in events.launchpad_sells.into_iter() {
        let token_id = bytes_to_hex_prefixed(&evt.token_id);
        upsert_dim_token(
            &mut tables,
            &token_id,
            Some(&evt.token_address),
            None,
            None,
            None,
            None,
            None,
            false,
            evt.evt_block_number,
            evt.evt_block_time.clone(),
        );
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_launchpad_sell", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("token_id", token_id);
        row.set("token_address", evt.token_address);
        row.set("trader", bytes_to_hex_prefixed(&evt.trader));
        row.set("tokens_in", evt.tokens_in);
        row.set("amount_out", evt.amount_out);
        row.set("price", evt.price);
        row.set("liquidity_wei", evt.liquidity_wei);
        row.set("supply", evt.supply);
        row.set("tokens_left", evt.tokens_left);
    }

    for evt in events.launchpad_graduations.into_iter() {
        let token_id = bytes_to_hex_prefixed(&evt.token_id);
        upsert_dim_token(
            &mut tables,
            &evt.token_layer_id,
            Some(&evt.token_address),
            None,
            None,
            None,
            None,
            None,
            false,
            evt.evt_block_number,
            evt.evt_block_time.clone(),
        );
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_launchpad_graduation", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("token_id", token_id);
        row.set("token_address", evt.token_address);
        row.set("is_external", evt.is_external);
        row.set("final_supply", evt.final_supply);
        row.set("final_reserves", evt.final_reserves);
        row.set("token_layer_id", evt.token_layer_id);
    }

    for evt in events.ip_approvals.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_ip_approval", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("owner", bytes_to_hex_prefixed(&evt.owner));
        row.set("spender", bytes_to_hex_prefixed(&evt.spender));
        row.set("id", evt.id);
    }

    for evt in events.ip_approval_for_alls.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_ip_approval_for_all", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("owner", bytes_to_hex_prefixed(&evt.owner));
        row.set("operator", bytes_to_hex_prefixed(&evt.operator));
        row.set("approved", evt.approved);
    }

    for evt in events.ip_manager_changeds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_ip_manager_changed", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("new_manager", bytes_to_hex_prefixed(&evt.new_manager));
    }

    for evt in events.ip_transfers.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_ip_transfer", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("from", bytes_to_hex_prefixed(&evt.from));
        row.set("to", bytes_to_hex_prefixed(&evt.to));
        row.set("id", evt.id);
    }

    for evt in events.liquidity_mananager_fees_collecteds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_liquidity_mananager_fees_collected", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("key_id", bytes_to_hex_prefixed(&evt.key_id));
        row.set("token_layer_id", bytes_to_hex_prefixed(&evt.key_id));
        row.set("token_id", evt.token_id);
        row.set("amount0", evt.amount0);
        row.set("amount1", evt.amount1);
    }

    for evt in events.liquidity_mananager_fees_distributeds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_liquidity_mananager_fees_distributed", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("key_id", bytes_to_hex_prefixed(&evt.key_id));
        row.set("token_layer_id", bytes_to_hex_prefixed(&evt.key_id));
        row.set("token_id", evt.token_id);
        row.set("token0", bytes_to_hex_prefixed(&evt.token0));
        row.set("token1", bytes_to_hex_prefixed(&evt.token1));
        row.set("owner", bytes_to_hex_prefixed(&evt.owner));
        row.set("amount0_owner", evt.amount0_owner);
        row.set("amount1_owner", evt.amount1_owner);
        row.set("protocol_fee_to", bytes_to_hex_prefixed(&evt.protocol_fee_to));
        row.set("amount0_protocol", evt.amount0_protocol);
        row.set("amount1_protocol", evt.amount1_protocol);
    }

    for evt in events.liquidity_mananager_initial_position_minteds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_liquidity_mananager_initial_position_minted", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("token_id", evt.token_id);
        row.set("key_id", bytes_to_hex_prefixed(&evt.key_id));
        row.set("token_layer_id", bytes_to_hex_prefixed(&evt.key_id));
        row.set("token0", bytes_to_hex_prefixed(&evt.token0));
        row.set("token1", bytes_to_hex_prefixed(&evt.token1));
        row.set("liquidity", evt.liquidity);
        row.set("amount0", evt.amount0);
        row.set("amount1", evt.amount1);
        row.set("tick_lower", evt.tick_lower);
        row.set("tick_upper", evt.tick_upper);
    }

    for evt in events.liquidity_mananager_initializeds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_liquidity_mananager_initialized", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("version", evt.version as i64);
    }

    for evt in events.liquidity_mananager_liquidity_increaseds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_liquidity_mananager_liquidity_increased", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("token_id", evt.token_id);
        row.set("liquidity_added", evt.liquidity_added);
        row.set("amount0", evt.amount0);
        row.set("amount1", evt.amount1);
    }

    for evt in events.liquidity_mananager_liquidity_manager_initializeds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_liquidity_mananager_liquidity_manager_initialized", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("nonfungible_position_manager", bytes_to_hex_prefixed(&evt.nonfungible_position_manager));
        row.set("registry", bytes_to_hex_prefixed(&evt.registry));
        row.set("owner", bytes_to_hex_prefixed(&evt.owner));
    }

    for evt in events.liquidity_mananager_liquidity_manager_upgradeds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_liquidity_mananager_liquidity_manager_upgraded", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("old_implementation", bytes_to_hex_prefixed(&evt.old_implementation));
        row.set("new_implementation", bytes_to_hex_prefixed(&evt.new_implementation));
    }

    for evt in events.liquidity_mananager_liquidity_migrateds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_liquidity_mananager_liquidity_migrated", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("token_id", evt.token_id);
        row.set("liquidity", evt.liquidity);
        row.set("fee", evt.fee as i64);
        row.set("destination_chain", bytes_to_hex_prefixed(&evt.destination_chain));
        row.set("is_default", evt.is_default);
    }

    for evt in events.liquidity_mananager_new_deposits.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_liquidity_mananager_new_deposit", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("token_id", evt.token_id);
        row.set("liquidity", evt.liquidity);
        row.set("token0", bytes_to_hex_prefixed(&evt.token0));
        row.set("token1", bytes_to_hex_prefixed(&evt.token1));
    }

    for evt in events.liquidity_mananager_ownership_transferreds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_liquidity_mananager_ownership_transferred", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("previous_owner", bytes_to_hex_prefixed(&evt.previous_owner));
        row.set("new_owner", bytes_to_hex_prefixed(&evt.new_owner));
    }

    for evt in events.liquidity_mananager_pool_createds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_liquidity_mananager_pool_created", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("token0", bytes_to_hex_prefixed(&evt.token0));
        row.set("token1", bytes_to_hex_prefixed(&evt.token1));
        row.set("fee", evt.fee as i64);
        row.set("sqrt_price_x96", evt.sqrt_price_x96);
        row.set("pool", bytes_to_hex_prefixed(&evt.pool));
    }

    for evt in events.liquidity_mananager_position_created_via_composes.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_liquidity_mananager_position_created_via_compose", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("key_id", bytes_to_hex_prefixed(&evt.key_id));
        row.set("token_layer_id", bytes_to_hex_prefixed(&evt.key_id));
        row.set("token_id", evt.token_id);
        row.set("token0", bytes_to_hex_prefixed(&evt.token0));
        row.set("token1", bytes_to_hex_prefixed(&evt.token1));
        row.set("amount0", evt.amount0);
        row.set("amount1", evt.amount1);
        row.set("sqrt_price_x96", evt.sqrt_price_x96);
    }

    for evt in events.liquidity_mananager_upgradeds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_liquidity_mananager_upgraded", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("implementation", bytes_to_hex_prefixed(&evt.implementation));
    }

    for evt in events.fees_fee_distributeds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_fees_fee_distributed", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("currency", bytes_to_hex_prefixed(&evt.currency));
        row.set("recipient", bytes_to_hex_prefixed(&evt.recipient));
        row.set("amount", evt.amount);
        row.set("distribution_type", evt.distribution_type as i64);
        row.set("tracking_id", bytes_to_hex_prefixed(&evt.tracking_id));
        row.set("activity_id", evt.activity_id as i64);
    }

    for evt in events.fees_protocol_fee_distributeds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_fees_protocol_fee_distributed", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("currency", bytes_to_hex_prefixed(&evt.currency));
        row.set("amount", evt.amount);
        row.set("activity_id", evt.activity_id as i64);
    }

    for evt in events.fees_protocol_fees_controller_updateds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_fees_protocol_fees_controller_updated", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("old_controller", bytes_to_hex_prefixed(&evt.old_controller));
        row.set("new_controller", bytes_to_hex_prefixed(&evt.new_controller));
    }

    for evt in events.fees_protocol_withdrawns.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_fees_protocol_withdrawn", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("currency", bytes_to_hex_prefixed(&evt.currency));
        row.set("to", bytes_to_hex_prefixed(&evt.to));
        row.set("amount", evt.amount);
    }

    for evt in events.fees_withdrawns.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_fees_withdrawn", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("currency", bytes_to_hex_prefixed(&evt.currency));
        row.set("recipient", bytes_to_hex_prefixed(&evt.recipient));
        row.set("to", bytes_to_hex_prefixed(&evt.to));
        row.set("amount", evt.amount);
    }

    for evt in events.roles_approvals.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_roles_approval", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("owner", bytes_to_hex_prefixed(&evt.owner));
        row.set("spender", bytes_to_hex_prefixed(&evt.spender));
        row.set("id", evt.id);
        row.set("amount", evt.amount);
    }

    for evt in events.roles_ban_removeds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_roles_ban_removed", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("account", bytes_to_hex_prefixed(&evt.account));
        row.set("sender", bytes_to_hex_prefixed(&evt.sender));
        row.set("user", bytes_to_hex_prefixed(&evt.user));
    }

    for evt in events.roles_manager_changeds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_roles_manager_changed", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("new_manager", bytes_to_hex_prefixed(&evt.new_manager));
    }

    for evt in events.roles_ownership_transferreds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_roles_ownership_transferred", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("user", bytes_to_hex_prefixed(&evt.user));
        row.set("new_owner", bytes_to_hex_prefixed(&evt.new_owner));
    }

    for evt in events.roles_role_addeds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_roles_role_added", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("account", bytes_to_hex_prefixed(&evt.account));
        row.set("role_id", evt.role_id);
        row.set("order_no", evt.order_no);
    }

    for evt in events.roles_role_createds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_roles_role_created", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("id", evt.id);
        row.set("name", evt.name);
    }

    for evt in events.roles_role_granteds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_roles_role_granted", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("id", evt.id);
        row.set("account", bytes_to_hex_prefixed(&evt.account));
        row.set("role_name", evt.role_name);
        row.set("sender", bytes_to_hex_prefixed(&evt.sender));
        row.set("user", bytes_to_hex_prefixed(&evt.user));
    }

    for evt in events.roles_role_order_updateds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_roles_role_order_updated", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("account", bytes_to_hex_prefixed(&evt.account));
        row.set("role_id", evt.role_id);
        row.set("order_no", evt.order_no);
    }

    for evt in events.roles_role_removeds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_roles_role_removed", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("account", bytes_to_hex_prefixed(&evt.account));
        row.set("role_id", evt.role_id);
    }

    for evt in events.roles_role_renounceds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_roles_role_renounced", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("account", bytes_to_hex_prefixed(&evt.account));
        row.set("sender", bytes_to_hex_prefixed(&evt.sender));
        row.set("id", evt.id);
    }

    for evt in events.roles_role_revokeds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_roles_role_revoked", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("id", evt.id);
        row.set("account", bytes_to_hex_prefixed(&evt.account));
        row.set("role_name", evt.role_name);
        row.set("sender", bytes_to_hex_prefixed(&evt.sender));
        row.set("user", bytes_to_hex_prefixed(&evt.user));
    }

    for evt in events.roles_transfers.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_roles_transfer", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("caller", bytes_to_hex_prefixed(&evt.caller));
        row.set("from", bytes_to_hex_prefixed(&evt.from));
        row.set("to", bytes_to_hex_prefixed(&evt.to));
        row.set("id", evt.id);
        row.set("amount", evt.amount);
    }

    for evt in events.roles_user_kickeds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_roles_user_kicked", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("account", bytes_to_hex_prefixed(&evt.account));
        row.set("sender", bytes_to_hex_prefixed(&evt.sender));
        row.set("user", bytes_to_hex_prefixed(&evt.user));
        row.set("deadline", evt.deadline);
    }

    for evt in events.token_coin_approvals.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_token_coin_approval", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("token_address", evt.token_address);
        row.set("owner", bytes_to_hex_prefixed(&evt.owner));
        row.set("spender", bytes_to_hex_prefixed(&evt.spender));
        row.set("amount", evt.amount);
        row.set("token_layer_id", evt.token_layer_id);
    }

    for evt in events.token_coin_enforced_option_sets.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_token_coin_enforced_option_set", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("token_address", evt.token_address);
        row.set("token_layer_id", evt.token_layer_id);
    }

    for evt in events.token_coin_initializeds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_token_coin_initialized", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("token_address", evt.token_address);
        row.set("version", evt.version as i64);
        row.set("token_layer_id", evt.token_layer_id);
    }

    for evt in events.token_coin_msg_inspector_sets.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_token_coin_msg_inspector_set", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("token_address", evt.token_address);
        row.set("inspector", bytes_to_hex_prefixed(&evt.inspector));
        row.set("token_layer_id", evt.token_layer_id);
    }

    for evt in events.token_coin_oft_receiveds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_token_coin_oft_received", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("token_address", evt.token_address);
        row.set("guid", bytes_to_hex_prefixed(&evt.guid));
        row.set("src_eid", evt.src_eid as i64);
        row.set("to_address", bytes_to_hex_prefixed(&evt.to_address));
        row.set("amount_received_ld", evt.amount_received_ld);
        row.set("token_layer_id", evt.token_layer_id);
    }

    for evt in events.token_coin_oft_sents.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_token_coin_oft_sent", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("token_address", evt.token_address);
        row.set("guid", bytes_to_hex_prefixed(&evt.guid));
        row.set("dst_eid", evt.dst_eid as i64);
        row.set("from_address", bytes_to_hex_prefixed(&evt.from_address));
        row.set("amount_sent_ld", evt.amount_sent_ld);
        row.set("amount_received_ld", evt.amount_received_ld);
        row.set("token_layer_id", evt.token_layer_id);
    }

    for evt in events.token_coin_ownership_transferreds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_token_coin_ownership_transferred", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("token_address", evt.token_address);
        row.set("previous_owner", bytes_to_hex_prefixed(&evt.previous_owner));
        row.set("new_owner", bytes_to_hex_prefixed(&evt.new_owner));
        row.set("token_layer_id", evt.token_layer_id);
    }

    for evt in events.token_coin_peer_sets.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_token_coin_peer_set", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("token_address", evt.token_address);
        row.set("eid", evt.eid as i64);
        row.set("peer", bytes_to_hex_prefixed(&evt.peer));
        row.set("token_layer_id", evt.token_layer_id);
    }

    for evt in events.token_coin_pre_crime_sets.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_token_coin_pre_crime_set", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("token_address", evt.token_address);
        row.set("pre_crime_address", bytes_to_hex_prefixed(&evt.pre_crime_address));
        row.set("token_layer_id", evt.token_layer_id);
    }

    for evt in events.token_coin_transfers.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_token_coin_transfer", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("token_address", evt.token_address);
        row.set("from", bytes_to_hex_prefixed(&evt.from));
        row.set("to", bytes_to_hex_prefixed(&evt.to));
        row.set("amount", evt.amount);
        row.set("token_layer_id", evt.token_layer_id);
    }

    for evt in events.uniswap_v3_swaps.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_uniswap_v3_swap", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("pool", evt.pool);
        row.set("sender", evt.sender);
        row.set("recipient", evt.recipient);
        row.set("amount0", evt.amount0);
        row.set("amount1", evt.amount1);
        row.set("sqrt_price_x96", evt.sqrt_price_x96);
        row.set("liquidity", evt.liquidity);
        row.set("tick", evt.tick);
        row.set("token_address", evt.token_address);
        row.set("token_layer_id", evt.token_layer_id);
    }

    for evt in events.uniswap_v3_pool_createds.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_uniswap_v3_pool_created", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("pool", evt.pool);
        row.set("token0", evt.token0);
        row.set("token1", evt.token1);
        row.set("fee", evt.fee as i64);
        row.set("sqrt_price_x96", evt.sqrt_price_x96);
        row.set("token_address", evt.token_address);
        row.set("token_layer_id", evt.token_layer_id);
    }

    for evt in events.uniswap_v3_mints.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_uniswap_v3_mint", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("pool", evt.pool);
        row.set("owner", evt.owner);
        row.set("sender", evt.sender);
        row.set("tick_lower", evt.tick_lower);
        row.set("tick_upper", evt.tick_upper);
        row.set("amount", evt.amount);
        row.set("amount0", evt.amount0);
        row.set("amount1", evt.amount1);
        row.set("token_address", evt.token_address);
        row.set("token_layer_id", evt.token_layer_id);
    }

    for evt in events.uniswap_v3_burns.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let row = tables.create_row("raw_uniswap_v3_burn", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt.evt_tx_hash);
        row.set("evt_index", evt.evt_index as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        row.set("pool", evt.pool);
        row.set("owner", evt.owner);
        row.set("tick_lower", evt.tick_lower);
        row.set("tick_upper", evt.tick_upper);
        row.set("amount", evt.amount);
        row.set("amount0", evt.amount0);
        row.set("amount1", evt.amount1);
        row.set("token_address", evt.token_address);
        row.set("token_layer_id", evt.token_layer_id);
    }

    for (idx, evt) in events.wallet_token_balances.into_iter().enumerate() {
        let token_address = evt.token_address.clone();
        let wallet = evt.wallet.clone();
        let balance = evt.balance.clone();
        let row_id = format!("{}:{}:{}:{}", token_address, wallet, evt.evt_block_number, idx);
        let row = tables.create_row("agg_wallet_token_balance", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("token_address", evt.token_address);
        row.set("token_layer_id", evt.token_layer_id.clone());
        row.set("wallet", evt.wallet);
        row.set("balance", evt.balance);
        let current_id = format!("{}:{}", token_address, wallet);
        let current = tables.upsert_row("cur_wallet_token_balance", current_id);
        current.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { current.set("_block_timestamp_", value.clone()); }
        current.set("evt_block_number", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { current.set("evt_block_time", value); }
        current.set("token_address", token_address);
        current.set("token_layer_id", evt.token_layer_id);
        current.set("wallet", wallet);
        current.set("balance", balance);
    }

    for evt in events.user_fee_balance_currents.into_iter() {
        let row_id = format!("{}:{}", evt.account, evt.currency);
        let row = tables.upsert_row("cur_user_fee_balance", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("account", evt.account);
        row.set("currency", evt.currency);
        row.set("balance", evt.balance);
    }

    for evt in events.protocol_fee_balance_currents.into_iter() {
        let row_id = evt.currency.clone();
        let row = tables.upsert_row("cur_protocol_fee_balance", row_id);
        row.set("_block_number_", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_block_number", evt.evt_block_number as i64);
        if let Some(value) = evt.evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("currency", evt.currency);
        row.set("balance", evt.balance);
    }

    for evt in events.agg_token_trades.into_iter() {
        let row_id = event_row_id(&evt.evt_tx_hash, evt.evt_index);
        let evt_tx_hash = evt.evt_tx_hash.clone();
        let evt_index = evt.evt_index as i64;
        let evt_block_number = evt.evt_block_number as i64;
        let evt_block_time = evt.evt_block_time.clone();
        let token_layer_id = evt.token_layer_id.clone();
        let token_address = evt.token_address.clone();
        let price_usd = evt.price_usd.clone();
        let row = tables.create_row("agg_token_trade", row_id);
        row.set("_block_number_", evt_block_number);
        if let Some(value) = evt_block_time.clone() { row.set("_block_timestamp_", value.clone()); }
        row.set("evt_tx_hash", evt_tx_hash.clone());
        row.set("evt_index", evt_index);
        if let Some(value) = evt_block_time.clone() { row.set("evt_block_time", value); }
        row.set("evt_block_number", evt_block_number);
        row.set("venue", evt.venue);
        row.set("trade_type", evt.trade_type);
        row.set("wallet", evt.wallet);
        row.set("token_address", token_address.clone());
        row.set("pool", evt.pool);
        if !evt.token_amount.is_empty() {
            row.set("token_amount", evt.token_amount);
        }
        if !evt.token_amount_raw.is_empty() {
            row.set("token_amount_raw", evt.token_amount_raw);
        }
        if !evt.usd_amount.is_empty() {
            row.set("usd_amount", evt.usd_amount);
        }
        if !evt.usd_amount_raw.is_empty() {
            row.set("usd_amount_raw", evt.usd_amount_raw);
        }
        if !price_usd.is_empty() {
            row.set("price_usd", price_usd.clone());
        }
        if !evt.market_cap_usd.is_empty() {
            row.set("market_cap_usd", evt.market_cap_usd);
        }
        row.set("token_decimals", evt.token_decimals as i64);
        row.set("quote_decimals", evt.quote_decimals as i64);
        row.set("token_decimals_source", evt.token_decimals_source);
        row.set("quote_decimals_source", evt.quote_decimals_source);
        row.set("token_layer_id", token_layer_id.clone());

        if !price_usd.is_empty() {
            let price_row_id = format!("{}:{}:price", evt_tx_hash, evt_index);
            let price_row = tables.create_row("agg_token_price_usd", price_row_id);
            price_row.set("_block_number_", evt_block_number);
            if let Some(value) = evt_block_time.clone() { price_row.set("_block_timestamp_", value.clone()); }
            price_row.set("evt_tx_hash", evt_tx_hash.clone());
            price_row.set("evt_index", evt_index);
            if let Some(value) = evt_block_time.clone() { price_row.set("evt_block_time", value); }
            price_row.set("evt_block_number", evt_block_number);
            price_row.set("token_layer_id", token_layer_id.clone());
            price_row.set("token_address", token_address.clone());
            price_row.set("price_usd", price_usd.clone());

            let current_id = if !token_layer_id.is_empty() {
                token_layer_id.clone()
            } else {
                format!("addr:{}", token_address)
            };
            let current = tables.upsert_row("cur_token_price_usd", current_id);
            current.set("_block_number_", evt_block_number);
            if let Some(value) = evt_block_time.clone() { current.set("_block_timestamp_", value.clone()); }
            current.set("evt_tx_hash", evt_tx_hash);
            current.set("evt_index", evt_index);
            if let Some(value) = evt_block_time.clone() { current.set("evt_block_time", value); }
            current.set("evt_block_number", evt_block_number);
            current.set("token_layer_id", token_layer_id);
            current.set("token_address", token_address);
            current.set("price_usd", price_usd);
        }
    }

    tables.to_database_changes()
}
