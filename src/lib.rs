mod abi;
mod db_changes;
#[allow(unused)]
mod pb;
use hex_literal::hex;
use pb::contract::v1 as contract;
use substreams::prelude::*;
use substreams::store;
use substreams::Hex;
use substreams_ethereum::pb::eth::v2 as eth;
use substreams_ethereum::Event;
use std::collections::{HashMap, HashSet};

#[allow(unused_imports)] // Might not be needed depending on actual ABI, hence the allow
use {num_traits::cast::ToPrimitive, std::str::FromStr, substreams::scalar::BigDecimal};

substreams_ethereum::init!();

const REGISTRY_TRACKED_CONTRACT: [u8; 20] = hex!("000000194d2afe38a20707cb96ed1583038bf02f");
const OAPP_TRACKED_CONTRACT: [u8; 20] = hex!("f7d116f1a1ac7c34372e52cf5763c58dcf43185a");
const MANAGER_TRACKED_CONTRACT: [u8; 20] = hex!("0000007e56e19a085a31f27aa61c8671c12d2bb7");
const LAUNCHPAD_TRACKED_CONTRACT: [u8; 20] = hex!("00060eb62a2c042d00e29fddc092f9ed1f25def1");
const IP_TRACKED_CONTRACT: [u8; 20] = hex!("00089428a12cd4a6064be0125ced1f6a1066deed");
const LIQUIDITY_MANANAGER_TRACKED_CONTRACT: [u8; 20] = hex!("e60159a9831ed8c8a8832da1b9a10c03d737dcb2");
const FEES_TRACKED_CONTRACT: [u8; 20] = hex!("feeeba1dcc3abbd045e8b824d9699e735de49fee");
const ROLES_TRACKED_CONTRACT: [u8; 20] = hex!("ff582c406d037ac7aaddbb203d74bde112791d51");
const ZERO_ADDRESS: [u8; 20] = [0u8; 20];
const UNISWAP_V3_MINT_TOPIC: [u8; 32] = hex!("7a53080ba414158be7ec69b987b5fb7d07dee101fe85488f0853ae16239d0bde");
const UNISWAP_V3_BURN_TOPIC: [u8; 32] = hex!("0c396cd989a39f4459b5fa1aed6a9a8dcdbc45908acfd67e028cd568da98982c");
const LAUNCHPAD_GRADUATION_TOPIC: [u8; 32] = hex!("392671c0c142729d75db4636bb6c9c0686ed7b801f6a29231b35286367b434e4");

fn resolve_uniswap_factory_address(params: &str) -> String {
    for pair in params.split('&') {
        let mut it = pair.splitn(2, '=');
        let key = it.next().unwrap_or_default().trim();
        let val = it.next().unwrap_or_default().trim();
        if key != "uniswap_v3_factory" || val.is_empty() {
            continue;
        }

        let normalized = val.strip_prefix("0x").unwrap_or(val).to_lowercase();
        if normalized.len() == 40 {
            return normalized;
        }
    }

    panic!("missing required module param: uniswap_v3_factory (expected 0x-prefixed 20-byte address)")
}

fn resolve_oapp_address(params: &str) -> [u8; 20] {
    for pair in params.split('&') {
        let mut it = pair.splitn(2, '=');
        let key = it.next().unwrap_or_default().trim();
        let val = it.next().unwrap_or_default().trim();
        if key != "oapp_address" || val.is_empty() {
            continue;
        }

        let normalized = val.strip_prefix("0x").unwrap_or(val).to_lowercase();
        if normalized.len() != 40 {
            panic!("invalid module param: oapp_address must be 20-byte hex")
        }

        let mut out = [0u8; 20];
        if let Ok(bytes) = hex::decode(normalized) {
            if bytes.len() == 20 {
                out.copy_from_slice(&bytes);
                return out;
            }
        }

        panic!("invalid module param: oapp_address must be valid hex")
    }

    OAPP_TRACKED_CONTRACT
}

fn param_value<'a>(params: &'a str, key: &str) -> Option<&'a str> {
    for pair in params.split('&') {
        let mut it = pair.splitn(2, '=');
        let k = it.next().unwrap_or_default().trim();
        let v = it.next().unwrap_or_default().trim();
        if k == key && !v.is_empty() {
            return Some(v);
        }
    }
    None
}

fn resolve_usd_token_address(params: &str) -> String {
    param_value(params, "usd_token_address")
        .map(|v| v.strip_prefix("0x").unwrap_or(v).to_lowercase())
        .unwrap_or_else(|| "ed0e8956d5e7b04560460be6b3811b0b31cee8e1".to_string())
}

fn resolve_u64_param(params: &str, key: &str, default: u64) -> u64 {
    param_value(params, key)
        .and_then(|v| v.parse::<u64>().ok())
        .unwrap_or(default)
}

fn map_registry_events(blk: &eth::Block, events: &mut contract::Events) {
    events.registry_adapter_deployeds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::registry_contract::events::AdapterDeployed::match_and_decode(log) {
                        return Some(contract::RegistryAdapterDeployed {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            adapter: event.adapter,
                            adapter_type: event.adapter_type.to_u64(),
                            external_token: event.external_token,
                            wrapped_token: event.wrapped_token,
                        });
                    }

                    None
                })
        })
        .collect());
    events.registry_adapter_template_resets.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::registry_contract::events::AdapterTemplateReset::match_and_decode(log) {
                        return Some(contract::RegistryAdapterTemplateReset {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            template_id: Vec::from(event.template_id),
                        });
                    }

                    None
                })
        })
        .collect());
    events.registry_adapter_template_sets.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::registry_contract::events::AdapterTemplateSet::match_and_decode(log) {
                        return Some(contract::RegistryAdapterTemplateSet {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            adapter_type: event.adapter_type.to_u64(),
                            implementation_address: event.implementation_address,
                            template_id: Vec::from(event.template_id),
                        });
                    }

                    None
                })
        })
        .collect());
    events.registry_builder_fees_approveds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::registry_contract::events::BuilderFeesApproved::match_and_decode(log) {
                        return Some(contract::RegistryBuilderFeesApproved {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            builder: event.builder,
                            user: event.user,
                        });
                    }

                    None
                })
        })
        .collect());
    events.registry_coin_createds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::registry_contract::events::CoinCreated::match_and_decode(log) {
                        return Some(contract::RegistryCoinCreated {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            coin_address: event.coin_address,
                            decimals: event.decimals.to_u64(),
                            hub_id: event.hub_id.to_string(),
                            name: event.name,
                            symbol: event.symbol,
                            token_uri: event.token_uri,
                            total_supply: event.total_supply.to_string(),
                        });
                    }

                    None
                })
        })
        .collect());
    events.registry_contract_address_overwrittens.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::registry_contract::events::ContractAddressOverwritten::match_and_decode(log) {
                        return Some(contract::RegistryContractAddressOverwritten {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            identifier: Vec::from(event.identifier),
                            new_address: event.new_address,
                            old_address: event.old_address,
                        });
                    }

                    None
                })
        })
        .collect());
    events.registry_contract_deployeds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::registry_contract::events::ContractDeployed::match_and_decode(log) {
                        return Some(contract::RegistryContractDeployed {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            contract_address: event.contract_address,
                            name: Vec::from(event.name),
                            salt: Vec::from(event.salt),
                        });
                    }

                    None
                })
        })
        .collect());
    events.registry_external_token_createds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::registry_contract::events::ExternalTokenCreated::match_and_decode(log) {
                        return Some(contract::RegistryExternalTokenCreated {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            adapter: event.adapter,
                            adapter_type: event.adapter_type.to_u64(),
                            external_token: event.external_token,
                            name: event.name,
                            symbol: event.symbol,
                            token_address: event.token_address,
                            token_id: format!("0x{}", Hex(&event.token_id).to_string()),
                        });
                    }

                    None
                })
        })
        .collect());
    events.registry_hub_createds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::registry_contract::events::HubCreated::match_and_decode(log) {
                        return Some(contract::RegistryHubCreated {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            creator: event.creator,
                            id: event.id.to_string(),
                            is_private: event.is_private,
                            receiver: event.receiver,
                        });
                    }

                    None
                })
        })
        .collect());
    events.registry_hubs_address_changeds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::registry_contract::events::HubsAddressChanged::match_and_decode(log) {
                        return Some(contract::RegistryHubsAddressChanged {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            new_address: event.new_address,
                        });
                    }

                    None
                })
        })
        .collect());
    events.registry_initializeds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::registry_contract::events::Initialized::match_and_decode(log) {
                        return Some(contract::RegistryInitialized {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            version: event.version.to_u64(),
                        });
                    }

                    None
                })
        })
        .collect());
    events.registry_item_createds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::registry_contract::events::ItemCreated::match_and_decode(log) {
                        return Some(contract::RegistryItemCreated {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            decimals: event.decimals.to_u64(),
                            hub_id: event.hub_id.to_string(),
                            id: event.id.to_string(),
                            name: event.name,
                            pool_type: event.pool_type.to_string(),
                            symbol: event.symbol.hash,
                            token_uri: event.token_uri,
                        });
                    }

                    None
                })
        })
        .collect());
    events.registry_items_address_changeds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::registry_contract::events::ItemsAddressChanged::match_and_decode(log) {
                        return Some(contract::RegistryItemsAddressChanged {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            new_address: event.new_address,
                        });
                    }

                    None
                })
        })
        .collect());
    events.registry_launchpad_address_changeds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::registry_contract::events::LaunchpadAddressChanged::match_and_decode(log) {
                        return Some(contract::RegistryLaunchpadAddressChanged {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            new_address: event.new_address,
                        });
                    }

                    None
                })
        })
        .collect());
    events.registry_liquidity_manager_address_changeds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::registry_contract::events::LiquidityManagerAddressChanged::match_and_decode(log) {
                        return Some(contract::RegistryLiquidityManagerAddressChanged {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            new_address: event.new_address,
                        });
                    }

                    None
                })
        })
        .collect());
    events.registry_liquidity_migrator_address_changeds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::registry_contract::events::LiquidityMigratorAddressChanged::match_and_decode(log) {
                        return Some(contract::RegistryLiquidityMigratorAddressChanged {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            new_address: event.new_address,
                        });
                    }

                    None
                })
        })
        .collect());
    events.registry_manager_updateds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::registry_contract::events::ManagerUpdated::match_and_decode(log) {
                        return Some(contract::RegistryManagerUpdated {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            authorized: event.authorized,
                            manager: event.manager,
                        });
                    }

                    None
                })
        })
        .collect());
    events.registry_o_app_configureds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::registry_contract::events::OAppConfigured::match_and_decode(log) {
                        return Some(contract::RegistryOAppConfigured {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            endpoint_id: event.endpoint_id.to_u64(),
                            receive_library: event.receive_library,
                            send_library: event.send_library,
                            token_address: event.token_address,
                            token_id: Vec::from(event.token_id),
                        });
                    }

                    None
                })
        })
        .collect());
    events.registry_ownership_transferreds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::registry_contract::events::OwnershipTransferred::match_and_decode(log) {
                        return Some(contract::RegistryOwnershipTransferred {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            new_owner: event.new_owner,
                            user: event.user,
                        });
                    }

                    None
                })
        })
        .collect());
    events.registry_peer_sets.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::registry_contract::events::PeerSet::match_and_decode(log) {
                        return Some(contract::RegistryPeerSet {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            endpoint_id: event.endpoint_id.to_u64(),
                            peer_address: Vec::from(event.peer_address),
                            token_address: event.token_address,
                            token_id: Vec::from(event.token_id),
                        });
                    }

                    None
                })
        })
        .collect());
    events.registry_points_createds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::registry_contract::events::PointsCreated::match_and_decode(log) {
                        return Some(contract::RegistryPointsCreated {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            hub_id: event.hub_id.to_string(),
                            id: event.id.to_string(),
                            name: event.name,
                            soulbound: event.soulbound,
                            symbol: event.symbol,
                            uri: event.uri,
                        });
                    }

                    None
                })
        })
        .collect());
    events.registry_protocol_bonus_config_sets.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::registry_contract::events::ProtocolBonusConfigSet::match_and_decode(log) {
                        return Some(contract::RegistryProtocolBonusConfigSet {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            duration_blocks: event.duration_blocks.to_u64(),
                            start_percentage_bps: event.start_percentage_bps.to_u64(),
                        });
                    }

                    None
                })
        })
        .collect());
    events.registry_protocol_fee_sets.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::registry_contract::events::ProtocolFeeSet::match_and_decode(log) {
                        return Some(contract::RegistryProtocolFeeSet {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            activity: event.activity.to_u64(),
                            fee_bps: event.fee_bps.to_u64(),
                        });
                    }

                    None
                })
        })
        .collect());
    events.registry_protocol_limit_sets.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::registry_contract::events::ProtocolLimitSet::match_and_decode(log) {
                        return Some(contract::RegistryProtocolLimitSet {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            activity: event.activity.to_u64(),
                            max_fee_bps: event.max_fee_bps.to_u64(),
                        });
                    }

                    None
                })
        })
        .collect());
    events.registry_referral_sets.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::registry_contract::events::ReferralSet::match_and_decode(log) {
                        return Some(contract::RegistryReferralSet {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            discount_active: event.discount_active,
                            referee: event.referee,
                            referrer: event.referrer,
                            reward_active: event.reward_active,
                        });
                    }

                    None
                })
        })
        .collect());
    events.registry_referral_status_updateds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::registry_contract::events::ReferralStatusUpdated::match_and_decode(log) {
                        return Some(contract::RegistryReferralStatusUpdated {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            discount_active: event.discount_active,
                            referee: event.referee,
                            reward_active: event.reward_active,
                        });
                    }

                    None
                })
        })
        .collect());
    events.registry_referrals_controller_updateds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::registry_contract::events::ReferralsControllerUpdated::match_and_decode(log) {
                        return Some(contract::RegistryReferralsControllerUpdated {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            new_controller: event.new_controller,
                            old_controller: event.old_controller,
                        });
                    }

                    None
                })
        })
        .collect());
    events.registry_registry_initializeds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::registry_contract::events::RegistryInitialized::match_and_decode(log) {
                        return Some(contract::RegistryRegistryInitialized {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            endpoint: event.endpoint,
                            owner: event.owner,
                            payment_token: event.payment_token,
                            protocol_fee_to: event.protocol_fee_to,
                            swap_router: event.swap_router,
                            trusted_forwarder: event.trusted_forwarder,
                        });
                    }

                    None
                })
        })
        .collect());
    events.registry_token_createds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::registry_contract::events::TokenCreated::match_and_decode(log) {
                        return Some(contract::RegistryTokenCreated {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            decimals: event.decimals.to_u64(),
                            ip_id: event.hub_id.to_string(),
                            name: event.name,
                            symbol: event.symbol,
                            token_address: format!("0x{}", Hex(&event.token_address).to_string()),
                            token_id: format!("0x{}", Hex(&log.topics[2]).to_string()),
                            token_uri: event.token_uri,
                        });
                    }

                    None
                })
        })
        .collect());
    events.registry_token_registereds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::registry_contract::events::TokenRegistered::match_and_decode(log) {
                        return Some(contract::RegistryTokenRegistered {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            name: event.name,
                            symbol: event.symbol,
                            template_id: Vec::from(event.template_id),
                            token_address: event.token_address,
                            token_id: format!("0x{}", Hex(&event.token_id).to_string()),
                        });
                    }

                    None
                })
        })
        .collect());
    events.registry_token_template_resets.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::registry_contract::events::TokenTemplateReset::match_and_decode(log) {
                        return Some(contract::RegistryTokenTemplateReset {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            template_id: Vec::from(event.template_id),
                        });
                    }

                    None
                })
        })
        .collect());
    events.registry_token_template_sets.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::registry_contract::events::TokenTemplateSet::match_and_decode(log) {
                        return Some(contract::RegistryTokenTemplateSet {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            implementation_address: event.implementation_address,
                            template_id: Vec::from(event.template_id),
                            token_type: event.token_type.to_u64(),
                            total_supply: event.total_supply.to_string(),
                        });
                    }

                    None
                })
        })
        .collect());
    events.registry_whitelist_toggleds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::registry_contract::events::WhitelistToggled::match_and_decode(log) {
                        return Some(contract::RegistryWhitelistToggled {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            contract_address: event.contract_address,
                            whitelisted: event.whitelisted,
                        });
                    }

                    None
                })
        })
        .collect());
}

fn map_uniswap_v3_pool_created_events(
    blk: &eth::Block,
    tracked_tokens_store: &store::StoreGetInt64,
    token_id_to_address_store: &store::StoreGetString,
    uniswap_v3_factory: &String,
    events: &mut contract::Events,
) {
    events.uniswap_v3_pool_createds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| Hex(&log.address).to_string() == *uniswap_v3_factory)
                .filter_map(|log| {
                    if let Some(event) = abi::uniswap_v3_factory_contract::events::PoolCreated::match_and_decode(log) {
                        if !is_declared_dds_address(&event.token0, log.ordinal, tracked_tokens_store)
                            && !is_declared_dds_address(&event.token1, log.ordinal, tracked_tokens_store)
                        {
                            return None;
                        }
                        let token0_address = format!("0x{}", Hex(&event.token0).to_string());
                        let token1_address = format!("0x{}", Hex(&event.token1).to_string());
                        let token0_layer_id = token_layer_id_from_token_address(token_id_to_address_store, &token0_address);
                        let token1_layer_id = token_layer_id_from_token_address(token_id_to_address_store, &token1_address);
                        let (token_address, token_layer_id) = if !token0_layer_id.is_empty() {
                            (token0_address.clone(), token0_layer_id)
                        } else if !token1_layer_id.is_empty() {
                            (token1_address.clone(), token1_layer_id)
                        } else {
                            (String::new(), String::new())
                        };
                        return Some(contract::UniswapV3PoolCreated {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            pool: format!("0x{}", Hex(&event.pool).to_string()),
                            token0: token0_address,
                            token1: token1_address,
                            fee: event.fee.to_u64(),
                            // PoolCreated event doesn't include sqrt_price_x96; use numeric zero for schema compatibility.
                            sqrt_price_x96: "0".to_string(),
                            token_address,
                            token_layer_id,
                        });
                    }

                    None
                })
        })
        .collect());
}
fn map_oapp_events(blk: &eth::Block, oapp_tracked_contract: &[u8; 20], events: &mut contract::Events) {
    events.oapp_eth_withdrawns.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == *oapp_tracked_contract)
                .filter_map(|log| {
                    if let Some(event) = abi::oapp_contract::events::EthWithdrawn::match_and_decode(log) {
                        return Some(contract::OappEthWithdrawn {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            amount: event.amount.to_string(),
                            owner: event.owner,
                        });
                    }

                    None
                })
        })
        .collect());
    events.oapp_enforced_option_sets.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == *oapp_tracked_contract)
                .filter_map(|log| {
                    if let Some(event) = abi::oapp_contract::events::EnforcedOptionSet::match_and_decode(log) {
                        return Some(contract::OappEnforcedOptionSet {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                        });
                    }

                    None
                })
        })
        .collect());
    events.oapp_message_receiveds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == *oapp_tracked_contract)
                .filter_map(|log| {
                    if let Some(event) = abi::oapp_contract::events::MessageReceived::match_and_decode(log) {
                        return Some(contract::OappMessageReceived {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            guid: Vec::from(event.guid),
                            msg_type: event.msg_type.to_u64(),
                            src_eid: event.src_eid.to_u64(),
                        });
                    }

                    None
                })
        })
        .collect());
    events.oapp_operation_createds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == *oapp_tracked_contract)
                .filter_map(|log| {
                    if let Some(event) = abi::oapp_contract::events::OperationCreated::match_and_decode(log) {
                        return Some(contract::OappOperationCreated {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            amount: event.amount.to_string(),
                            dst_eid: event.dst_eid.to_u64(),
                            operation_id: event.operation_id.to_u64(),
                            operation_type: event.operation_type.to_u64(),
                            token_id: Vec::from(event.token_id),
                        });
                    }

                    None
                })
        })
        .collect());
    events.oapp_ownership_transferreds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == *oapp_tracked_contract)
                .filter_map(|log| {
                    if let Some(event) = abi::oapp_contract::events::OwnershipTransferred::match_and_decode(log) {
                        return Some(contract::OappOwnershipTransferred {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            new_owner: event.new_owner,
                            user: event.user,
                        });
                    }

                    None
                })
        })
        .collect());
    events.oapp_peer_sets.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == *oapp_tracked_contract)
                .filter_map(|log| {
                    if let Some(event) = abi::oapp_contract::events::PeerSet::match_and_decode(log) {
                        return Some(contract::OappPeerSet {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            eid: event.eid.to_u64(),
                            peer: Vec::from(event.peer),
                        });
                    }

                    None
                })
        })
        .collect());
    events.oapp_solana_liquidity_manager_sets.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == *oapp_tracked_contract)
                .filter_map(|log| {
                    if let Some(event) = abi::oapp_contract::events::SolanaLiquidityManagerSet::match_and_decode(log) {
                        return Some(contract::OappSolanaLiquidityManagerSet {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            liquidity_manager: Vec::from(event.liquidity_manager),
                        });
                    }

                    None
                })
        })
        .collect());
    events.oapp_token_liquidity_initialized_externallies.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == *oapp_tracked_contract)
                .filter_map(|log| {
                    if let Some(event) = abi::oapp_contract::events::TokenLiquidityInitializedExternally::match_and_decode(log) {
                        return Some(contract::OappTokenLiquidityInitializedExternally {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            amount: event.amount.to_string(),
                            dst_eid: event.dst_eid.to_u64(),
                            price_in_wei: event.price_in_wei.to_string(),
                            src_eid: event.src_eid.to_u64(),
                            token_id: Vec::from(event.token_id),
                        });
                    }

                    None
                })
        })
        .collect());
    events.oapp_token_registered_externallies.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == *oapp_tracked_contract)
                .filter_map(|log| {
                    if let Some(event) = abi::oapp_contract::events::TokenRegisteredExternally::match_and_decode(log) {
                        return Some(contract::OappTokenRegisteredExternally {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            dst_eid: event.dst_eid.to_u64(),
                            operation_id: event.operation_id.to_u64(),
                            src_eid: event.src_eid.to_u64(),
                            token_id: Vec::from(event.token_id),
                        });
                    }

                    None
                })
        })
        .collect());
    events.oapp_token_registration_acks.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == *oapp_tracked_contract)
                .filter_map(|log| {
                    if let Some(event) = abi::oapp_contract::events::TokenRegistrationAck::match_and_decode(log) {
                        return Some(contract::OappTokenRegistrationAck {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            guid: Vec::from(event.guid),
                            success: event.success,
                        });
                    }

                    None
                })
        })
        .collect());
    events.oapp_token_registration_ack_processeds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == *oapp_tracked_contract)
                .filter_map(|log| {
                    if let Some(event) = abi::oapp_contract::events::TokenRegistrationAckProcessed::match_and_decode(log) {
                        return Some(contract::OappTokenRegistrationAckProcessed {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            dst_eid: event.dst_eid.to_u64(),
                            operation_id: event.operation_id.to_u64(),
                            remote_token_address: Vec::from(event.remote_token_address),
                            src_eid: event.src_eid.to_u64(),
                            success: event.success,
                            token_id: Vec::from(event.token_id),
                        });
                    }

                    None
                })
        })
        .collect());
    events.oapp_token_registration_ack_sents.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == *oapp_tracked_contract)
                .filter_map(|log| {
                    if let Some(event) = abi::oapp_contract::events::TokenRegistrationAckSent::match_and_decode(log) {
                        return Some(contract::OappTokenRegistrationAckSent {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            dst_eid: event.dst_eid.to_u64(),
                            operation_id: event.operation_id.to_u64(),
                            success: event.success,
                            token_id: Vec::from(event.token_id),
                        });
                    }

                    None
                })
        })
        .collect());
    events.oapp_token_registration_initiateds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == *oapp_tracked_contract)
                .filter_map(|log| {
                    if let Some(event) = abi::oapp_contract::events::TokenRegistrationInitiated::match_and_decode(log) {
                        return Some(contract::OappTokenRegistrationInitiated {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            dst_eid: event.dst_eid.to_u64(),
                            operation_id: event.operation_id.to_u64(),
                            token_id: Vec::from(event.token_id),
                        });
                    }

                    None
                })
        })
        .collect());
    events.oapp_token_registration_receiveds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == *oapp_tracked_contract)
                .filter_map(|log| {
                    if let Some(event) = abi::oapp_contract::events::TokenRegistrationReceived::match_and_decode(log) {
                        return Some(contract::OappTokenRegistrationReceived {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            operation_id: event.operation_id.to_u64(),
                            source_token_address: Vec::from(event.source_token_address),
                            src_eid: event.src_eid.to_u64(),
                            token_id: Vec::from(event.token_id),
                        });
                    }

                    None
                })
        })
        .collect());
}
fn map_manager_events(blk: &eth::Block, events: &mut contract::Events) {
    events.manager_builder_activity_fee_sets.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == MANAGER_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::manager_contract::events::BuilderActivityFeeSet::match_and_decode(log) {
                        return Some(contract::ManagerBuilderActivityFeeSet {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            activity_id: Vec::from(event.activity_id),
                            builder: event.builder,
                            fee_percent: event.fee_percent.to_string(),
                            flat_fee: event.flat_fee.to_string(),
                        });
                    }

                    None
                })
        })
        .collect());
    events.manager_external_whitelist_changeds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == MANAGER_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::manager_contract::events::ExternalWhitelistChanged::match_and_decode(log) {
                        return Some(contract::ManagerExternalWhitelistChanged {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            signer: event.signer,
                            status: event.status,
                            token_id: Vec::from(event.token_id),
                        });
                    }

                    None
                })
        })
        .collect());
    events.manager_fees_paids.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == MANAGER_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::manager_contract::events::FeesPaid::match_and_decode(log) {
                        return Some(contract::ManagerFeesPaid {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            activity_id: Vec::from(event.activity_id),
                            builder: event.builder,
                            builder_amount: event.builder_amount.to_string(),
                            contract_address: event.contract_address,
                            hub_amount: event.hub_amount.to_string(),
                            hub_id: event.hub_id.to_string(),
                            payment_token: event.payment_token,
                            protocol_amount: event.protocol_amount.to_string(),
                            sender: event.sender,
                        });
                    }

                    None
                })
        })
        .collect());
    events.manager_initializeds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == MANAGER_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::manager_contract::events::Initialized::match_and_decode(log) {
                        return Some(contract::ManagerInitialized {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            version: event.version.to_u64(),
                        });
                    }

                    None
                })
        })
        .collect());
    events.manager_ownership_transferreds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == MANAGER_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::manager_contract::events::OwnershipTransferred::match_and_decode(log) {
                        return Some(contract::ManagerOwnershipTransferred {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            new_owner: event.new_owner,
                            user: event.user,
                        });
                    }

                    None
                })
        })
        .collect());
}
fn map_launchpad_events(
    blk: &eth::Block,
    token_id_to_address_store: &store::StoreGetString,
    events: &mut contract::Events,
) {
    events.launchpad_buys.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == LAUNCHPAD_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::launchpad_contract::events::Buy::match_and_decode(log) {
                        let token_id_key = format!("0x{}", Hex(&event.token_id).to_string());
                        return Some(contract::LaunchpadBuy {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            amount_in: event.amount_in.to_string(),
                            liquidity_wei: event.liquidity_wei.to_string(),
                            price: event.price.to_string(),
                            receiver: event.receiver,
                            supply: event.supply.to_string(),
                            token_id: Vec::from(event.token_id),
                            tokens_left: event.tokens_left.to_string(),
                            tokens_out: event.tokens_out.to_string(),
                            trader: event.trader,
                            token_address: token_id_to_address_store.get_last(token_id_key).unwrap_or_default(),
                        });
                    }

                    None
                })
        })
        .collect());
    events.launchpad_new_pool_types.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == LAUNCHPAD_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::launchpad_contract::events::NewPoolType::match_and_decode(log) {
                        return Some(contract::LaunchpadNewPoolType {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            creator_reward: event.creator_reward.to_string(),
                            initial_reserve_deposit_wad: event.initial_reserve_deposit_wad.to_string(),
                            initial_token_deposit_wad: event.initial_token_deposit_wad.to_string(),
                            migration_reserve_supply: event.migration_reserve_supply.to_string(),
                            migration_supply: event.migration_supply.to_string(),
                            migration_token_supply: event.migration_token_supply.to_string(),
                            pool_type_id: event.pool_type_id.to_string(),
                            price_at_migration_supply: event.price_at_migration_supply.to_string(),
                            weight: event.weight.to_u64(),
                        });
                    }

                    None
                })
        })
        .collect());
    events.launchpad_ownership_transferreds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == LAUNCHPAD_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::launchpad_contract::events::OwnershipTransferred::match_and_decode(log) {
                        return Some(contract::LaunchpadOwnershipTransferred {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            new_owner: event.new_owner,
                            user: event.user,
                        });
                    }

                    None
                })
        })
        .collect());
    events.launchpad_phase_expiry_config_sets.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == LAUNCHPAD_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::launchpad_contract::events::PhaseExpiryConfigSet::match_and_decode(log) {
                        return Some(contract::LaunchpadPhaseExpiryConfigSet {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            phase1_expiry_blocks: event.phase1_expiry_blocks.to_u64(),
                            phase2_expiry_blocks: event.phase2_expiry_blocks.to_u64(),
                        });
                    }

                    None
                })
        })
        .collect());
    events.launchpad_sells.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == LAUNCHPAD_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::launchpad_contract::events::Sell::match_and_decode(log) {
                        let token_id_key = format!("0x{}", Hex(&event.token_id).to_string());
                        return Some(contract::LaunchpadSell {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            amount_out: event.amount_out.to_string(),
                            liquidity_wei: event.liquidity_wei.to_string(),
                            price: event.price.to_string(),
                            supply: event.supply.to_string(),
                            token_id: Vec::from(event.token_id),
                            tokens_in: event.tokens_in.to_string(),
                            tokens_left: event.tokens_left.to_string(),
                            trader: event.trader,
                            token_address: token_id_to_address_store.get_last(token_id_key).unwrap_or_default(),
                        });
                    }

                    None
                })
        })
        .collect());
    events.launchpad_graduations.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == LAUNCHPAD_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some((token_id, is_external, final_supply, final_reserves)) = decode_launchpad_graduation(log) {
                        let token_id_key = format!("0x{}", Hex(&token_id).to_string());
                        return Some(contract::LaunchpadGraduation {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            token_id: token_id.clone(),
                            token_address: token_id_to_address_store.get_last(token_id_key.clone()).unwrap_or_default(),
                            is_external,
                            final_supply,
                            final_reserves,
                            token_layer_id: token_id_key,
                        });
                    }

                    None
                })
        })
        .collect());
}
fn map_ip_events(blk: &eth::Block, events: &mut contract::Events) {
    events.ip_approvals.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == IP_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::ip_contract::events::Approval::match_and_decode(log) {
                        return Some(contract::IpApproval {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            id: event.id.to_string(),
                            owner: event.owner,
                            spender: event.spender,
                        });
                    }

                    None
                })
        })
        .collect());
    events.ip_approval_for_alls.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == IP_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::ip_contract::events::ApprovalForAll::match_and_decode(log) {
                        return Some(contract::IpApprovalForAll {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            approved: event.approved,
                            operator: event.operator,
                            owner: event.owner,
                        });
                    }

                    None
                })
        })
        .collect());
    events.ip_manager_changeds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == IP_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::ip_contract::events::ManagerChanged::match_and_decode(log) {
                        return Some(contract::IpManagerChanged {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            new_manager: event.new_manager,
                        });
                    }

                    None
                })
        })
        .collect());
    events.ip_transfers.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == IP_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::ip_contract::events::Transfer::match_and_decode(log) {
                        return Some(contract::IpTransfer {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            from: event.from,
                            id: event.id.to_string(),
                            to: event.to,
                        });
                    }

                    None
                })
        })
        .collect());
}
fn map_liquidity_mananager_events(blk: &eth::Block, events: &mut contract::Events) {
    events.liquidity_mananager_fees_collecteds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == LIQUIDITY_MANANAGER_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::liquidity_mananager_contract::events::FeesCollected::match_and_decode(log) {
                        return Some(contract::LiquidityMananagerFeesCollected {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            amount0: event.amount0.to_string(),
                            amount1: event.amount1.to_string(),
                            key_id: Vec::from(event.key_id),
                            token_id: event.token_id.to_string(),
                        });
                    }

                    None
                })
        })
        .collect());
    events.liquidity_mananager_fees_distributeds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == LIQUIDITY_MANANAGER_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::liquidity_mananager_contract::events::FeesDistributed::match_and_decode(log) {
                        return Some(contract::LiquidityMananagerFeesDistributed {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            amount0_owner: event.amount0_owner.to_string(),
                            amount0_protocol: event.amount0_protocol.to_string(),
                            amount1_owner: event.amount1_owner.to_string(),
                            amount1_protocol: event.amount1_protocol.to_string(),
                            key_id: Vec::from(event.key_id),
                            owner: event.owner,
                            protocol_fee_to: event.protocol_fee_to,
                            token0: event.token0,
                            token1: event.token1,
                            token_id: event.token_id.to_string(),
                        });
                    }

                    None
                })
        })
        .collect());
    events.liquidity_mananager_initial_position_minteds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == LIQUIDITY_MANANAGER_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::liquidity_mananager_contract::events::InitialPositionMinted::match_and_decode(log) {
                        return Some(contract::LiquidityMananagerInitialPositionMinted {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            amount0: event.amount0.to_string(),
                            amount1: event.amount1.to_string(),
                            key_id: Vec::from(event.key_id),
                            liquidity: event.liquidity.to_string(),
                            tick_lower: Into::<num_bigint::BigInt>::into(event.tick_lower).to_i64().unwrap(),
                            tick_upper: Into::<num_bigint::BigInt>::into(event.tick_upper).to_i64().unwrap(),
                            token0: event.token0,
                            token1: event.token1,
                            token_id: event.token_id.to_string(),
                        });
                    }

                    None
                })
        })
        .collect());
    events.liquidity_mananager_initializeds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == LIQUIDITY_MANANAGER_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::liquidity_mananager_contract::events::Initialized::match_and_decode(log) {
                        return Some(contract::LiquidityMananagerInitialized {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            version: event.version.to_u64(),
                        });
                    }

                    None
                })
        })
        .collect());
    events.liquidity_mananager_liquidity_increaseds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == LIQUIDITY_MANANAGER_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::liquidity_mananager_contract::events::LiquidityIncreased::match_and_decode(log) {
                        return Some(contract::LiquidityMananagerLiquidityIncreased {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            amount0: event.amount0.to_string(),
                            amount1: event.amount1.to_string(),
                            liquidity_added: event.liquidity_added.to_string(),
                            token_id: event.token_id.to_string(),
                        });
                    }

                    None
                })
        })
        .collect());
    events.liquidity_mananager_liquidity_manager_initializeds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == LIQUIDITY_MANANAGER_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::liquidity_mananager_contract::events::LiquidityManagerInitialized::match_and_decode(log) {
                        return Some(contract::LiquidityMananagerLiquidityManagerInitialized {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            nonfungible_position_manager: event.nonfungible_position_manager,
                            owner: event.owner,
                            registry: event.registry,
                        });
                    }

                    None
                })
        })
        .collect());
    events.liquidity_mananager_liquidity_manager_upgradeds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == LIQUIDITY_MANANAGER_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::liquidity_mananager_contract::events::LiquidityManagerUpgraded::match_and_decode(log) {
                        return Some(contract::LiquidityMananagerLiquidityManagerUpgraded {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            new_implementation: event.new_implementation,
                            old_implementation: event.old_implementation,
                        });
                    }

                    None
                })
        })
        .collect());
    events.liquidity_mananager_liquidity_migrateds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == LIQUIDITY_MANANAGER_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::liquidity_mananager_contract::events::LiquidityMigrated::match_and_decode(log) {
                        return Some(contract::LiquidityMananagerLiquidityMigrated {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            destination_chain: Vec::from(event.destination_chain),
                            fee: event.fee.to_u64(),
                            is_default: event.is_default,
                            liquidity: event.liquidity.to_string(),
                            token_id: event.token_id.to_string(),
                        });
                    }

                    None
                })
        })
        .collect());
    events.liquidity_mananager_new_deposits.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == LIQUIDITY_MANANAGER_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::liquidity_mananager_contract::events::NewDeposit::match_and_decode(log) {
                        return Some(contract::LiquidityMananagerNewDeposit {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            liquidity: event.liquidity.to_string(),
                            token0: event.token0,
                            token1: event.token1,
                            token_id: event.token_id.to_string(),
                        });
                    }

                    None
                })
        })
        .collect());
    events.liquidity_mananager_ownership_transferreds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == LIQUIDITY_MANANAGER_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::liquidity_mananager_contract::events::OwnershipTransferred::match_and_decode(log) {
                        return Some(contract::LiquidityMananagerOwnershipTransferred {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            new_owner: event.new_owner,
                            previous_owner: event.previous_owner,
                        });
                    }

                    None
                })
        })
        .collect());
    events.liquidity_mananager_pool_createds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == LIQUIDITY_MANANAGER_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::liquidity_mananager_contract::events::PoolCreated::match_and_decode(log) {
                        return Some(contract::LiquidityMananagerPoolCreated {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            fee: event.fee.to_u64(),
                            pool: event.pool,
                            sqrt_price_x96: event.sqrt_price_x96.to_string(),
                            token0: event.token0,
                            token1: event.token1,
                        });
                    }

                    None
                })
        })
        .collect());
    events.liquidity_mananager_position_created_via_composes.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == LIQUIDITY_MANANAGER_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::liquidity_mananager_contract::events::PositionCreatedViaCompose::match_and_decode(log) {
                        return Some(contract::LiquidityMananagerPositionCreatedViaCompose {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            amount0: event.amount0.to_string(),
                            amount1: event.amount1.to_string(),
                            key_id: Vec::from(event.key_id),
                            sqrt_price_x96: event.sqrt_price_x96.to_string(),
                            token0: event.token0,
                            token1: event.token1,
                            token_id: event.token_id.to_string(),
                        });
                    }

                    None
                })
        })
        .collect());
    events.liquidity_mananager_upgradeds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == LIQUIDITY_MANANAGER_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::liquidity_mananager_contract::events::Upgraded::match_and_decode(log) {
                        return Some(contract::LiquidityMananagerUpgraded {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            implementation: event.implementation,
                        });
                    }

                    None
                })
        })
        .collect());
}
fn map_fees_events(blk: &eth::Block, events: &mut contract::Events) {
    events.fees_fee_distributeds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == FEES_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::fees_contract::events::FeeDistributed::match_and_decode(log) {
                        return Some(contract::FeesFeeDistributed {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            activity_id: event.activity_id.to_u64(),
                            amount: event.amount.to_string(),
                            currency: event.currency,
                            distribution_type: event.distribution_type.to_u64(),
                            recipient: event.recipient,
                            tracking_id: Vec::from(event.tracking_id),
                        });
                    }

                    None
                })
        })
        .collect());
    events.fees_protocol_fee_distributeds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == FEES_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::fees_contract::events::ProtocolFeeDistributed::match_and_decode(log) {
                        return Some(contract::FeesProtocolFeeDistributed {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            activity_id: event.activity_id.to_u64(),
                            amount: event.amount.to_string(),
                            currency: event.currency,
                        });
                    }

                    None
                })
        })
        .collect());
    events.fees_protocol_fees_controller_updateds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == FEES_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::fees_contract::events::ProtocolFeesControllerUpdated::match_and_decode(log) {
                        return Some(contract::FeesProtocolFeesControllerUpdated {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            new_controller: event.new_controller,
                            old_controller: event.old_controller,
                        });
                    }

                    None
                })
        })
        .collect());
    events.fees_protocol_withdrawns.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == FEES_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::fees_contract::events::ProtocolWithdrawn::match_and_decode(log) {
                        return Some(contract::FeesProtocolWithdrawn {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            amount: event.amount.to_string(),
                            currency: event.currency,
                            to: event.to,
                        });
                    }

                    None
                })
        })
        .collect());
    events.fees_withdrawns.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == FEES_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::fees_contract::events::Withdrawn::match_and_decode(log) {
                        return Some(contract::FeesWithdrawn {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            amount: event.amount.to_string(),
                            currency: event.currency,
                            recipient: event.recipient,
                            to: event.to,
                        });
                    }

                    None
                })
        })
        .collect());
}
fn map_roles_events(blk: &eth::Block, events: &mut contract::Events) {
    events.roles_approvals.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == ROLES_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::roles_contract::events::Approval::match_and_decode(log) {
                        return Some(contract::RolesApproval {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            amount: event.amount.to_string(),
                            id: event.id.to_string(),
                            owner: event.owner,
                            spender: event.spender,
                        });
                    }

                    None
                })
        })
        .collect());
    events.roles_ban_removeds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == ROLES_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::roles_contract::events::BanRemoved::match_and_decode(log) {
                        return Some(contract::RolesBanRemoved {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            account: event.account,
                            sender: event.sender,
                            user: event.user,
                        });
                    }

                    None
                })
        })
        .collect());
    events.roles_manager_changeds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == ROLES_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::roles_contract::events::ManagerChanged::match_and_decode(log) {
                        return Some(contract::RolesManagerChanged {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            new_manager: event.new_manager,
                        });
                    }

                    None
                })
        })
        .collect());
    events.roles_ownership_transferreds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == ROLES_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::roles_contract::events::OwnershipTransferred::match_and_decode(log) {
                        return Some(contract::RolesOwnershipTransferred {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            new_owner: event.new_owner,
                            user: event.user,
                        });
                    }

                    None
                })
        })
        .collect());
    events.roles_role_addeds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == ROLES_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::roles_contract::events::RoleAdded::match_and_decode(log) {
                        return Some(contract::RolesRoleAdded {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            account: event.account,
                            order_no: event.order_no.to_string(),
                            role_id: event.role_id.to_string(),
                        });
                    }

                    None
                })
        })
        .collect());
    events.roles_role_createds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == ROLES_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::roles_contract::events::RoleCreated::match_and_decode(log) {
                        return Some(contract::RolesRoleCreated {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            id: event.id.to_string(),
                            name: event.name,
                        });
                    }

                    None
                })
        })
        .collect());
    events.roles_role_granteds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == ROLES_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::roles_contract::events::RoleGranted::match_and_decode(log) {
                        return Some(contract::RolesRoleGranted {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            account: event.account,
                            id: event.id.to_string(),
                            role_name: event.role_name,
                            sender: event.sender,
                            user: event.user,
                        });
                    }

                    None
                })
        })
        .collect());
    events.roles_role_order_updateds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == ROLES_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::roles_contract::events::RoleOrderUpdated::match_and_decode(log) {
                        return Some(contract::RolesRoleOrderUpdated {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            account: event.account,
                            order_no: event.order_no.to_string(),
                            role_id: event.role_id.to_string(),
                        });
                    }

                    None
                })
        })
        .collect());
    events.roles_role_removeds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == ROLES_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::roles_contract::events::RoleRemoved::match_and_decode(log) {
                        return Some(contract::RolesRoleRemoved {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            account: event.account,
                            role_id: event.role_id.to_string(),
                        });
                    }

                    None
                })
        })
        .collect());
    events.roles_role_renounceds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == ROLES_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::roles_contract::events::RoleRenounced::match_and_decode(log) {
                        return Some(contract::RolesRoleRenounced {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            account: event.account,
                            id: event.id.to_string(),
                            sender: event.sender,
                        });
                    }

                    None
                })
        })
        .collect());
    events.roles_role_revokeds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == ROLES_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::roles_contract::events::RoleRevoked::match_and_decode(log) {
                        return Some(contract::RolesRoleRevoked {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            account: event.account,
                            id: event.id.to_string(),
                            role_name: event.role_name,
                            sender: event.sender,
                            user: event.user,
                        });
                    }

                    None
                })
        })
        .collect());
    events.roles_transfers.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == ROLES_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::roles_contract::events::Transfer::match_and_decode(log) {
                        return Some(contract::RolesTransfer {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            amount: event.amount.to_string(),
                            caller: event.caller,
                            from: event.from,
                            id: event.id.to_string(),
                            to: event.to,
                        });
                    }

                    None
                })
        })
        .collect());
    events.roles_user_kickeds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == ROLES_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::roles_contract::events::UserKicked::match_and_decode(log) {
                        return Some(contract::RolesUserKicked {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            account: event.account,
                            deadline: event.deadline.to_string(),
                            sender: event.sender,
                            user: event.user,
                        });
                    }

                    None
                })
        })
        .collect());
}
fn is_declared_dds_address(addr: &Vec<u8>, ordinal: u64, dds_store: &store::StoreGetInt64) -> bool {
    //    substreams::log::info!("Checking if address {} is declared dds address", Hex(addr).to_string());
    if dds_store.get_at(ordinal, Hex(addr).to_string()).is_some() {
        return true;
    }
    return false;
}

fn tracked_token_addresses_created_in_block(blk: &eth::Block) -> HashSet<String> {
    let mut tracked = HashSet::new();
    for rcpt in blk.receipts() {
        for log in rcpt
            .receipt
            .logs
            .iter()
            .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
        {
            if let Some(event) = abi::registry_contract::events::TokenCreated::match_and_decode(log) {
                tracked.insert(Hex(event.token_address).to_string());
            }
            if let Some(event) = abi::registry_contract::events::CoinCreated::match_and_decode(log) {
                tracked.insert(Hex(event.coin_address).to_string());
            }
            if let Some(event) = abi::registry_contract::events::ExternalTokenCreated::match_and_decode(log) {
                tracked.insert(Hex(event.token_address).to_string());
            }
            if let Some(event) = abi::registry_contract::events::TokenRegistered::match_and_decode(log) {
                tracked.insert(Hex(event.token_address).to_string());
            }
        }
    }
    tracked
}

fn is_tracked_token_address(
    addr: &Vec<u8>,
    ordinal: u64,
    dds_store: &store::StoreGetInt64,
    created_in_block: &HashSet<String>,
) -> bool {
    let key = Hex(addr).to_string();
    created_in_block.contains(&key) || dds_store.get_at(ordinal, key).is_some()
}

fn is_zero_address(addr: &[u8]) -> bool {
    addr == ZERO_ADDRESS.as_slice()
}

fn balance_store_key(token_address: &Vec<u8>, wallet: &Vec<u8>) -> String {
    format!("{}:{}", Hex(token_address).to_string(), Hex(wallet).to_string())
}

fn user_fee_balance_store_key(account: &Vec<u8>, currency: &Vec<u8>) -> String {
    format!("{}:{}", Hex(account).to_string(), Hex(currency).to_string())
}

fn protocol_fee_balance_store_key(currency: &Vec<u8>) -> String {
    Hex(currency).to_string()
}

fn token_layer_id_from_token_address(token_id_to_address_store: &store::StoreGetString, token_address: &str) -> String {
    token_id_to_address_store
        .get_last(format!("addr:{}", token_address.to_lowercase()))
        .unwrap_or_default()
}

fn decode_i24_topic(topic: &[u8]) -> Option<i32> {
    if topic.len() != 32 {
        return None;
    }
    let mut raw = ((topic[29] as i32) << 16) | ((topic[30] as i32) << 8) | (topic[31] as i32);
    if (raw & 0x0080_0000) != 0 {
        raw -= 0x0100_0000;
    }
    Some(raw)
}

fn decode_uniswap_v3_mint(log: &eth::Log) -> Option<(Vec<u8>, Vec<u8>, i32, i32, String, String, String)> {
    if log.topics.len() != 4 || log.data.len() != 128 {
        return None;
    }
    if log.topics[0].as_slice() != UNISWAP_V3_MINT_TOPIC {
        return None;
    }

    let owner = log.topics[1].get(12..32)?.to_vec();
    let tick_lower = decode_i24_topic(log.topics[2].as_slice())?;
    let tick_upper = decode_i24_topic(log.topics[3].as_slice())?;

    let values = ethabi::decode(
        &[
            ethabi::ParamType::Address,
            ethabi::ParamType::Uint(128),
            ethabi::ParamType::Uint(256),
            ethabi::ParamType::Uint(256),
        ],
        log.data.as_slice(),
    )
    .ok()?;

    let sender = values.get(0)?.clone().into_address()?.as_bytes().to_vec();
    let amount = values.get(1)?.clone().into_uint()?.to_string();
    let amount0 = values.get(2)?.clone().into_uint()?.to_string();
    let amount1 = values.get(3)?.clone().into_uint()?.to_string();

    Some((owner, sender, tick_lower, tick_upper, amount, amount0, amount1))
}

fn decode_uniswap_v3_burn(log: &eth::Log) -> Option<(Vec<u8>, i32, i32, String, String, String)> {
    if log.topics.len() != 4 || log.data.len() != 96 {
        return None;
    }
    if log.topics[0].as_slice() != UNISWAP_V3_BURN_TOPIC {
        return None;
    }

    let owner = log.topics[1].get(12..32)?.to_vec();
    let tick_lower = decode_i24_topic(log.topics[2].as_slice())?;
    let tick_upper = decode_i24_topic(log.topics[3].as_slice())?;

    let values = ethabi::decode(
        &[
            ethabi::ParamType::Uint(128),
            ethabi::ParamType::Uint(256),
            ethabi::ParamType::Uint(256),
        ],
        log.data.as_slice(),
    )
    .ok()?;

    let amount = values.get(0)?.clone().into_uint()?.to_string();
    let amount0 = values.get(1)?.clone().into_uint()?.to_string();
    let amount1 = values.get(2)?.clone().into_uint()?.to_string();

    Some((owner, tick_lower, tick_upper, amount, amount0, amount1))
}

fn decode_launchpad_graduation(log: &eth::Log) -> Option<(Vec<u8>, bool, String, String)> {
    if log.topics.len() != 2 || log.data.len() != 96 {
        return None;
    }
    if log.topics[0].as_slice() != LAUNCHPAD_GRADUATION_TOPIC {
        return None;
    }

    let token_id = log.topics[1].as_slice().to_vec();
    let values = ethabi::decode(
        &[
            ethabi::ParamType::Bool,
            ethabi::ParamType::Uint(256),
            ethabi::ParamType::Uint(256),
        ],
        log.data.as_slice(),
    )
    .ok()?;

    let is_external = values.get(0)?.clone().into_bool()?;
    let final_supply = values.get(1)?.clone().into_uint()?.to_string();
    let final_reserves = values.get(2)?.clone().into_uint()?.to_string();

    Some((token_id, is_external, final_supply, final_reserves))
}

fn parse_big_int_or_zero(input: &str) -> substreams::scalar::BigInt {
    substreams::scalar::BigInt::from_str(input).unwrap_or_else(|_| substreams::scalar::BigInt::from(0))
}

fn decimal_to_string_max_18(value: &substreams::scalar::BigDecimal) -> String {
    let s = value.to_string();
    if let Some(dot) = s.find('.') {
        let int_part = &s[..dot];
        let frac_part = &s[dot + 1..];
        let mut limited = frac_part.chars().take(18).collect::<String>();
        while limited.ends_with('0') {
            limited.pop();
        }
        if limited.is_empty() {
            int_part.to_string()
        } else {
            format!("{}.{}", int_part, limited)
        }
    } else {
        s
    }
}
fn map_token_coin_events(
    blk: &eth::Block,
    dds_store: &store::StoreGetInt64,
    token_id_to_address_store: &store::StoreGetString,
    created_in_block: &HashSet<String>,
    events: &mut contract::Events,
) {

    events.token_coin_approvals.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| is_tracked_token_address(&log.address, log.ordinal, dds_store, created_in_block))
                .filter_map(|log| {
                    if let Some(event) = abi::token_coin_contract::events::Approval::match_and_decode(log) {
                        let token_address = format!("0x{}", Hex(&log.address).to_string());
                        return Some(contract::TokenCoinApproval {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            token_address: token_address.clone(),
                            amount: event.amount.to_string(),
                            owner: event.owner,
                            spender: event.spender,
                            token_layer_id: token_layer_id_from_token_address(token_id_to_address_store, &token_address),
                        });
                    }

                    None
                })
        })
        .collect());

    events.token_coin_enforced_option_sets.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| is_tracked_token_address(&log.address, log.ordinal, dds_store, created_in_block))
                .filter_map(|log| {
                    if let Some(event) = abi::token_coin_contract::events::EnforcedOptionSet::match_and_decode(log) {
                        let token_address = format!("0x{}", Hex(&log.address).to_string());
                        return Some(contract::TokenCoinEnforcedOptionSet {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            token_address: token_address.clone(),
                            token_layer_id: token_layer_id_from_token_address(token_id_to_address_store, &token_address),
                        });
                    }

                    None
                })
        })
        .collect());

    events.token_coin_initializeds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| is_tracked_token_address(&log.address, log.ordinal, dds_store, created_in_block))
                .filter_map(|log| {
                    if let Some(event) = abi::token_coin_contract::events::Initialized::match_and_decode(log) {
                        let token_address = format!("0x{}", Hex(&log.address).to_string());
                        return Some(contract::TokenCoinInitialized {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            token_address: token_address.clone(),
                            version: event.version.to_u64(),
                            token_layer_id: token_layer_id_from_token_address(token_id_to_address_store, &token_address),
                        });
                    }

                    None
                })
        })
        .collect());

    events.token_coin_msg_inspector_sets.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| is_tracked_token_address(&log.address, log.ordinal, dds_store, created_in_block))
                .filter_map(|log| {
                    if let Some(event) = abi::token_coin_contract::events::MsgInspectorSet::match_and_decode(log) {
                        let token_address = format!("0x{}", Hex(&log.address).to_string());
                        return Some(contract::TokenCoinMsgInspectorSet {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            token_address: token_address.clone(),
                            inspector: event.inspector,
                            token_layer_id: token_layer_id_from_token_address(token_id_to_address_store, &token_address),
                        });
                    }

                    None
                })
        })
        .collect());

    events.token_coin_oft_receiveds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| is_tracked_token_address(&log.address, log.ordinal, dds_store, created_in_block))
                .filter_map(|log| {
                    if let Some(event) = abi::token_coin_contract::events::OftReceived::match_and_decode(log) {
                        let token_address = format!("0x{}", Hex(&log.address).to_string());
                        return Some(contract::TokenCoinOftReceived {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            token_address: token_address.clone(),
                            amount_received_ld: event.amount_received_ld.to_string(),
                            guid: Vec::from(event.guid),
                            src_eid: event.src_eid.to_u64(),
                            to_address: event.to_address,
                            token_layer_id: token_layer_id_from_token_address(token_id_to_address_store, &token_address),
                        });
                    }

                    None
                })
        })
        .collect());

    events.token_coin_oft_sents.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| is_tracked_token_address(&log.address, log.ordinal, dds_store, created_in_block))
                .filter_map(|log| {
                    if let Some(event) = abi::token_coin_contract::events::OftSent::match_and_decode(log) {
                        let token_address = format!("0x{}", Hex(&log.address).to_string());
                        return Some(contract::TokenCoinOftSent {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            token_address: token_address.clone(),
                            amount_received_ld: event.amount_received_ld.to_string(),
                            amount_sent_ld: event.amount_sent_ld.to_string(),
                            dst_eid: event.dst_eid.to_u64(),
                            from_address: event.from_address,
                            guid: Vec::from(event.guid),
                            token_layer_id: token_layer_id_from_token_address(token_id_to_address_store, &token_address),
                        });
                    }

                    None
                })
        })
        .collect());

    events.token_coin_ownership_transferreds.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| is_tracked_token_address(&log.address, log.ordinal, dds_store, created_in_block))
                .filter_map(|log| {
                    if let Some(event) = abi::token_coin_contract::events::OwnershipTransferred::match_and_decode(log) {
                        let token_address = format!("0x{}", Hex(&log.address).to_string());
                        return Some(contract::TokenCoinOwnershipTransferred {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            token_address: token_address.clone(),
                            new_owner: event.new_owner,
                            previous_owner: event.previous_owner,
                            token_layer_id: token_layer_id_from_token_address(token_id_to_address_store, &token_address),
                        });
                    }

                    None
                })
        })
        .collect());

    events.token_coin_peer_sets.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| is_tracked_token_address(&log.address, log.ordinal, dds_store, created_in_block))
                .filter_map(|log| {
                    if let Some(event) = abi::token_coin_contract::events::PeerSet::match_and_decode(log) {
                        let token_address = format!("0x{}", Hex(&log.address).to_string());
                        return Some(contract::TokenCoinPeerSet {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            token_address: token_address.clone(),
                            eid: event.eid.to_u64(),
                            peer: Vec::from(event.peer),
                            token_layer_id: token_layer_id_from_token_address(token_id_to_address_store, &token_address),
                        });
                    }

                    None
                })
        })
        .collect());

    events.token_coin_pre_crime_sets.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| is_tracked_token_address(&log.address, log.ordinal, dds_store, created_in_block))
                .filter_map(|log| {
                    if let Some(event) = abi::token_coin_contract::events::PreCrimeSet::match_and_decode(log) {
                        let token_address = format!("0x{}", Hex(&log.address).to_string());
                        return Some(contract::TokenCoinPreCrimeSet {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            token_address: token_address.clone(),
                            pre_crime_address: event.pre_crime_address,
                            token_layer_id: token_layer_id_from_token_address(token_id_to_address_store, &token_address),
                        });
                    }

                    None
                })
        })
        .collect());

    events.token_coin_transfers.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| is_tracked_token_address(&log.address, log.ordinal, dds_store, created_in_block))
                .filter_map(|log| {
                    if let Some(event) = abi::token_coin_contract::events::Transfer::match_and_decode(log) {
                        let token_address = format!("0x{}", Hex(&log.address).to_string());
                        return Some(contract::TokenCoinTransfer {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            token_address: token_address.clone(),
                            amount: event.amount.to_string(),
                            from: event.from,
                            to: event.to,
                            token_layer_id: token_layer_id_from_token_address(token_id_to_address_store, &token_address),
                        });
                    }

                    None
                })
        })
        .collect());
}

fn map_uniswap_v3_pool_events(
    blk: &eth::Block,
    pools_store: &store::StoreGetInt64,
    pool_meta_store: &store::StoreGetString,
    token_id_to_address_store: &store::StoreGetString,
    events: &mut contract::Events,
) {
    events.uniswap_v3_swaps.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| is_declared_dds_address(&log.address, log.ordinal, pools_store))
                .filter_map(|log| {
                    if let Some(event) = abi::uniswap_v3_pool_contract::events::Swap::match_and_decode(log) {
                        let pool_key = Hex(&log.address).to_string();
                        let pool_meta = pool_meta_store.get_last(pool_key.clone()).unwrap_or_default();
                        let mut parts = pool_meta.split('|');
                        let token0 = parts.next().unwrap_or_default().to_string();
                        let token1 = parts.next().unwrap_or_default().to_string();
                        let token0_address = if token0.is_empty() { String::new() } else { format!("0x{}", token0) };
                        let token1_address = if token1.is_empty() { String::new() } else { format!("0x{}", token1) };
                        let token0_layer_id = if token0_address.is_empty() {
                            String::new()
                        } else {
                            token_layer_id_from_token_address(token_id_to_address_store, &token0_address)
                        };
                        let token1_layer_id = if token1_address.is_empty() {
                            String::new()
                        } else {
                            token_layer_id_from_token_address(token_id_to_address_store, &token1_address)
                        };
                        let (token_address, token_layer_id) = if !token0_layer_id.is_empty() {
                            (token0_address, token0_layer_id)
                        } else if !token1_layer_id.is_empty() {
                            (token1_address, token1_layer_id)
                        } else {
                            (String::new(), String::new())
                        };
                        return Some(contract::UniswapV3Swap {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            pool: format!("0x{}", Hex(&log.address).to_string()),
                            sender: format!("0x{}", Hex(&event.sender).to_string()),
                            recipient: format!("0x{}", Hex(&event.recipient).to_string()),
                            amount0: event.amount0.to_string(),
                            amount1: event.amount1.to_string(),
                            sqrt_price_x96: event.sqrt_price_x96.to_string(),
                            liquidity: event.liquidity.to_string(),
                            tick: event.tick.to_string(),
                            token_address,
                            token_layer_id,
                        });
                    }

                    None
                })
        })
        .collect());

    events.uniswap_v3_mints.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| is_declared_dds_address(&log.address, log.ordinal, pools_store))
                .filter_map(|log| {
                    if let Some((owner, sender, tick_lower, tick_upper, amount, amount0, amount1)) = decode_uniswap_v3_mint(log) {
                        let pool_key = Hex(&log.address).to_string();
                        let pool_meta = pool_meta_store.get_last(pool_key.clone()).unwrap_or_default();
                        let mut parts = pool_meta.split('|');
                        let token0 = parts.next().unwrap_or_default().to_string();
                        let token1 = parts.next().unwrap_or_default().to_string();
                        let token0_address = if token0.is_empty() { String::new() } else { format!("0x{}", token0) };
                        let token1_address = if token1.is_empty() { String::new() } else { format!("0x{}", token1) };
                        let token0_layer_id = if token0_address.is_empty() {
                            String::new()
                        } else {
                            token_layer_id_from_token_address(token_id_to_address_store, &token0_address)
                        };
                        let token1_layer_id = if token1_address.is_empty() {
                            String::new()
                        } else {
                            token_layer_id_from_token_address(token_id_to_address_store, &token1_address)
                        };
                        let (token_address, token_layer_id) = if !token0_layer_id.is_empty() {
                            (token0_address, token0_layer_id)
                        } else if !token1_layer_id.is_empty() {
                            (token1_address, token1_layer_id)
                        } else {
                            (String::new(), String::new())
                        };

                        return Some(contract::UniswapV3Mint {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            pool: format!("0x{}", Hex(&log.address).to_string()),
                            owner: format!("0x{}", Hex(&owner).to_string()),
                            sender: format!("0x{}", Hex(&sender).to_string()),
                            tick_lower: tick_lower.to_string(),
                            tick_upper: tick_upper.to_string(),
                            amount,
                            amount0,
                            amount1,
                            token_address,
                            token_layer_id,
                        });
                    }

                    None
                })
        })
        .collect());

    events.uniswap_v3_burns.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| is_declared_dds_address(&log.address, log.ordinal, pools_store))
                .filter_map(|log| {
                    if let Some((owner, tick_lower, tick_upper, amount, amount0, amount1)) = decode_uniswap_v3_burn(log) {
                        let pool_key = Hex(&log.address).to_string();
                        let pool_meta = pool_meta_store.get_last(pool_key.clone()).unwrap_or_default();
                        let mut parts = pool_meta.split('|');
                        let token0 = parts.next().unwrap_or_default().to_string();
                        let token1 = parts.next().unwrap_or_default().to_string();
                        let token0_address = if token0.is_empty() { String::new() } else { format!("0x{}", token0) };
                        let token1_address = if token1.is_empty() { String::new() } else { format!("0x{}", token1) };
                        let token0_layer_id = if token0_address.is_empty() {
                            String::new()
                        } else {
                            token_layer_id_from_token_address(token_id_to_address_store, &token0_address)
                        };
                        let token1_layer_id = if token1_address.is_empty() {
                            String::new()
                        } else {
                            token_layer_id_from_token_address(token_id_to_address_store, &token1_address)
                        };
                        let (token_address, token_layer_id) = if !token0_layer_id.is_empty() {
                            (token0_address, token0_layer_id)
                        } else if !token1_layer_id.is_empty() {
                            (token1_address, token1_layer_id)
                        } else {
                            (String::new(), String::new())
                        };

                        return Some(contract::UniswapV3Burn {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            pool: format!("0x{}", Hex(&log.address).to_string()),
                            owner: format!("0x{}", Hex(&owner).to_string()),
                            tick_lower: tick_lower.to_string(),
                            tick_upper: tick_upper.to_string(),
                            amount,
                            amount0,
                            amount1,
                            token_address,
                            token_layer_id,
                        });
                    }

                    None
                })
        })
        .collect());
}

fn map_wallet_token_balance_events(
    blk: &eth::Block,
    tracked_tokens_store: &store::StoreGetInt64,
    token_id_to_address_store: &store::StoreGetString,
    created_in_block: &HashSet<String>,
    balances_store: &store::StoreGetBigInt,
    events: &mut contract::Events,
) {
    let mut touched_keys: HashMap<String, u64> = HashMap::new();

    for view in blk.receipts() {
        for log in view
            .receipt
            .logs
            .iter()
            .filter(|log| is_tracked_token_address(&log.address, log.ordinal, tracked_tokens_store, created_in_block))
        {
            if let Some(transfer) = abi::token_coin_contract::events::Transfer::match_and_decode(log) {
                if !is_zero_address(&transfer.from) {
                    let from_key = balance_store_key(&log.address, &transfer.from);
                    touched_keys.insert(from_key, log.ordinal);
                }
                if !is_zero_address(&transfer.to) {
                    let to_key = balance_store_key(&log.address, &transfer.to);
                    touched_keys.insert(to_key, log.ordinal);
                }
            }
        }
    }

    for (key, ordinal) in touched_keys {
        let mut split = key.split(':');
        let token = split.next().unwrap_or_default().to_string();
        let wallet = split.next().unwrap_or_default().to_string();
        if token.is_empty() || wallet.is_empty() {
            continue;
        }

        if let Some(balance) = balances_store.get_at(ordinal, key.clone()) {
            let token_address = format!("0x{}", token);
            events.wallet_token_balances.push(contract::WalletTokenBalance {
                evt_block_number: blk.number,
                evt_block_time: Some(blk.timestamp().to_owned()),
                token_address: token_address.clone(),
                wallet: format!("0x{}", wallet),
                balance: balance.to_string(),
                token_layer_id: token_layer_id_from_token_address(token_id_to_address_store, &token_address),
            });
        }
    }
}

fn map_fee_balance_events(
    blk: &eth::Block,
    user_fee_balances_store: &store::StoreGetBigInt,
    protocol_fee_balances_store: &store::StoreGetBigInt,
    events: &mut contract::Events,
) {
    let mut touched_user_keys: HashMap<String, u64> = HashMap::new();
    let mut touched_protocol_keys: HashMap<String, u64> = HashMap::new();

    for view in blk.receipts() {
        for log in view.receipt.logs.iter().filter(|log| log.address == FEES_TRACKED_CONTRACT) {
            if let Some(event) = abi::fees_contract::events::FeeDistributed::match_and_decode(log) {
                let key = user_fee_balance_store_key(&event.recipient, &event.currency);
                touched_user_keys.insert(key, log.ordinal);
            }
            if let Some(event) = abi::fees_contract::events::Withdrawn::match_and_decode(log) {
                let key = user_fee_balance_store_key(&event.recipient, &event.currency);
                touched_user_keys.insert(key, log.ordinal);
            }
            if let Some(event) = abi::fees_contract::events::ProtocolFeeDistributed::match_and_decode(log) {
                let key = protocol_fee_balance_store_key(&event.currency);
                touched_protocol_keys.insert(key, log.ordinal);
            }
            if let Some(event) = abi::fees_contract::events::ProtocolWithdrawn::match_and_decode(log) {
                let key = protocol_fee_balance_store_key(&event.currency);
                touched_protocol_keys.insert(key, log.ordinal);
            }
        }
    }

    for (key, ordinal) in touched_user_keys {
        let mut split = key.split(':');
        let account = split.next().unwrap_or_default().to_string();
        let currency = split.next().unwrap_or_default().to_string();
        if account.is_empty() || currency.is_empty() {
            continue;
        }
        if let Some(balance) = user_fee_balances_store.get_at(ordinal, key) {
            events.user_fee_balance_currents.push(contract::UserFeeBalanceCurrent {
                evt_block_number: blk.number,
                evt_block_time: Some(blk.timestamp().to_owned()),
                account: format!("0x{}", account),
                currency: format!("0x{}", currency),
                balance: balance.to_string(),
            });
        }
    }

    for (key, ordinal) in touched_protocol_keys {
        if key.is_empty() {
            continue;
        }
        if let Some(balance) = protocol_fee_balances_store.get_at(ordinal, key.clone()) {
            events.protocol_fee_balance_currents.push(contract::ProtocolFeeBalanceCurrent {
                evt_block_number: blk.number,
                evt_block_time: Some(blk.timestamp().to_owned()),
                currency: format!("0x{}", key),
                balance: balance.to_string(),
            });
        }
    }
}

fn get_token_decimals_with_source(
    token_decimals_store: &store::StoreGetInt64,
    token_address_no_prefix: &str,
    default_decimals: u64,
) -> (u64, String) {
    match token_decimals_store.get_last(token_address_no_prefix.to_string()) {
        Some(v) => (v as u64, "token_store".to_string()),
        None => (default_decimals, "default_assumed_18".to_string()),
    }
}

fn get_token_total_supply(
    token_total_supply_store: &store::StoreGetBigInt,
    token_address_no_prefix: &str,
    default_supply: &substreams::scalar::BigInt,
) -> substreams::scalar::BigInt {
    token_total_supply_store
        .get_last(token_address_no_prefix.to_string())
        .unwrap_or_else(|| default_supply.clone())
}

fn map_agg_token_trades(
    params: &str,
    _blk: &eth::Block,
    token_id_to_address_store: &store::StoreGetString,
    token_decimals_store: &store::StoreGetInt64,
    token_total_supply_store: &store::StoreGetBigInt,
    uniswap_pool_meta_store: &store::StoreGetString,
    events: &mut contract::Events,
) {
    let usd_token_address = resolve_usd_token_address(params);
    let usd_decimals = resolve_u64_param(params, "usd_token_decimals", 6);
    let launchpad_usd_decimals = resolve_u64_param(params, "launchpad_usd_decimals", 18);
    let default_token_decimals = resolve_u64_param(params, "default_token_decimals", 18);
    let default_token_supply = resolve_u64_param(params, "default_token_supply", 1_000_000_000);

    for evt in events.launchpad_buys.iter() {
        let token_id_key = format!("0x{}", Hex(&evt.token_id).to_string());
        let maybe_token_address = token_id_to_address_store
            .get_last(token_id_key.clone())
            .or_else(|| {
                if token_id_key.len() == 42 {
                    Some(token_id_key.clone())
                } else {
                    None
                }
            });
        let token_address = match maybe_token_address {
            Some(v) => v,
            None => continue,
        };
        let token_layer_id = token_id_to_address_store
            .get_last(format!("addr:{}", token_address.to_lowercase()))
            .unwrap_or_else(|| token_id_key.clone());
        let token_no_prefix = token_address.trim_start_matches("0x");
        let (token_decimals, token_decimals_source) =
            get_token_decimals_with_source(token_decimals_store, token_no_prefix, default_token_decimals);
        let token_amount_raw = parse_big_int_or_zero(&evt.tokens_out);
        let usd_amount_raw = parse_big_int_or_zero(&evt.amount_in);
        if token_amount_raw.is_zero() {
            continue;
        }
        let token_amount = token_amount_raw.to_decimal(token_decimals);
        let usd_amount = usd_amount_raw.to_decimal(launchpad_usd_decimals);
        let price_usd = parse_big_int_or_zero(&evt.price).to_decimal(launchpad_usd_decimals);
        let circulating_raw = parse_big_int_or_zero(&evt.supply);
        let tokens_left_raw = parse_big_int_or_zero(&evt.tokens_left);
        let total_from_pool_raw = circulating_raw + tokens_left_raw;
        let default_total_supply_raw =
            substreams::scalar::BigInt::from(default_token_supply) * substreams::scalar::BigInt::from(10).pow(token_decimals as u32);
        let configured_total_supply_raw =
            get_token_total_supply(token_total_supply_store, token_no_prefix, &default_total_supply_raw);
        let effective_total_supply_raw = if configured_total_supply_raw > total_from_pool_raw {
            configured_total_supply_raw
        } else {
            total_from_pool_raw
        };
        let market_cap_usd = price_usd.clone() * effective_total_supply_raw.to_decimal(token_decimals);

        events.agg_token_trades.push(contract::AggTokenTrade {
            evt_tx_hash: evt.evt_tx_hash.clone(),
            evt_index: evt.evt_index,
            evt_block_time: evt.evt_block_time.clone(),
            evt_block_number: evt.evt_block_number,
            venue: "launchpad".to_string(),
            trade_type: "buy".to_string(),
            wallet: format!("0x{}", Hex(&evt.trader).to_string()),
            token_address: token_address.clone(),
            pool: String::new(),
            token_amount: decimal_to_string_max_18(&token_amount),
            usd_amount: decimal_to_string_max_18(&usd_amount),
            price_usd: decimal_to_string_max_18(&price_usd),
            market_cap_usd: decimal_to_string_max_18(&market_cap_usd),
            token_layer_id,
            token_amount_raw: token_amount_raw.to_string(),
            usd_amount_raw: usd_amount_raw.to_string(),
            token_decimals,
            quote_decimals: launchpad_usd_decimals,
            token_decimals_source,
            quote_decimals_source: "launchpad_param".to_string(),
        });
    }

    for evt in events.launchpad_sells.iter() {
        let token_id_key = format!("0x{}", Hex(&evt.token_id).to_string());
        let maybe_token_address = token_id_to_address_store
            .get_last(token_id_key.clone())
            .or_else(|| {
                if token_id_key.len() == 42 {
                    Some(token_id_key.clone())
                } else {
                    None
                }
            });
        let token_address = match maybe_token_address {
            Some(v) => v,
            None => continue,
        };
        let token_layer_id = token_id_to_address_store
            .get_last(format!("addr:{}", token_address.to_lowercase()))
            .unwrap_or_else(|| token_id_key.clone());
        let token_no_prefix = token_address.trim_start_matches("0x");
        let (token_decimals, token_decimals_source) =
            get_token_decimals_with_source(token_decimals_store, token_no_prefix, default_token_decimals);
        let token_amount_raw = parse_big_int_or_zero(&evt.tokens_in);
        let usd_amount_raw = parse_big_int_or_zero(&evt.amount_out);
        if token_amount_raw.is_zero() {
            continue;
        }
        let token_amount = token_amount_raw.to_decimal(token_decimals);
        let usd_amount = usd_amount_raw.to_decimal(launchpad_usd_decimals);
        let price_usd = parse_big_int_or_zero(&evt.price).to_decimal(launchpad_usd_decimals);
        let circulating_raw = parse_big_int_or_zero(&evt.supply);
        let tokens_left_raw = parse_big_int_or_zero(&evt.tokens_left);
        let total_from_pool_raw = circulating_raw + tokens_left_raw;
        let default_total_supply_raw =
            substreams::scalar::BigInt::from(default_token_supply) * substreams::scalar::BigInt::from(10).pow(token_decimals as u32);
        let configured_total_supply_raw =
            get_token_total_supply(token_total_supply_store, token_no_prefix, &default_total_supply_raw);
        let effective_total_supply_raw = if configured_total_supply_raw > total_from_pool_raw {
            configured_total_supply_raw
        } else {
            total_from_pool_raw
        };
        let market_cap_usd = price_usd.clone() * effective_total_supply_raw.to_decimal(token_decimals);

        events.agg_token_trades.push(contract::AggTokenTrade {
            evt_tx_hash: evt.evt_tx_hash.clone(),
            evt_index: evt.evt_index,
            evt_block_time: evt.evt_block_time.clone(),
            evt_block_number: evt.evt_block_number,
            venue: "launchpad".to_string(),
            trade_type: "sell".to_string(),
            wallet: format!("0x{}", Hex(&evt.trader).to_string()),
            token_address: token_address.clone(),
            pool: String::new(),
            token_amount: decimal_to_string_max_18(&token_amount),
            usd_amount: decimal_to_string_max_18(&usd_amount),
            price_usd: decimal_to_string_max_18(&price_usd),
            market_cap_usd: decimal_to_string_max_18(&market_cap_usd),
            token_layer_id,
            token_amount_raw: token_amount_raw.to_string(),
            usd_amount_raw: usd_amount_raw.to_string(),
            token_decimals,
            quote_decimals: launchpad_usd_decimals,
            token_decimals_source,
            quote_decimals_source: "launchpad_param".to_string(),
        });
    }

    for evt in events.uniswap_v3_swaps.iter() {
        let pool_key = evt.pool.trim_start_matches("0x").to_lowercase();
        let pool_meta = match uniswap_pool_meta_store.get_last(pool_key.clone()) {
            Some(v) => v,
            None => continue,
        };
        let mut parts = pool_meta.split('|');
        let token0 = parts.next().unwrap_or_default().to_string();
        let token1 = parts.next().unwrap_or_default().to_string();
        if token0.is_empty() || token1.is_empty() {
            continue;
        }

        let (tracked_token, token_raw_signed, usd_raw_signed, quote_decimals) =
            if token0 == usd_token_address {
                (
                    token1.clone(),
                    parse_big_int_or_zero(&evt.amount1),
                    parse_big_int_or_zero(&evt.amount0),
                    usd_decimals,
                )
            } else if token1 == usd_token_address {
                (
                    token0.clone(),
                    parse_big_int_or_zero(&evt.amount0),
                    parse_big_int_or_zero(&evt.amount1),
                    usd_decimals,
                )
            } else {
                continue;
            };

        let trade_type = if usd_raw_signed > substreams::scalar::BigInt::zero() {
            "buy"
        } else if usd_raw_signed < substreams::scalar::BigInt::zero() {
            "sell"
        } else {
            "unknown"
        };

        let token_amount_raw = token_raw_signed.absolute();
        let usd_amount_raw = usd_raw_signed.absolute();
        if token_amount_raw.is_zero() {
            continue;
        }
        let (token_decimals, token_decimals_source) =
            get_token_decimals_with_source(token_decimals_store, &tracked_token, default_token_decimals);
        let token_amount = token_amount_raw.to_decimal(token_decimals);
        let usd_amount = usd_amount_raw.to_decimal(quote_decimals);
        let price_usd = usd_amount.clone() / token_amount.clone();
        let default_total_supply_raw =
            substreams::scalar::BigInt::from(default_token_supply) * substreams::scalar::BigInt::from(10).pow(token_decimals as u32);
        let total_supply_raw = get_token_total_supply(token_total_supply_store, &tracked_token, &default_total_supply_raw);
        let market_cap_usd = price_usd.clone() * total_supply_raw.to_decimal(token_decimals);

        let tracked_token_address = format!("0x{}", tracked_token);
        let token_layer_id = token_id_to_address_store
            .get_last(format!("addr:{}", tracked_token_address.to_lowercase()))
            .unwrap_or_default();

        events.agg_token_trades.push(contract::AggTokenTrade {
            evt_tx_hash: evt.evt_tx_hash.clone(),
            evt_index: evt.evt_index,
            evt_block_time: evt.evt_block_time.clone(),
            evt_block_number: evt.evt_block_number,
            venue: "uniswap_v3".to_string(),
            trade_type: trade_type.to_string(),
            wallet: evt.sender.clone(),
            token_address: tracked_token_address,
            pool: evt.pool.clone(),
            token_amount: decimal_to_string_max_18(&token_amount),
            usd_amount: decimal_to_string_max_18(&usd_amount),
            price_usd: decimal_to_string_max_18(&price_usd),
            market_cap_usd: decimal_to_string_max_18(&market_cap_usd),
            token_layer_id,
            token_amount_raw: token_amount_raw.to_string(),
            usd_amount_raw: usd_amount_raw.to_string(),
            token_decimals,
            quote_decimals,
            token_decimals_source,
            quote_decimals_source: "stablecoin_param".to_string(),
        });
    }
}

#[substreams::handlers::store]
fn store_token_coin_created(blk: eth::Block, store: StoreSetInt64) {
    for rcpt in blk.receipts() {
        for log in rcpt
            .receipt
            .logs
            .iter()
            .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
        {
            if let Some(event) = abi::registry_contract::events::TokenCreated::match_and_decode(log) {
                store.set(log.ordinal, Hex(event.token_address).to_string(), &1);
            }
            if let Some(event) = abi::registry_contract::events::CoinCreated::match_and_decode(log) {
                store.set(log.ordinal, Hex(event.coin_address).to_string(), &1);
            }
            if let Some(event) = abi::registry_contract::events::ExternalTokenCreated::match_and_decode(log) {
                store.set(log.ordinal, Hex(event.token_address).to_string(), &1);
            }
            if let Some(event) = abi::registry_contract::events::TokenRegistered::match_and_decode(log) {
                store.set(log.ordinal, Hex(event.token_address).to_string(), &1);
            }
        }
    }
}

#[substreams::handlers::store]
fn store_token_id_to_address(blk: eth::Block, store: StoreSetString) {
    for rcpt in blk.receipts() {
        for log in rcpt
            .receipt
            .logs
            .iter()
            .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
        {
            if let Some(event) = abi::registry_contract::events::TokenCreated::match_and_decode(log) {
                let token_id = if log.topics.len() > 2 {
                    format!("0x{}", Hex(&log.topics[2]).to_string())
                } else {
                    event.token_id.to_string()
                };
                let token_address = format!("0x{}", Hex(&event.token_address).to_string());
                store.set(log.ordinal, token_id, &token_address);
                let reverse_token_id = if log.topics.len() > 2 {
                    format!("0x{}", Hex(&log.topics[2]).to_string())
                } else {
                    event.token_id.to_string()
                };
                store.set(log.ordinal, format!("addr:{}", token_address.to_lowercase()), &reverse_token_id);
            }
            if let Some(event) = abi::registry_contract::events::TokenRegistered::match_and_decode(log) {
                let token_id = format!("0x{}", Hex(&event.token_id).to_string());
                let token_address = format!("0x{}", Hex(&event.token_address).to_string());
                store.set(log.ordinal, token_id, &token_address);
                store.set(log.ordinal, format!("addr:{}", token_address.to_lowercase()), &format!("0x{}", Hex(&event.token_id).to_string()));
            }
            if let Some(event) = abi::registry_contract::events::ExternalTokenCreated::match_and_decode(log) {
                let token_id = format!("0x{}", Hex(&event.token_id).to_string());
                let token_address = format!("0x{}", Hex(&event.token_address).to_string());
                store.set(log.ordinal, token_id, &token_address);
                store.set(log.ordinal, format!("addr:{}", token_address.to_lowercase()), &format!("0x{}", Hex(&event.token_id).to_string()));
            }
        }
    }
}

#[substreams::handlers::store]
fn store_token_decimals(blk: eth::Block, store: StoreSetInt64) {
    for rcpt in blk.receipts() {
        for log in rcpt
            .receipt
            .logs
            .iter()
            .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
        {
            if let Some(event) = abi::registry_contract::events::TokenCreated::match_and_decode(log) {
                let token_address = Hex(&event.token_address).to_string();
                store.set(log.ordinal, token_address, &(event.decimals.to_u64() as i64));
            }
            if let Some(event) = abi::registry_contract::events::CoinCreated::match_and_decode(log) {
                let token_address = Hex(&event.coin_address).to_string();
                store.set(log.ordinal, token_address, &(event.decimals.to_u64() as i64));
            }
        }
    }
}

#[substreams::handlers::store]
fn store_token_total_supply(blk: eth::Block, store: StoreSetBigInt) {
    for rcpt in blk.receipts() {
        for log in rcpt
            .receipt
            .logs
            .iter()
            .filter(|log| log.address == REGISTRY_TRACKED_CONTRACT)
        {
            if let Some(event) = abi::registry_contract::events::CoinCreated::match_and_decode(log) {
                let token_address = Hex(&event.coin_address).to_string();
                let total_supply = parse_big_int_or_zero(&event.total_supply.to_string());
                store.set(log.ordinal, token_address, &total_supply);
            }
        }
    }
}

#[substreams::handlers::store]
fn store_uniswap_v3_pools(params: String, blk: eth::Block, tracked_tokens_store: StoreGetInt64, store: StoreSetInt64) {
    let uniswap_v3_factory = resolve_uniswap_factory_address(&params);
    for rcpt in blk.receipts() {
        for log in rcpt
            .receipt
            .logs
            .iter()
            .filter(|log| Hex(&log.address).to_string() == uniswap_v3_factory)
        {
            if let Some(event) = abi::uniswap_v3_factory_contract::events::PoolCreated::match_and_decode(log) {
                if !is_declared_dds_address(&event.token0, log.ordinal, &tracked_tokens_store)
                    && !is_declared_dds_address(&event.token1, log.ordinal, &tracked_tokens_store)
                {
                    continue;
                }
                store.set(log.ordinal, Hex(event.pool).to_string(), &1);
            }
        }
    }
}

#[substreams::handlers::store]
fn store_uniswap_v3_pool_meta(params: String, blk: eth::Block, tracked_tokens_store: StoreGetInt64, store: StoreSetString) {
    let uniswap_v3_factory = resolve_uniswap_factory_address(&params);
    for rcpt in blk.receipts() {
        for log in rcpt
            .receipt
            .logs
            .iter()
            .filter(|log| Hex(&log.address).to_string() == uniswap_v3_factory)
        {
            if let Some(event) = abi::uniswap_v3_factory_contract::events::PoolCreated::match_and_decode(log) {
                if !is_declared_dds_address(&event.token0, log.ordinal, &tracked_tokens_store)
                    && !is_declared_dds_address(&event.token1, log.ordinal, &tracked_tokens_store)
                {
                    continue;
                }
                let pool = Hex(&event.pool).to_string();
                let meta = format!("{}|{}", Hex(&event.token0).to_string(), Hex(&event.token1).to_string());
                store.set(log.ordinal, pool, &meta);
            }
        }
    }
}

#[substreams::handlers::store]
fn store_wallet_token_balances(
    blk: eth::Block,
    tracked_tokens_store: StoreGetInt64,
    store: StoreAddBigInt,
) {
    let created_in_block = tracked_token_addresses_created_in_block(&blk);
    for rcpt in blk.receipts() {
        for log in rcpt
            .receipt
            .logs
            .iter()
            .filter(|log| is_tracked_token_address(&log.address, log.ordinal, &tracked_tokens_store, &created_in_block))
        {
            if let Some(transfer) = abi::token_coin_contract::events::Transfer::match_and_decode(log) {
                if !is_zero_address(&transfer.to) {
                    let to_key = balance_store_key(&log.address, &transfer.to);
                    store.add(log.ordinal, to_key, &transfer.amount);
                }
                if !is_zero_address(&transfer.from) {
                    let from_key = balance_store_key(&log.address, &transfer.from);
                    let negative_amount = substreams::scalar::BigInt::from(0) - transfer.amount;
                    store.add(log.ordinal, from_key, &negative_amount);
                }
            }
        }
    }
}

#[substreams::handlers::store]
fn store_user_fee_balances(blk: eth::Block, store: StoreAddBigInt) {
    for rcpt in blk.receipts() {
        for log in rcpt.receipt.logs.iter().filter(|log| log.address == FEES_TRACKED_CONTRACT) {
            if let Some(event) = abi::fees_contract::events::FeeDistributed::match_and_decode(log) {
                let key = user_fee_balance_store_key(&event.recipient, &event.currency);
                let amount = parse_big_int_or_zero(&event.amount.to_string());
                store.add(log.ordinal, key, &amount);
            }
            if let Some(event) = abi::fees_contract::events::Withdrawn::match_and_decode(log) {
                let key = user_fee_balance_store_key(&event.recipient, &event.currency);
                let amount = parse_big_int_or_zero(&event.amount.to_string());
                let negative_amount = substreams::scalar::BigInt::from(0) - amount;
                store.add(log.ordinal, key, &negative_amount);
            }
        }
    }
}

#[substreams::handlers::store]
fn store_protocol_fee_balances(blk: eth::Block, store: StoreAddBigInt) {
    for rcpt in blk.receipts() {
        for log in rcpt.receipt.logs.iter().filter(|log| log.address == FEES_TRACKED_CONTRACT) {
            if let Some(event) = abi::fees_contract::events::ProtocolFeeDistributed::match_and_decode(log) {
                let key = protocol_fee_balance_store_key(&event.currency);
                let amount = parse_big_int_or_zero(&event.amount.to_string());
                store.add(log.ordinal, key, &amount);
            }
            if let Some(event) = abi::fees_contract::events::ProtocolWithdrawn::match_and_decode(log) {
                let key = protocol_fee_balance_store_key(&event.currency);
                let amount = parse_big_int_or_zero(&event.amount.to_string());
                let negative_amount = substreams::scalar::BigInt::from(0) - amount;
                store.add(log.ordinal, key, &negative_amount);
            }
        }
    }
}

#[substreams::handlers::map]
fn map_events(
    params: String,
    blk: eth::Block,
    store_token_coin: StoreGetInt64,
    store_token_id_to_address: StoreGetString,
    store_token_decimals: StoreGetInt64,
    store_token_total_supply: StoreGetBigInt,
    store_uniswap_pools: StoreGetInt64,
    store_uniswap_pool_meta: StoreGetString,
    store_wallet_balances: StoreGetBigInt,
    store_user_fee_balances: StoreGetBigInt,
    store_protocol_fee_balances: StoreGetBigInt,
) -> Result<contract::Events, substreams::errors::Error> {
    let uniswap_v3_factory = resolve_uniswap_factory_address(&params);
    let oapp_tracked_contract = resolve_oapp_address(&params);
    let created_in_block = tracked_token_addresses_created_in_block(&blk);
    let mut events = contract::Events::default();
    map_registry_events(&blk, &mut events);
    map_oapp_events(&blk, &oapp_tracked_contract, &mut events);
    map_manager_events(&blk, &mut events);
    map_launchpad_events(&blk, &store_token_id_to_address, &mut events);
    map_ip_events(&blk, &mut events);
    map_liquidity_mananager_events(&blk, &mut events);
    map_fees_events(&blk, &mut events);
    map_roles_events(&blk, &mut events);
    map_token_coin_events(&blk, &store_token_coin, &store_token_id_to_address, &created_in_block, &mut events);
    map_uniswap_v3_pool_created_events(
        &blk,
        &store_token_coin,
        &store_token_id_to_address,
        &uniswap_v3_factory,
        &mut events,
    );
    map_uniswap_v3_pool_events(
        &blk,
        &store_uniswap_pools,
        &store_uniswap_pool_meta,
        &store_token_id_to_address,
        &mut events,
    );
    map_wallet_token_balance_events(
        &blk,
        &store_token_coin,
        &store_token_id_to_address,
        &created_in_block,
        &store_wallet_balances,
        &mut events,
    );
    map_fee_balance_events(&blk, &store_user_fee_balances, &store_protocol_fee_balances, &mut events);
    map_agg_token_trades(
        &params,
        &blk,
        &store_token_id_to_address,
        &store_token_decimals,
        &store_token_total_supply,
        &store_uniswap_pool_meta,
        &mut events,
    );
    Ok(events)
}

#[substreams::handlers::map]
fn db_out(events: contract::Events) -> Result<substreams_database_change::pb::database::DatabaseChanges, substreams::errors::Error> {
    Ok(db_changes::events_to_database_changes(events))
}
