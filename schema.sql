-- Generated from proto/contract.proto for DatabaseChanges sink

CREATE TABLE IF NOT EXISTS "raw_registry_adapter_deployed" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "adapter" TEXT,
  "external_token" TEXT,
  "wrapped_token" TEXT,
  "adapter_type" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_registry_adapterdeployed_evt_block_number" ON "raw_registry_adapter_deployed" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_registry_adapterdeployed_evt_tx_hash" ON "raw_registry_adapter_deployed" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_registry_adapter_template_reset" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "template_id" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_registry_adaptertemplatereset_evt_block_number" ON "raw_registry_adapter_template_reset" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_registry_adaptertemplatereset_evt_tx_hash" ON "raw_registry_adapter_template_reset" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_registry_adapter_template_set" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "template_id" TEXT,
  "adapter_type" NUMERIC,
  "implementation_address" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_registry_adaptertemplateset_evt_block_number" ON "raw_registry_adapter_template_set" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_registry_adaptertemplateset_evt_tx_hash" ON "raw_registry_adapter_template_set" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_registry_builder_fees_approved" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "user" TEXT,
  "builder" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_registry_builderfeesapproved_evt_block_number" ON "raw_registry_builder_fees_approved" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_registry_builderfeesapproved_evt_tx_hash" ON "raw_registry_builder_fees_approved" ("evt_tx_hash");
CREATE INDEX IF NOT EXISTS "idx_registry_builderfeesapproved_user" ON "raw_registry_builder_fees_approved" ("user");

CREATE TABLE IF NOT EXISTS "raw_registry_coin_created" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "coin_address" TEXT,
  "hub_id" TEXT,
  "name" TEXT,
  "symbol" TEXT,
  "decimals" NUMERIC,
  "token_uri" TEXT,
  "total_supply" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_registry_coincreated_evt_block_number" ON "raw_registry_coin_created" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_registry_coincreated_evt_tx_hash" ON "raw_registry_coin_created" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_registry_contract_address_overwritten" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "identifier" TEXT,
  "old_address" TEXT,
  "new_address" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_registry_contractaddressoverwritten_evt_block_number" ON "raw_registry_contract_address_overwritten" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_registry_contractaddressoverwritten_evt_tx_hash" ON "raw_registry_contract_address_overwritten" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_registry_contract_deployed" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "name" TEXT,
  "contract_address" TEXT,
  "salt" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_registry_contractdeployed_evt_block_number" ON "raw_registry_contract_deployed" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_registry_contractdeployed_evt_tx_hash" ON "raw_registry_contract_deployed" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_registry_external_token_created" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "token_id" TEXT,
  "token_address" TEXT,
  "adapter" TEXT,
  "external_token" TEXT,
  "name" TEXT,
  "symbol" TEXT,
  "adapter_type" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_registry_externaltokencreated_evt_block_number" ON "raw_registry_external_token_created" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_registry_externaltokencreated_evt_tx_hash" ON "raw_registry_external_token_created" ("evt_tx_hash");
CREATE INDEX IF NOT EXISTS "idx_registry_externaltokencreated_token_address" ON "raw_registry_external_token_created" ("token_address");

CREATE TABLE IF NOT EXISTS "raw_registry_hub_created" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "id" TEXT,
  "creator" TEXT,
  "receiver" TEXT,
  "is_private" BOOLEAN
);
CREATE INDEX IF NOT EXISTS "idx_registry_hubcreated_evt_block_number" ON "raw_registry_hub_created" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_registry_hubcreated_evt_tx_hash" ON "raw_registry_hub_created" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_registry_hubs_address_changed" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "new_address" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_registry_hubsaddresschanged_evt_block_number" ON "raw_registry_hubs_address_changed" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_registry_hubsaddresschanged_evt_tx_hash" ON "raw_registry_hubs_address_changed" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_registry_initialized" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "version" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_registry_initialized_evt_block_number" ON "raw_registry_initialized" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_registry_initialized_evt_tx_hash" ON "raw_registry_initialized" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_registry_item_created" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "id" TEXT,
  "hub_id" TEXT,
  "symbol" TEXT,
  "name" TEXT,
  "token_uri" TEXT,
  "decimals" NUMERIC,
  "pool_type" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_registry_itemcreated_evt_block_number" ON "raw_registry_item_created" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_registry_itemcreated_evt_tx_hash" ON "raw_registry_item_created" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_registry_items_address_changed" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "new_address" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_registry_itemsaddresschanged_evt_block_number" ON "raw_registry_items_address_changed" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_registry_itemsaddresschanged_evt_tx_hash" ON "raw_registry_items_address_changed" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_registry_launchpad_address_changed" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "new_address" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_registry_launchpadaddresschanged_evt_block_number" ON "raw_registry_launchpad_address_changed" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_registry_launchpadaddresschanged_evt_tx_hash" ON "raw_registry_launchpad_address_changed" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_registry_liquidity_manager_address_changed" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "new_address" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_registry_liquiditymanageraddresschanged_evt_block_number" ON "raw_registry_liquidity_manager_address_changed" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_registry_liquiditymanageraddresschanged_evt_tx_hash" ON "raw_registry_liquidity_manager_address_changed" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_registry_liquidity_migrator_address_changed" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "new_address" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_registry_liquiditymigratoraddresschanged_evt_block_number" ON "raw_registry_liquidity_migrator_address_changed" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_registry_liquiditymigratoraddresschanged_evt_tx_hash" ON "raw_registry_liquidity_migrator_address_changed" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_registry_manager_updated" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "manager" TEXT,
  "authorized" BOOLEAN
);
CREATE INDEX IF NOT EXISTS "idx_registry_managerupdated_evt_block_number" ON "raw_registry_manager_updated" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_registry_managerupdated_evt_tx_hash" ON "raw_registry_manager_updated" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_registry_oapp_configured" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "endpoint_id" NUMERIC,
  "token_id" TEXT,
  "token_address" TEXT,
  "send_library" TEXT,
  "receive_library" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_registry_oappconfigured_evt_block_number" ON "raw_registry_oapp_configured" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_registry_oappconfigured_evt_tx_hash" ON "raw_registry_oapp_configured" ("evt_tx_hash");
CREATE INDEX IF NOT EXISTS "idx_registry_oappconfigured_token_address" ON "raw_registry_oapp_configured" ("token_address");

CREATE TABLE IF NOT EXISTS "raw_registry_ownership_transferred" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "user" TEXT,
  "new_owner" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_registry_ownershiptransferred_evt_block_number" ON "raw_registry_ownership_transferred" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_registry_ownershiptransferred_evt_tx_hash" ON "raw_registry_ownership_transferred" ("evt_tx_hash");
CREATE INDEX IF NOT EXISTS "idx_registry_ownershiptransferred_user" ON "raw_registry_ownership_transferred" ("user");

CREATE TABLE IF NOT EXISTS "raw_registry_peer_set" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "endpoint_id" NUMERIC,
  "token_id" TEXT,
  "token_address" TEXT,
  "peer_address" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_registry_peerset_evt_block_number" ON "raw_registry_peer_set" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_registry_peerset_evt_tx_hash" ON "raw_registry_peer_set" ("evt_tx_hash");
CREATE INDEX IF NOT EXISTS "idx_registry_peerset_token_address" ON "raw_registry_peer_set" ("token_address");

CREATE TABLE IF NOT EXISTS "raw_registry_points_created" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "id" TEXT,
  "hub_id" TEXT,
  "name" TEXT,
  "symbol" TEXT,
  "uri" TEXT,
  "soulbound" BOOLEAN
);
CREATE INDEX IF NOT EXISTS "idx_registry_pointscreated_evt_block_number" ON "raw_registry_points_created" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_registry_pointscreated_evt_tx_hash" ON "raw_registry_points_created" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_registry_protocol_bonus_config_set" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "duration_blocks" NUMERIC,
  "start_percentage_bps" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_registry_protocolbonusconfigset_evt_block_number" ON "raw_registry_protocol_bonus_config_set" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_registry_protocolbonusconfigset_evt_tx_hash" ON "raw_registry_protocol_bonus_config_set" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_registry_protocol_fee_set" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "activity" NUMERIC,
  "fee_bps" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_registry_protocolfeeset_evt_block_number" ON "raw_registry_protocol_fee_set" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_registry_protocolfeeset_evt_tx_hash" ON "raw_registry_protocol_fee_set" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_registry_protocol_limit_set" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "activity" NUMERIC,
  "max_fee_bps" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_registry_protocollimitset_evt_block_number" ON "raw_registry_protocol_limit_set" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_registry_protocollimitset_evt_tx_hash" ON "raw_registry_protocol_limit_set" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_registry_referral_set" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "referee" TEXT,
  "referrer" TEXT,
  "reward_active" BOOLEAN,
  "discount_active" BOOLEAN
);
CREATE INDEX IF NOT EXISTS "idx_registry_referralset_evt_block_number" ON "raw_registry_referral_set" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_registry_referralset_evt_tx_hash" ON "raw_registry_referral_set" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_registry_referral_status_updated" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "referee" TEXT,
  "reward_active" BOOLEAN,
  "discount_active" BOOLEAN
);
CREATE INDEX IF NOT EXISTS "idx_registry_referralstatusupdated_evt_block_number" ON "raw_registry_referral_status_updated" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_registry_referralstatusupdated_evt_tx_hash" ON "raw_registry_referral_status_updated" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_registry_referrals_controller_updated" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "old_controller" TEXT,
  "new_controller" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_registry_referralscontrollerupdated_evt_block_number" ON "raw_registry_referrals_controller_updated" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_registry_referralscontrollerupdated_evt_tx_hash" ON "raw_registry_referrals_controller_updated" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_registry_registry_initialized" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "owner" TEXT,
  "trusted_forwarder" TEXT,
  "payment_token" TEXT,
  "protocol_fee_to" TEXT,
  "endpoint" TEXT,
  "swap_router" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_registry_registryinitialized_evt_block_number" ON "raw_registry_registry_initialized" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_registry_registryinitialized_evt_tx_hash" ON "raw_registry_registry_initialized" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_registry_token_created" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "token_address" TEXT,
  "token_id" TEXT,
  "ip_id" TEXT,
  "symbol" TEXT,
  "name" TEXT,
  "token_uri" TEXT,
  "decimals" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_registry_tokencreated_evt_block_number" ON "raw_registry_token_created" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_registry_tokencreated_evt_tx_hash" ON "raw_registry_token_created" ("evt_tx_hash");
CREATE INDEX IF NOT EXISTS "idx_registry_tokencreated_token_address" ON "raw_registry_token_created" ("token_address");

CREATE TABLE IF NOT EXISTS "raw_registry_token_registered" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "token_id" TEXT,
  "token_address" TEXT,
  "template_id" TEXT,
  "name" TEXT,
  "symbol" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_registry_tokenregistered_evt_block_number" ON "raw_registry_token_registered" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_registry_tokenregistered_evt_tx_hash" ON "raw_registry_token_registered" ("evt_tx_hash");
CREATE INDEX IF NOT EXISTS "idx_registry_tokenregistered_token_address" ON "raw_registry_token_registered" ("token_address");

CREATE TABLE IF NOT EXISTS "raw_registry_token_template_reset" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "template_id" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_registry_tokentemplatereset_evt_block_number" ON "raw_registry_token_template_reset" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_registry_tokentemplatereset_evt_tx_hash" ON "raw_registry_token_template_reset" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_registry_token_template_set" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "template_id" TEXT,
  "token_type" NUMERIC,
  "implementation_address" TEXT,
  "total_supply" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_registry_tokentemplateset_evt_block_number" ON "raw_registry_token_template_set" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_registry_tokentemplateset_evt_tx_hash" ON "raw_registry_token_template_set" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_registry_whitelist_toggled" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "contract_address" TEXT,
  "whitelisted" BOOLEAN
);
CREATE INDEX IF NOT EXISTS "idx_registry_whitelisttoggled_evt_block_number" ON "raw_registry_whitelist_toggled" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_registry_whitelisttoggled_evt_tx_hash" ON "raw_registry_whitelist_toggled" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_oapp_eth_withdrawn" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "owner" TEXT,
  "amount" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_oapp_ethwithdrawn_evt_block_number" ON "raw_oapp_eth_withdrawn" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_oapp_ethwithdrawn_evt_tx_hash" ON "raw_oapp_eth_withdrawn" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_oapp_enforced_option_set" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_oapp_enforcedoptionset_evt_block_number" ON "raw_oapp_enforced_option_set" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_oapp_enforcedoptionset_evt_tx_hash" ON "raw_oapp_enforced_option_set" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_oapp_message_received" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "guid" TEXT,
  "src_eid" NUMERIC,
  "msg_type" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_oapp_messagereceived_evt_block_number" ON "raw_oapp_message_received" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_oapp_messagereceived_evt_tx_hash" ON "raw_oapp_message_received" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_oapp_operation_created" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "operation_id" NUMERIC,
  "token_id" TEXT,
  "dst_eid" NUMERIC,
  "operation_type" NUMERIC,
  "amount" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_oapp_operationcreated_evt_block_number" ON "raw_oapp_operation_created" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_oapp_operationcreated_evt_tx_hash" ON "raw_oapp_operation_created" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_oapp_ownership_transferred" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "user" TEXT,
  "new_owner" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_oapp_ownershiptransferred_evt_block_number" ON "raw_oapp_ownership_transferred" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_oapp_ownershiptransferred_evt_tx_hash" ON "raw_oapp_ownership_transferred" ("evt_tx_hash");
CREATE INDEX IF NOT EXISTS "idx_oapp_ownershiptransferred_user" ON "raw_oapp_ownership_transferred" ("user");

CREATE TABLE IF NOT EXISTS "raw_oapp_peer_set" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "eid" NUMERIC,
  "peer" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_oapp_peerset_evt_block_number" ON "raw_oapp_peer_set" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_oapp_peerset_evt_tx_hash" ON "raw_oapp_peer_set" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_oapp_solana_liquidity_manager_set" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "liquidity_manager" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_oapp_solanaliquiditymanagerset_evt_block_number" ON "raw_oapp_solana_liquidity_manager_set" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_oapp_solanaliquiditymanagerset_evt_tx_hash" ON "raw_oapp_solana_liquidity_manager_set" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_oapp_token_liquidity_initialized_externally" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "token_id" TEXT,
  "src_eid" NUMERIC,
  "dst_eid" NUMERIC,
  "amount" NUMERIC,
  "price_in_wei" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_oapp_tokenliquidityinitializedexternally_evt_block_number" ON "raw_oapp_token_liquidity_initialized_externally" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_oapp_tokenliquidityinitializedexternally_evt_tx_hash" ON "raw_oapp_token_liquidity_initialized_externally" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_oapp_token_registered_externally" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "token_id" TEXT,
  "src_eid" NUMERIC,
  "dst_eid" NUMERIC,
  "operation_id" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_oapp_tokenregisteredexternally_evt_block_number" ON "raw_oapp_token_registered_externally" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_oapp_tokenregisteredexternally_evt_tx_hash" ON "raw_oapp_token_registered_externally" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_oapp_token_registration_ack" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "guid" TEXT,
  "success" BOOLEAN
);
CREATE INDEX IF NOT EXISTS "idx_oapp_tokenregistrationack_evt_block_number" ON "raw_oapp_token_registration_ack" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_oapp_tokenregistrationack_evt_tx_hash" ON "raw_oapp_token_registration_ack" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_oapp_token_registration_ack_processed" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "token_id" TEXT,
  "src_eid" NUMERIC,
  "dst_eid" NUMERIC,
  "success" BOOLEAN,
  "remote_token_address" TEXT,
  "operation_id" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_oapp_tokenregistrationackprocessed_evt_block_number" ON "raw_oapp_token_registration_ack_processed" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_oapp_tokenregistrationackprocessed_evt_tx_hash" ON "raw_oapp_token_registration_ack_processed" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_oapp_token_registration_ack_sent" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "token_id" TEXT,
  "dst_eid" NUMERIC,
  "success" BOOLEAN,
  "operation_id" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_oapp_tokenregistrationacksent_evt_block_number" ON "raw_oapp_token_registration_ack_sent" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_oapp_tokenregistrationacksent_evt_tx_hash" ON "raw_oapp_token_registration_ack_sent" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_oapp_token_registration_initiated" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "token_id" TEXT,
  "dst_eid" NUMERIC,
  "operation_id" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_oapp_tokenregistrationinitiated_evt_block_number" ON "raw_oapp_token_registration_initiated" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_oapp_tokenregistrationinitiated_evt_tx_hash" ON "raw_oapp_token_registration_initiated" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_oapp_token_registration_received" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "token_id" TEXT,
  "src_eid" NUMERIC,
  "source_token_address" TEXT,
  "operation_id" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_oapp_tokenregistrationreceived_evt_block_number" ON "raw_oapp_token_registration_received" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_oapp_tokenregistrationreceived_evt_tx_hash" ON "raw_oapp_token_registration_received" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_manager_builder_activity_fee_set" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "builder" TEXT,
  "activity_id" TEXT,
  "fee_percent" NUMERIC,
  "flat_fee" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_manager_builderactivityfeeset_evt_block_number" ON "raw_manager_builder_activity_fee_set" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_manager_builderactivityfeeset_evt_tx_hash" ON "raw_manager_builder_activity_fee_set" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_manager_external_whitelist_changed" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "token_id" TEXT,
  "signer" TEXT,
  "status" BOOLEAN
);
CREATE INDEX IF NOT EXISTS "idx_manager_externalwhitelistchanged_evt_block_number" ON "raw_manager_external_whitelist_changed" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_manager_externalwhitelistchanged_evt_tx_hash" ON "raw_manager_external_whitelist_changed" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_manager_fees_paid" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "hub_id" TEXT,
  "activity_id" TEXT,
  "contract_address" TEXT,
  "sender" TEXT,
  "protocol_amount" NUMERIC,
  "hub_amount" NUMERIC,
  "builder" TEXT,
  "builder_amount" NUMERIC,
  "payment_token" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_manager_feespaid_evt_block_number" ON "raw_manager_fees_paid" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_manager_feespaid_evt_tx_hash" ON "raw_manager_fees_paid" ("evt_tx_hash");
CREATE INDEX IF NOT EXISTS "idx_manager_feespaid_sender" ON "raw_manager_fees_paid" ("sender");

CREATE TABLE IF NOT EXISTS "raw_manager_initialized" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "version" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_manager_initialized_evt_block_number" ON "raw_manager_initialized" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_manager_initialized_evt_tx_hash" ON "raw_manager_initialized" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_manager_ownership_transferred" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "user" TEXT,
  "new_owner" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_manager_ownershiptransferred_evt_block_number" ON "raw_manager_ownership_transferred" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_manager_ownershiptransferred_evt_tx_hash" ON "raw_manager_ownership_transferred" ("evt_tx_hash");
CREATE INDEX IF NOT EXISTS "idx_manager_ownershiptransferred_user" ON "raw_manager_ownership_transferred" ("user");

CREATE TABLE IF NOT EXISTS "raw_launchpad_buy" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "token_id" TEXT,
  "token_address" TEXT,
  "trader" TEXT,
  "receiver" TEXT,
  "amount_in" NUMERIC,
  "tokens_out" NUMERIC,
  "price" NUMERIC,
  "liquidity_wei" NUMERIC,
  "supply" NUMERIC,
  "tokens_left" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_launchpad_buy_evt_block_number" ON "raw_launchpad_buy" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_launchpad_buy_evt_tx_hash" ON "raw_launchpad_buy" ("evt_tx_hash");
CREATE INDEX IF NOT EXISTS "idx_launchpad_buy_trader" ON "raw_launchpad_buy" ("trader");
CREATE INDEX IF NOT EXISTS "idx_launchpad_buy_token_address" ON "raw_launchpad_buy" ("token_address");

CREATE TABLE IF NOT EXISTS "raw_launchpad_new_pool_type" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "pool_type_id" TEXT,
  "migration_supply" NUMERIC,
  "price_at_migration_supply" NUMERIC,
  "initial_token_deposit_wad" NUMERIC,
  "initial_reserve_deposit_wad" NUMERIC,
  "creator_reward" NUMERIC,
  "migration_reserve_supply" NUMERIC,
  "migration_token_supply" NUMERIC,
  "weight" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_launchpad_newpooltype_evt_block_number" ON "raw_launchpad_new_pool_type" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_launchpad_newpooltype_evt_tx_hash" ON "raw_launchpad_new_pool_type" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_launchpad_ownership_transferred" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "user" TEXT,
  "new_owner" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_launchpad_ownershiptransferred_evt_block_number" ON "raw_launchpad_ownership_transferred" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_launchpad_ownershiptransferred_evt_tx_hash" ON "raw_launchpad_ownership_transferred" ("evt_tx_hash");
CREATE INDEX IF NOT EXISTS "idx_launchpad_ownershiptransferred_user" ON "raw_launchpad_ownership_transferred" ("user");

CREATE TABLE IF NOT EXISTS "raw_launchpad_phase_expiry_config_set" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "phase1_expiry_blocks" NUMERIC,
  "phase2_expiry_blocks" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_launchpad_phaseexpiryconfigset_evt_block_number" ON "raw_launchpad_phase_expiry_config_set" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_launchpad_phaseexpiryconfigset_evt_tx_hash" ON "raw_launchpad_phase_expiry_config_set" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_launchpad_sell" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "token_id" TEXT,
  "token_address" TEXT,
  "trader" TEXT,
  "tokens_in" NUMERIC,
  "amount_out" NUMERIC,
  "price" NUMERIC,
  "liquidity_wei" NUMERIC,
  "supply" NUMERIC,
  "tokens_left" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_launchpad_sell_evt_block_number" ON "raw_launchpad_sell" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_launchpad_sell_evt_tx_hash" ON "raw_launchpad_sell" ("evt_tx_hash");
CREATE INDEX IF NOT EXISTS "idx_launchpad_sell_trader" ON "raw_launchpad_sell" ("trader");
CREATE INDEX IF NOT EXISTS "idx_launchpad_sell_token_address" ON "raw_launchpad_sell" ("token_address");

CREATE TABLE IF NOT EXISTS "raw_launchpad_graduation" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "token_id" TEXT,
  "token_layer_id" TEXT,
  "token_address" TEXT,
  "is_external" BOOLEAN,
  "final_supply" NUMERIC,
  "final_reserves" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_launchpad_graduation_evt_block_number" ON "raw_launchpad_graduation" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_launchpad_graduation_evt_tx_hash" ON "raw_launchpad_graduation" ("evt_tx_hash");
CREATE INDEX IF NOT EXISTS "idx_launchpad_graduation_token_id" ON "raw_launchpad_graduation" ("token_id");
CREATE INDEX IF NOT EXISTS "idx_launchpad_graduation_token_layer_id" ON "raw_launchpad_graduation" ("token_layer_id");
CREATE INDEX IF NOT EXISTS "idx_launchpad_graduation_token_address" ON "raw_launchpad_graduation" ("token_address");

CREATE TABLE IF NOT EXISTS "raw_ip_approval" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "owner" TEXT,
  "spender" TEXT,
  "id" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_ip_approval_evt_block_number" ON "raw_ip_approval" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_ip_approval_evt_tx_hash" ON "raw_ip_approval" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_ip_approval_for_all" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "owner" TEXT,
  "operator" TEXT,
  "approved" BOOLEAN
);
CREATE INDEX IF NOT EXISTS "idx_ip_approvalforall_evt_block_number" ON "raw_ip_approval_for_all" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_ip_approvalforall_evt_tx_hash" ON "raw_ip_approval_for_all" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_ip_manager_changed" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "new_manager" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_ip_managerchanged_evt_block_number" ON "raw_ip_manager_changed" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_ip_managerchanged_evt_tx_hash" ON "raw_ip_manager_changed" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_ip_transfer" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "from" TEXT,
  "to" TEXT,
  "id" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_ip_transfer_evt_block_number" ON "raw_ip_transfer" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_ip_transfer_evt_tx_hash" ON "raw_ip_transfer" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_liquidity_mananager_fees_collected" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "key_id" TEXT,
  "token_layer_id" TEXT,
  "token_id" TEXT,
  "amount0" NUMERIC,
  "amount1" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_liquiditymananager_feescollected_evt_block_number" ON "raw_liquidity_mananager_fees_collected" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_liquiditymananager_feescollected_evt_tx_hash" ON "raw_liquidity_mananager_fees_collected" ("evt_tx_hash");
CREATE INDEX IF NOT EXISTS "idx_liquiditymananager_feescollected_token_layer_id" ON "raw_liquidity_mananager_fees_collected" ("token_layer_id");

CREATE TABLE IF NOT EXISTS "raw_liquidity_mananager_fees_distributed" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "key_id" TEXT,
  "token_layer_id" TEXT,
  "token_id" TEXT,
  "token0" TEXT,
  "token1" TEXT,
  "owner" TEXT,
  "amount0_owner" NUMERIC,
  "amount1_owner" NUMERIC,
  "protocol_fee_to" TEXT,
  "amount0_protocol" NUMERIC,
  "amount1_protocol" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_liquiditymananager_feesdistributed_evt_block_number" ON "raw_liquidity_mananager_fees_distributed" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_liquiditymananager_feesdistributed_evt_tx_hash" ON "raw_liquidity_mananager_fees_distributed" ("evt_tx_hash");
CREATE INDEX IF NOT EXISTS "idx_liquiditymananager_feesdistributed_token_layer_id" ON "raw_liquidity_mananager_fees_distributed" ("token_layer_id");

CREATE TABLE IF NOT EXISTS "raw_liquidity_mananager_initial_position_minted" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "token_id" TEXT,
  "key_id" TEXT,
  "token_layer_id" TEXT,
  "token0" TEXT,
  "token1" TEXT,
  "liquidity" NUMERIC,
  "amount0" NUMERIC,
  "amount1" NUMERIC,
  "tick_lower" NUMERIC,
  "tick_upper" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_liquiditymananager_initialpositionminted_evt_block_number" ON "raw_liquidity_mananager_initial_position_minted" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_liquiditymananager_initialpositionminted_evt_tx_hash" ON "raw_liquidity_mananager_initial_position_minted" ("evt_tx_hash");
CREATE INDEX IF NOT EXISTS "idx_liquiditymananager_initialpositionminted_token_layer_id" ON "raw_liquidity_mananager_initial_position_minted" ("token_layer_id");

CREATE TABLE IF NOT EXISTS "raw_liquidity_mananager_initialized" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "version" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_liquiditymananager_initialized_evt_block_number" ON "raw_liquidity_mananager_initialized" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_liquiditymananager_initialized_evt_tx_hash" ON "raw_liquidity_mananager_initialized" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_liquidity_mananager_liquidity_increased" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "token_id" TEXT,
  "liquidity_added" NUMERIC,
  "amount0" NUMERIC,
  "amount1" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_liquiditymananager_liquidityincreased_evt_block_number" ON "raw_liquidity_mananager_liquidity_increased" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_liquiditymananager_liquidityincreased_evt_tx_hash" ON "raw_liquidity_mananager_liquidity_increased" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_liquidity_mananager_liquidity_manager_initialized" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "nonfungible_position_manager" TEXT,
  "registry" TEXT,
  "owner" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_liquiditymananager_liquiditymanagerinitialized_evt_block_number" ON "raw_liquidity_mananager_liquidity_manager_initialized" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_liquiditymananager_liquiditymanagerinitialized_evt_tx_hash" ON "raw_liquidity_mananager_liquidity_manager_initialized" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_liquidity_mananager_liquidity_manager_upgraded" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "old_implementation" TEXT,
  "new_implementation" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_liquiditymananager_liquiditymanagerupgraded_evt_block_number" ON "raw_liquidity_mananager_liquidity_manager_upgraded" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_liquiditymananager_liquiditymanagerupgraded_evt_tx_hash" ON "raw_liquidity_mananager_liquidity_manager_upgraded" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_liquidity_mananager_liquidity_migrated" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "token_id" TEXT,
  "liquidity" NUMERIC,
  "fee" NUMERIC,
  "destination_chain" TEXT,
  "is_default" BOOLEAN
);
CREATE INDEX IF NOT EXISTS "idx_liquiditymananager_liquiditymigrated_evt_block_number" ON "raw_liquidity_mananager_liquidity_migrated" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_liquiditymananager_liquiditymigrated_evt_tx_hash" ON "raw_liquidity_mananager_liquidity_migrated" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_liquidity_mananager_new_deposit" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "token_id" TEXT,
  "liquidity" NUMERIC,
  "token0" TEXT,
  "token1" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_liquiditymananager_newdeposit_evt_block_number" ON "raw_liquidity_mananager_new_deposit" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_liquiditymananager_newdeposit_evt_tx_hash" ON "raw_liquidity_mananager_new_deposit" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_liquidity_mananager_ownership_transferred" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "previous_owner" TEXT,
  "new_owner" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_liquiditymananager_ownershiptransferred_evt_block_number" ON "raw_liquidity_mananager_ownership_transferred" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_liquiditymananager_ownershiptransferred_evt_tx_hash" ON "raw_liquidity_mananager_ownership_transferred" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_liquidity_mananager_pool_created" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "token0" TEXT,
  "token1" TEXT,
  "fee" NUMERIC,
  "sqrt_price_x96" NUMERIC,
  "pool" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_liquiditymananager_poolcreated_evt_block_number" ON "raw_liquidity_mananager_pool_created" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_liquiditymananager_poolcreated_evt_tx_hash" ON "raw_liquidity_mananager_pool_created" ("evt_tx_hash");
CREATE INDEX IF NOT EXISTS "idx_liquiditymananager_poolcreated_pool" ON "raw_liquidity_mananager_pool_created" ("pool");

CREATE TABLE IF NOT EXISTS "raw_liquidity_mananager_position_created_via_compose" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "key_id" TEXT,
  "token_layer_id" TEXT,
  "token_id" TEXT,
  "token0" TEXT,
  "token1" TEXT,
  "amount0" NUMERIC,
  "amount1" NUMERIC,
  "sqrt_price_x96" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_liquiditymananager_positioncreatedviacompose_evt_block_number" ON "raw_liquidity_mananager_position_created_via_compose" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_liquiditymananager_positioncreatedviacompose_evt_tx_hash" ON "raw_liquidity_mananager_position_created_via_compose" ("evt_tx_hash");
CREATE INDEX IF NOT EXISTS "idx_liquiditymananager_positioncreatedviacompose_token_layer_id" ON "raw_liquidity_mananager_position_created_via_compose" ("token_layer_id");

CREATE TABLE IF NOT EXISTS "raw_liquidity_mananager_upgraded" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "implementation" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_liquiditymananager_upgraded_evt_block_number" ON "raw_liquidity_mananager_upgraded" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_liquiditymananager_upgraded_evt_tx_hash" ON "raw_liquidity_mananager_upgraded" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_fees_fee_distributed" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "currency" TEXT,
  "recipient" TEXT,
  "amount" NUMERIC,
  "distribution_type" NUMERIC,
  "tracking_id" TEXT,
  "activity_id" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_fees_feedistributed_evt_block_number" ON "raw_fees_fee_distributed" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_fees_feedistributed_evt_tx_hash" ON "raw_fees_fee_distributed" ("evt_tx_hash");
CREATE INDEX IF NOT EXISTS "idx_fees_feedistributed_recipient" ON "raw_fees_fee_distributed" ("recipient");

CREATE TABLE IF NOT EXISTS "raw_fees_protocol_fee_distributed" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "currency" TEXT,
  "amount" NUMERIC,
  "activity_id" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_fees_protocolfeedistributed_evt_block_number" ON "raw_fees_protocol_fee_distributed" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_fees_protocolfeedistributed_evt_tx_hash" ON "raw_fees_protocol_fee_distributed" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_fees_protocol_fees_controller_updated" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "old_controller" TEXT,
  "new_controller" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_fees_protocolfeescontrollerupdated_evt_block_number" ON "raw_fees_protocol_fees_controller_updated" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_fees_protocolfeescontrollerupdated_evt_tx_hash" ON "raw_fees_protocol_fees_controller_updated" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_fees_protocol_withdrawn" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "currency" TEXT,
  "to" TEXT,
  "amount" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_fees_protocolwithdrawn_evt_block_number" ON "raw_fees_protocol_withdrawn" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_fees_protocolwithdrawn_evt_tx_hash" ON "raw_fees_protocol_withdrawn" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_fees_withdrawn" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "currency" TEXT,
  "recipient" TEXT,
  "to" TEXT,
  "amount" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_fees_withdrawn_evt_block_number" ON "raw_fees_withdrawn" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_fees_withdrawn_evt_tx_hash" ON "raw_fees_withdrawn" ("evt_tx_hash");
CREATE INDEX IF NOT EXISTS "idx_fees_withdrawn_recipient" ON "raw_fees_withdrawn" ("recipient");

CREATE TABLE IF NOT EXISTS "raw_roles_approval" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "owner" TEXT,
  "spender" TEXT,
  "id" TEXT,
  "amount" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_roles_approval_evt_block_number" ON "raw_roles_approval" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_roles_approval_evt_tx_hash" ON "raw_roles_approval" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_roles_ban_removed" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "account" TEXT,
  "sender" TEXT,
  "user" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_roles_banremoved_evt_block_number" ON "raw_roles_ban_removed" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_roles_banremoved_evt_tx_hash" ON "raw_roles_ban_removed" ("evt_tx_hash");
CREATE INDEX IF NOT EXISTS "idx_roles_banremoved_sender" ON "raw_roles_ban_removed" ("sender");
CREATE INDEX IF NOT EXISTS "idx_roles_banremoved_user" ON "raw_roles_ban_removed" ("user");

CREATE TABLE IF NOT EXISTS "raw_roles_manager_changed" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "new_manager" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_roles_managerchanged_evt_block_number" ON "raw_roles_manager_changed" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_roles_managerchanged_evt_tx_hash" ON "raw_roles_manager_changed" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_roles_ownership_transferred" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "user" TEXT,
  "new_owner" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_roles_ownershiptransferred_evt_block_number" ON "raw_roles_ownership_transferred" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_roles_ownershiptransferred_evt_tx_hash" ON "raw_roles_ownership_transferred" ("evt_tx_hash");
CREATE INDEX IF NOT EXISTS "idx_roles_ownershiptransferred_user" ON "raw_roles_ownership_transferred" ("user");

CREATE TABLE IF NOT EXISTS "raw_roles_role_added" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "account" TEXT,
  "role_id" TEXT,
  "order_no" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_roles_roleadded_evt_block_number" ON "raw_roles_role_added" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_roles_roleadded_evt_tx_hash" ON "raw_roles_role_added" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_roles_role_created" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "id" TEXT,
  "name" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_roles_rolecreated_evt_block_number" ON "raw_roles_role_created" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_roles_rolecreated_evt_tx_hash" ON "raw_roles_role_created" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_roles_role_granted" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "id" TEXT,
  "account" TEXT,
  "role_name" TEXT,
  "sender" TEXT,
  "user" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_roles_rolegranted_evt_block_number" ON "raw_roles_role_granted" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_roles_rolegranted_evt_tx_hash" ON "raw_roles_role_granted" ("evt_tx_hash");
CREATE INDEX IF NOT EXISTS "idx_roles_rolegranted_sender" ON "raw_roles_role_granted" ("sender");
CREATE INDEX IF NOT EXISTS "idx_roles_rolegranted_user" ON "raw_roles_role_granted" ("user");

CREATE TABLE IF NOT EXISTS "raw_roles_role_order_updated" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "account" TEXT,
  "role_id" TEXT,
  "order_no" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_roles_roleorderupdated_evt_block_number" ON "raw_roles_role_order_updated" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_roles_roleorderupdated_evt_tx_hash" ON "raw_roles_role_order_updated" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_roles_role_removed" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "account" TEXT,
  "role_id" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_roles_roleremoved_evt_block_number" ON "raw_roles_role_removed" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_roles_roleremoved_evt_tx_hash" ON "raw_roles_role_removed" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_roles_role_renounced" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "account" TEXT,
  "sender" TEXT,
  "id" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_roles_rolerenounced_evt_block_number" ON "raw_roles_role_renounced" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_roles_rolerenounced_evt_tx_hash" ON "raw_roles_role_renounced" ("evt_tx_hash");
CREATE INDEX IF NOT EXISTS "idx_roles_rolerenounced_sender" ON "raw_roles_role_renounced" ("sender");

CREATE TABLE IF NOT EXISTS "raw_roles_role_revoked" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "id" TEXT,
  "account" TEXT,
  "role_name" TEXT,
  "sender" TEXT,
  "user" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_roles_rolerevoked_evt_block_number" ON "raw_roles_role_revoked" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_roles_rolerevoked_evt_tx_hash" ON "raw_roles_role_revoked" ("evt_tx_hash");
CREATE INDEX IF NOT EXISTS "idx_roles_rolerevoked_sender" ON "raw_roles_role_revoked" ("sender");
CREATE INDEX IF NOT EXISTS "idx_roles_rolerevoked_user" ON "raw_roles_role_revoked" ("user");

CREATE TABLE IF NOT EXISTS "raw_roles_transfer" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "caller" TEXT,
  "from" TEXT,
  "to" TEXT,
  "id" TEXT,
  "amount" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_roles_transfer_evt_block_number" ON "raw_roles_transfer" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_roles_transfer_evt_tx_hash" ON "raw_roles_transfer" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_roles_user_kicked" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "account" TEXT,
  "sender" TEXT,
  "user" TEXT,
  "deadline" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_roles_userkicked_evt_block_number" ON "raw_roles_user_kicked" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_roles_userkicked_evt_tx_hash" ON "raw_roles_user_kicked" ("evt_tx_hash");
CREATE INDEX IF NOT EXISTS "idx_roles_userkicked_sender" ON "raw_roles_user_kicked" ("sender");
CREATE INDEX IF NOT EXISTS "idx_roles_userkicked_user" ON "raw_roles_user_kicked" ("user");

CREATE TABLE IF NOT EXISTS "raw_token_coin_approval" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "token_address" TEXT,
  "owner" TEXT,
  "spender" TEXT,
  "amount" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_tokencoin_approval_evt_block_number" ON "raw_token_coin_approval" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_tokencoin_approval_evt_tx_hash" ON "raw_token_coin_approval" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_token_coin_enforced_option_set" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "token_address" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_tokencoin_enforcedoptionset_evt_block_number" ON "raw_token_coin_enforced_option_set" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_tokencoin_enforcedoptionset_evt_tx_hash" ON "raw_token_coin_enforced_option_set" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_token_coin_initialized" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "token_address" TEXT,
  "version" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_tokencoin_initialized_evt_block_number" ON "raw_token_coin_initialized" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_tokencoin_initialized_evt_tx_hash" ON "raw_token_coin_initialized" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_token_coin_msg_inspector_set" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "token_address" TEXT,
  "inspector" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_tokencoin_msginspectorset_evt_block_number" ON "raw_token_coin_msg_inspector_set" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_tokencoin_msginspectorset_evt_tx_hash" ON "raw_token_coin_msg_inspector_set" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_token_coin_oft_received" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "token_address" TEXT,
  "guid" TEXT,
  "src_eid" NUMERIC,
  "to_address" TEXT,
  "amount_received_ld" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_tokencoin_oftreceived_evt_block_number" ON "raw_token_coin_oft_received" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_tokencoin_oftreceived_evt_tx_hash" ON "raw_token_coin_oft_received" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_token_coin_oft_sent" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "token_address" TEXT,
  "guid" TEXT,
  "dst_eid" NUMERIC,
  "from_address" TEXT,
  "amount_sent_ld" NUMERIC,
  "amount_received_ld" NUMERIC,
  "token_layer_id" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_tokencoin_oftsent_evt_block_number" ON "raw_token_coin_oft_sent" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_tokencoin_oftsent_evt_tx_hash" ON "raw_token_coin_oft_sent" ("evt_tx_hash");
CREATE INDEX IF NOT EXISTS "idx_tokencoin_oftsent_token_layer_id" ON "raw_token_coin_oft_sent" ("token_layer_id");

CREATE TABLE IF NOT EXISTS "raw_token_coin_ownership_transferred" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "token_address" TEXT,
  "previous_owner" TEXT,
  "new_owner" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_tokencoin_ownershiptransferred_evt_block_number" ON "raw_token_coin_ownership_transferred" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_tokencoin_ownershiptransferred_evt_tx_hash" ON "raw_token_coin_ownership_transferred" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_token_coin_peer_set" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "token_address" TEXT,
  "eid" NUMERIC,
  "peer" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_tokencoin_peerset_evt_block_number" ON "raw_token_coin_peer_set" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_tokencoin_peerset_evt_tx_hash" ON "raw_token_coin_peer_set" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_token_coin_pre_crime_set" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "token_address" TEXT,
  "pre_crime_address" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_tokencoin_precrimeset_evt_block_number" ON "raw_token_coin_pre_crime_set" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_tokencoin_precrimeset_evt_tx_hash" ON "raw_token_coin_pre_crime_set" ("evt_tx_hash");

CREATE TABLE IF NOT EXISTS "raw_token_coin_transfer" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "token_address" TEXT,
  "from" TEXT,
  "to" TEXT,
  "amount" NUMERIC,
  "token_layer_id" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_tokencoin_transfer_evt_block_number" ON "raw_token_coin_transfer" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_tokencoin_transfer_evt_tx_hash" ON "raw_token_coin_transfer" ("evt_tx_hash");
CREATE INDEX IF NOT EXISTS "idx_tokencoin_transfer_token_layer_id" ON "raw_token_coin_transfer" ("token_layer_id");

ALTER TABLE IF EXISTS "raw_token_coin_oft_sent"
  ADD COLUMN IF NOT EXISTS "token_layer_id" TEXT;
ALTER TABLE IF EXISTS "raw_token_coin_transfer"
  ADD COLUMN IF NOT EXISTS "token_layer_id" TEXT;
ALTER TABLE IF EXISTS "raw_token_coin_approval"
  ADD COLUMN IF NOT EXISTS "token_layer_id" TEXT;
ALTER TABLE IF EXISTS "raw_token_coin_enforced_option_set"
  ADD COLUMN IF NOT EXISTS "token_layer_id" TEXT;
ALTER TABLE IF EXISTS "raw_token_coin_initialized"
  ADD COLUMN IF NOT EXISTS "token_layer_id" TEXT;
ALTER TABLE IF EXISTS "raw_token_coin_msg_inspector_set"
  ADD COLUMN IF NOT EXISTS "token_layer_id" TEXT;
ALTER TABLE IF EXISTS "raw_token_coin_oft_received"
  ADD COLUMN IF NOT EXISTS "token_layer_id" TEXT;
ALTER TABLE IF EXISTS "raw_token_coin_ownership_transferred"
  ADD COLUMN IF NOT EXISTS "token_layer_id" TEXT;
ALTER TABLE IF EXISTS "raw_token_coin_peer_set"
  ADD COLUMN IF NOT EXISTS "token_layer_id" TEXT;
ALTER TABLE IF EXISTS "raw_token_coin_pre_crime_set"
  ADD COLUMN IF NOT EXISTS "token_layer_id" TEXT;
ALTER TABLE IF EXISTS "raw_launchpad_buy"
  ADD COLUMN IF NOT EXISTS "token_address" TEXT;
ALTER TABLE IF EXISTS "raw_launchpad_sell"
  ADD COLUMN IF NOT EXISTS "token_address" TEXT;
ALTER TABLE IF EXISTS "raw_launchpad_graduation"
  ADD COLUMN IF NOT EXISTS "token_layer_id" TEXT;
ALTER TABLE IF EXISTS "raw_liquidity_mananager_fees_collected"
  ADD COLUMN IF NOT EXISTS "token_layer_id" TEXT;
ALTER TABLE IF EXISTS "raw_liquidity_mananager_fees_distributed"
  ADD COLUMN IF NOT EXISTS "token_layer_id" TEXT;
ALTER TABLE IF EXISTS "raw_liquidity_mananager_initial_position_minted"
  ADD COLUMN IF NOT EXISTS "token_layer_id" TEXT;
ALTER TABLE IF EXISTS "raw_liquidity_mananager_position_created_via_compose"
  ADD COLUMN IF NOT EXISTS "token_layer_id" TEXT;
ALTER TABLE IF EXISTS "raw_uniswap_v3_swap"
  ADD COLUMN IF NOT EXISTS "token_address" TEXT;
ALTER TABLE IF EXISTS "raw_uniswap_v3_swap"
  ADD COLUMN IF NOT EXISTS "token_layer_id" TEXT;
ALTER TABLE IF EXISTS "raw_uniswap_v3_pool_created"
  ADD COLUMN IF NOT EXISTS "token_address" TEXT;
ALTER TABLE IF EXISTS "raw_uniswap_v3_pool_created"
  ADD COLUMN IF NOT EXISTS "token_layer_id" TEXT;
ALTER TABLE IF EXISTS "raw_uniswap_v3_mint"
  ADD COLUMN IF NOT EXISTS "token_address" TEXT;
ALTER TABLE IF EXISTS "raw_uniswap_v3_mint"
  ADD COLUMN IF NOT EXISTS "token_layer_id" TEXT;
ALTER TABLE IF EXISTS "raw_uniswap_v3_burn"
  ADD COLUMN IF NOT EXISTS "token_address" TEXT;
ALTER TABLE IF EXISTS "raw_uniswap_v3_burn"
  ADD COLUMN IF NOT EXISTS "token_layer_id" TEXT;
ALTER TABLE IF EXISTS "agg_wallet_token_balance"
  ADD COLUMN IF NOT EXISTS "token_layer_id" TEXT;
ALTER TABLE IF EXISTS "cur_wallet_token_balance"
  ADD COLUMN IF NOT EXISTS "token_layer_id" TEXT;

CREATE INDEX IF NOT EXISTS "idx_tokencoin_approval_token_layer_id" ON "raw_token_coin_approval" ("token_layer_id");
CREATE INDEX IF NOT EXISTS "idx_tokencoin_enforcedoptset_token_layer_id" ON "raw_token_coin_enforced_option_set" ("token_layer_id");
CREATE INDEX IF NOT EXISTS "idx_tokencoin_initialized_token_layer_id" ON "raw_token_coin_initialized" ("token_layer_id");
CREATE INDEX IF NOT EXISTS "idx_tokencoin_msginspect_token_layer_id" ON "raw_token_coin_msg_inspector_set" ("token_layer_id");
CREATE INDEX IF NOT EXISTS "idx_tokencoin_oftreceived_token_layer_id" ON "raw_token_coin_oft_received" ("token_layer_id");
CREATE INDEX IF NOT EXISTS "idx_tokencoin_ownertransf_token_layer_id" ON "raw_token_coin_ownership_transferred" ("token_layer_id");
CREATE INDEX IF NOT EXISTS "idx_tokencoin_peerset_token_layer_id" ON "raw_token_coin_peer_set" ("token_layer_id");
CREATE INDEX IF NOT EXISTS "idx_tokencoin_precrime_token_layer_id" ON "raw_token_coin_pre_crime_set" ("token_layer_id");

CREATE TABLE IF NOT EXISTS "raw_uniswap_v3_swap" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "token_address" TEXT,
  "token_layer_id" TEXT,
  "pool" TEXT,
  "sender" TEXT,
  "recipient" TEXT,
  "amount0" NUMERIC,
  "amount1" NUMERIC,
  "sqrt_price_x96" NUMERIC,
  "liquidity" NUMERIC,
  "tick" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_uniswapv3_swap_evt_block_number" ON "raw_uniswap_v3_swap" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_uniswapv3_swap_evt_tx_hash" ON "raw_uniswap_v3_swap" ("evt_tx_hash");
CREATE INDEX IF NOT EXISTS "idx_uniswapv3_swap_sender" ON "raw_uniswap_v3_swap" ("sender");
CREATE INDEX IF NOT EXISTS "idx_uniswapv3_swap_recipient" ON "raw_uniswap_v3_swap" ("recipient");
CREATE INDEX IF NOT EXISTS "idx_uniswapv3_swap_pool" ON "raw_uniswap_v3_swap" ("pool");
CREATE INDEX IF NOT EXISTS "idx_uniswapv3_swap_token_address" ON "raw_uniswap_v3_swap" ("token_address");
CREATE INDEX IF NOT EXISTS "idx_uniswapv3_swap_token_layer_id" ON "raw_uniswap_v3_swap" ("token_layer_id");

CREATE TABLE IF NOT EXISTS "raw_uniswap_v3_pool_created" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "token_address" TEXT,
  "token_layer_id" TEXT,
  "pool" TEXT,
  "token0" TEXT,
  "token1" TEXT,
  "fee" NUMERIC,
  "sqrt_price_x96" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_uniswapv3_poolcreated_evt_block_number" ON "raw_uniswap_v3_pool_created" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_uniswapv3_poolcreated_evt_tx_hash" ON "raw_uniswap_v3_pool_created" ("evt_tx_hash");
CREATE INDEX IF NOT EXISTS "idx_uniswapv3_poolcreated_pool" ON "raw_uniswap_v3_pool_created" ("pool");
CREATE INDEX IF NOT EXISTS "idx_uniswapv3_poolcreated_token_address" ON "raw_uniswap_v3_pool_created" ("token_address");
CREATE INDEX IF NOT EXISTS "idx_uniswapv3_poolcreated_token_layer_id" ON "raw_uniswap_v3_pool_created" ("token_layer_id");

CREATE TABLE IF NOT EXISTS "raw_uniswap_v3_mint" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "token_address" TEXT,
  "token_layer_id" TEXT,
  "pool" TEXT,
  "owner" TEXT,
  "sender" TEXT,
  "tick_lower" NUMERIC,
  "tick_upper" NUMERIC,
  "amount" NUMERIC,
  "amount0" NUMERIC,
  "amount1" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_uniswapv3_mint_evt_block_number" ON "raw_uniswap_v3_mint" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_uniswapv3_mint_evt_tx_hash" ON "raw_uniswap_v3_mint" ("evt_tx_hash");
CREATE INDEX IF NOT EXISTS "idx_uniswapv3_mint_pool" ON "raw_uniswap_v3_mint" ("pool");
CREATE INDEX IF NOT EXISTS "idx_uniswapv3_mint_owner" ON "raw_uniswap_v3_mint" ("owner");
CREATE INDEX IF NOT EXISTS "idx_uniswapv3_mint_sender" ON "raw_uniswap_v3_mint" ("sender");
CREATE INDEX IF NOT EXISTS "idx_uniswapv3_mint_token_address" ON "raw_uniswap_v3_mint" ("token_address");
CREATE INDEX IF NOT EXISTS "idx_uniswapv3_mint_token_layer_id" ON "raw_uniswap_v3_mint" ("token_layer_id");

CREATE TABLE IF NOT EXISTS "raw_uniswap_v3_burn" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "token_address" TEXT,
  "token_layer_id" TEXT,
  "pool" TEXT,
  "owner" TEXT,
  "tick_lower" NUMERIC,
  "tick_upper" NUMERIC,
  "amount" NUMERIC,
  "amount0" NUMERIC,
  "amount1" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_uniswapv3_burn_evt_block_number" ON "raw_uniswap_v3_burn" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_uniswapv3_burn_evt_tx_hash" ON "raw_uniswap_v3_burn" ("evt_tx_hash");
CREATE INDEX IF NOT EXISTS "idx_uniswapv3_burn_pool" ON "raw_uniswap_v3_burn" ("pool");
CREATE INDEX IF NOT EXISTS "idx_uniswapv3_burn_owner" ON "raw_uniswap_v3_burn" ("owner");
CREATE INDEX IF NOT EXISTS "idx_uniswapv3_burn_token_address" ON "raw_uniswap_v3_burn" ("token_address");
CREATE INDEX IF NOT EXISTS "idx_uniswapv3_burn_token_layer_id" ON "raw_uniswap_v3_burn" ("token_layer_id");

CREATE TABLE IF NOT EXISTS "agg_wallet_token_balance" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "token_address" TEXT,
  "token_layer_id" TEXT,
  "wallet" TEXT,
  "balance" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_wallettokenbalance_evt_block_number" ON "agg_wallet_token_balance" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_wallettokenbalance_token_address" ON "agg_wallet_token_balance" ("token_address");
CREATE INDEX IF NOT EXISTS "idx_wallettokenbalance_token_layer_id" ON "agg_wallet_token_balance" ("token_layer_id");
CREATE INDEX IF NOT EXISTS "idx_wallettokenbalance_wallet" ON "agg_wallet_token_balance" ("wallet");

CREATE TABLE IF NOT EXISTS "cur_wallet_token_balance" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "token_address" TEXT,
  "token_layer_id" TEXT,
  "wallet" TEXT,
  "balance" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_wallettokenbalancecurrent_wallet" ON "cur_wallet_token_balance" ("wallet");
CREATE INDEX IF NOT EXISTS "idx_wallettokenbalancecurrent_token_address" ON "cur_wallet_token_balance" ("token_address");
CREATE INDEX IF NOT EXISTS "idx_wallettokenbalancecurrent_token_layer_id" ON "cur_wallet_token_balance" ("token_layer_id");

CREATE TABLE IF NOT EXISTS "cur_user_fee_balance" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "account" TEXT,
  "currency" TEXT,
  "balance" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_user_fee_balance_current_account" ON "cur_user_fee_balance" ("account");
CREATE INDEX IF NOT EXISTS "idx_user_fee_balance_current_currency" ON "cur_user_fee_balance" ("currency");

CREATE TABLE IF NOT EXISTS "cur_protocol_fee_balance" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "currency" TEXT,
  "balance" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_protocol_fee_balance_current_currency" ON "cur_protocol_fee_balance" ("currency");

CREATE TABLE IF NOT EXISTS "agg_token_trade" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "venue" TEXT,
  "trade_type" TEXT,
  "wallet" TEXT,
  "token_address" TEXT,
  "pool" TEXT,
  "token_amount" NUMERIC,
  "token_amount_raw" NUMERIC,
  "usd_amount" NUMERIC,
  "usd_amount_raw" NUMERIC,
  "price_usd" NUMERIC,
  "market_cap_usd" NUMERIC,
  "token_layer_id" TEXT,
  "token_decimals" NUMERIC,
  "quote_decimals" NUMERIC,
  "token_decimals_source" TEXT,
  "quote_decimals_source" TEXT
);
CREATE INDEX IF NOT EXISTS "idx_agg_token_trade_evt_block_number" ON "agg_token_trade" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_agg_token_trade_evt_tx_hash" ON "agg_token_trade" ("evt_tx_hash");
CREATE INDEX IF NOT EXISTS "idx_agg_token_trade_wallet" ON "agg_token_trade" ("wallet");
CREATE INDEX IF NOT EXISTS "idx_agg_token_trade_token_address" ON "agg_token_trade" ("token_address");
CREATE INDEX IF NOT EXISTS "idx_agg_token_trade_venue" ON "agg_token_trade" ("venue");
CREATE INDEX IF NOT EXISTS "idx_agg_token_trade_token_layer_id" ON "agg_token_trade" ("token_layer_id");
CREATE INDEX IF NOT EXISTS "idx_agg_token_trade_token_decimals" ON "agg_token_trade" ("token_decimals");

CREATE TABLE IF NOT EXISTS "agg_token_price_usd" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "token_layer_id" TEXT,
  "token_address" TEXT,
  "price_usd" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_agg_token_price_usd_evt_block_number" ON "agg_token_price_usd" ("evt_block_number");
CREATE INDEX IF NOT EXISTS "idx_agg_token_price_usd_token_layer_id" ON "agg_token_price_usd" ("token_layer_id");
CREATE INDEX IF NOT EXISTS "idx_agg_token_price_usd_token_address" ON "agg_token_price_usd" ("token_address");

CREATE TABLE IF NOT EXISTS "cur_token_price_usd" (
  "_pk" TEXT PRIMARY KEY,
  "_block_number_" NUMERIC,
  "_block_timestamp_" TIMESTAMP,
  "evt_tx_hash" TEXT,
  "evt_index" NUMERIC,
  "evt_block_time" TIMESTAMP,
  "evt_block_number" NUMERIC,
  "token_layer_id" TEXT,
  "token_address" TEXT,
  "price_usd" NUMERIC
);
CREATE INDEX IF NOT EXISTS "idx_cur_token_price_usd_token_layer_id" ON "cur_token_price_usd" ("token_layer_id");
CREATE INDEX IF NOT EXISTS "idx_cur_token_price_usd_token_address" ON "cur_token_price_usd" ("token_address");

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

-- Added global token_id/token_address indexes
CREATE INDEX IF NOT EXISTS "idx_tokid_f91d53874a" ON "raw_registry_external_token_created" ("token_id");
CREATE INDEX IF NOT EXISTS "idx_tokaddr_fd33f6767c" ON "raw_registry_external_token_created" ("token_address");
CREATE INDEX IF NOT EXISTS "idx_tokid_39a469c06b" ON "raw_registry_oapp_configured" ("token_id");
CREATE INDEX IF NOT EXISTS "idx_tokaddr_4f3584e21d" ON "raw_registry_oapp_configured" ("token_address");
CREATE INDEX IF NOT EXISTS "idx_tokid_56cad74be2" ON "raw_registry_peer_set" ("token_id");
CREATE INDEX IF NOT EXISTS "idx_tokaddr_124575ac57" ON "raw_registry_peer_set" ("token_address");
CREATE INDEX IF NOT EXISTS "idx_tokid_f470feb7e6" ON "raw_registry_token_created" ("token_id");
CREATE INDEX IF NOT EXISTS "idx_tokaddr_ff3de24434" ON "raw_registry_token_created" ("token_address");
CREATE INDEX IF NOT EXISTS "idx_tokid_aa69e3f600" ON "raw_registry_token_registered" ("token_id");
CREATE INDEX IF NOT EXISTS "idx_tokaddr_f762cf88fa" ON "raw_registry_token_registered" ("token_address");
CREATE INDEX IF NOT EXISTS "idx_tokid_ddf1808118" ON "raw_oapp_operation_created" ("token_id");
CREATE INDEX IF NOT EXISTS "idx_tokid_36684e4664" ON "raw_oapp_token_liquidity_initialized_externally" ("token_id");
CREATE INDEX IF NOT EXISTS "idx_tokid_b4b9edca3b" ON "raw_oapp_token_registered_externally" ("token_id");
CREATE INDEX IF NOT EXISTS "idx_tokid_90608e3c5c" ON "raw_oapp_token_registration_ack_processed" ("token_id");
CREATE INDEX IF NOT EXISTS "idx_tokid_b145e84b59" ON "raw_oapp_token_registration_ack_sent" ("token_id");
CREATE INDEX IF NOT EXISTS "idx_tokid_f2dcaeb4c8" ON "raw_oapp_token_registration_initiated" ("token_id");
CREATE INDEX IF NOT EXISTS "idx_tokid_3dec876376" ON "raw_oapp_token_registration_received" ("token_id");
CREATE INDEX IF NOT EXISTS "idx_tokid_2ebeaf928d" ON "raw_manager_external_whitelist_changed" ("token_id");
CREATE INDEX IF NOT EXISTS "idx_tokid_dff88e8688" ON "raw_launchpad_buy" ("token_id");
CREATE INDEX IF NOT EXISTS "idx_tokid_f2e000dc7c" ON "raw_launchpad_sell" ("token_id");
CREATE INDEX IF NOT EXISTS "idx_tokid_1a4816a50f" ON "raw_liquidity_mananager_fees_collected" ("token_id");
CREATE INDEX IF NOT EXISTS "idx_tokid_6834174995" ON "raw_liquidity_mananager_fees_distributed" ("token_id");
CREATE INDEX IF NOT EXISTS "idx_tokid_a8dbfce49e" ON "raw_liquidity_mananager_initial_position_minted" ("token_id");
CREATE INDEX IF NOT EXISTS "idx_tokid_2ca47c11d8" ON "raw_liquidity_mananager_liquidity_increased" ("token_id");
CREATE INDEX IF NOT EXISTS "idx_tokid_be09197ff1" ON "raw_liquidity_mananager_liquidity_migrated" ("token_id");
CREATE INDEX IF NOT EXISTS "idx_tokid_deaa1056d7" ON "raw_liquidity_mananager_new_deposit" ("token_id");
CREATE INDEX IF NOT EXISTS "idx_tokid_36fa989c02" ON "raw_liquidity_mananager_position_created_via_compose" ("token_id");
CREATE INDEX IF NOT EXISTS "idx_tokaddr_8142709800" ON "raw_token_coin_approval" ("token_address");
CREATE INDEX IF NOT EXISTS "idx_tokaddr_888e572f0b" ON "raw_token_coin_enforced_option_set" ("token_address");
CREATE INDEX IF NOT EXISTS "idx_tokaddr_a6d587b1f2" ON "raw_token_coin_initialized" ("token_address");
CREATE INDEX IF NOT EXISTS "idx_tokaddr_19fe33e16c" ON "raw_token_coin_msg_inspector_set" ("token_address");
CREATE INDEX IF NOT EXISTS "idx_tokaddr_b8ba998580" ON "raw_token_coin_oft_received" ("token_address");
CREATE INDEX IF NOT EXISTS "idx_tokaddr_9729b6cd8e" ON "raw_token_coin_oft_sent" ("token_address");
CREATE INDEX IF NOT EXISTS "idx_tokaddr_44ebb0227b" ON "raw_token_coin_ownership_transferred" ("token_address");
CREATE INDEX IF NOT EXISTS "idx_tokaddr_2c9e7e9690" ON "raw_token_coin_peer_set" ("token_address");
CREATE INDEX IF NOT EXISTS "idx_tokaddr_2aa145974e" ON "raw_token_coin_pre_crime_set" ("token_address");
CREATE INDEX IF NOT EXISTS "idx_tokaddr_7b60cda6d6" ON "raw_token_coin_transfer" ("token_address");
CREATE INDEX IF NOT EXISTS "idx_tokaddr_0a209ff132" ON "agg_wallet_token_balance" ("token_address");
CREATE INDEX IF NOT EXISTS "idx_tokaddr_e52d3165fc" ON "cur_wallet_token_balance" ("token_address");
