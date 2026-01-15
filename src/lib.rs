mod abi;
#[allow(unused)]
mod pb;
use hex_literal::hex;
use pb::contract::v1 as contract;
use substreams::prelude::*;
use substreams::store;
use substreams::Hex;
use substreams_ethereum::pb::eth::v2 as eth;
use substreams_ethereum::Event;

#[allow(unused_imports)] // Might not be needed depending on actual ABI, hence the allow
use {num_traits::cast::ToPrimitive, std::str::FromStr, substreams::scalar::BigDecimal};

substreams_ethereum::init!();

const REGISTRY_TRACKED_CONTRACT: [u8; 20] = hex!("000000194d2afe38a20707cb96ed1583038bf02f");
const OAPP_TRACKED_CONTRACT: [u8; 20] = hex!("f132f6224dad58568c54780c14e1d3b97a5f672a");
const MANAGER_TRACKED_CONTRACT: [u8; 20] = hex!("0000007707a8be37357598bb351f39a25eba7028");
const LAUNCHPAD_TRACKED_CONTRACT: [u8; 20] = hex!("00000a3e40c7ee4053389d5bb6fa57e64536def1");
const IP_TRACKED_CONTRACT: [u8; 20] = hex!("00089428a12cd4a6064be0125ced1f6a1066deed");
const LIQUIDITY_MANANAGER_TRACKED_CONTRACT: [u8; 20] = hex!("e60159a9831ed8c8a8832da1b9a10c03d737dcb2");
const FEES_TRACKED_CONTRACT: [u8; 20] = hex!("feeeba1dcc3abbd045e8b824d9699e735de49fee");
const ROLES_TRACKED_CONTRACT: [u8; 20] = hex!("ff582c406d037ac7aaddbb203d74bde112791d51");

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
                            token_id: Vec::from(event.token_id),
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
                            hub_id: event.hub_id.to_string(),
                            name: event.name,
                            symbol: event.symbol,
                            token_address: event.token_address,
                            token_id: event.token_id.to_string(),
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
                            token_id: Vec::from(event.token_id),
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
fn map_oapp_events(blk: &eth::Block, events: &mut contract::Events) {
    events.oapp_eth_withdrawns.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == OAPP_TRACKED_CONTRACT)
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
                .filter(|log| log.address == OAPP_TRACKED_CONTRACT)
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
                .filter(|log| log.address == OAPP_TRACKED_CONTRACT)
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
                .filter(|log| log.address == OAPP_TRACKED_CONTRACT)
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
                .filter(|log| log.address == OAPP_TRACKED_CONTRACT)
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
                .filter(|log| log.address == OAPP_TRACKED_CONTRACT)
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
                .filter(|log| log.address == OAPP_TRACKED_CONTRACT)
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
                .filter(|log| log.address == OAPP_TRACKED_CONTRACT)
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
                .filter(|log| log.address == OAPP_TRACKED_CONTRACT)
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
                .filter(|log| log.address == OAPP_TRACKED_CONTRACT)
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
                .filter(|log| log.address == OAPP_TRACKED_CONTRACT)
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
                .filter(|log| log.address == OAPP_TRACKED_CONTRACT)
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
                .filter(|log| log.address == OAPP_TRACKED_CONTRACT)
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
                .filter(|log| log.address == OAPP_TRACKED_CONTRACT)
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
fn map_launchpad_events(blk: &eth::Block, events: &mut contract::Events) {
    events.launchpad_buys.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| log.address == LAUNCHPAD_TRACKED_CONTRACT)
                .filter_map(|log| {
                    if let Some(event) = abi::launchpad_contract::events::Buy::match_and_decode(log) {
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
fn map_token_coin_events(
    blk: &eth::Block,
    dds_store: &store::StoreGetInt64,
    events: &mut contract::Events,
) {

    events.token_coin_approvals.append(&mut blk
        .receipts()
        .flat_map(|view| {
            view.receipt.logs.iter()
                .filter(|log| is_declared_dds_address(&log.address, log.ordinal, dds_store))
                .filter_map(|log| {
                    if let Some(event) = abi::token_coin_contract::events::Approval::match_and_decode(log) {
                        return Some(contract::TokenCoinApproval {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            evt_address: Hex(&log.address).to_string(),
                            amount: event.amount.to_string(),
                            owner: event.owner,
                            spender: event.spender,
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
                .filter(|log| is_declared_dds_address(&log.address, log.ordinal, dds_store))
                .filter_map(|log| {
                    if let Some(event) = abi::token_coin_contract::events::EnforcedOptionSet::match_and_decode(log) {
                        return Some(contract::TokenCoinEnforcedOptionSet {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            evt_address: Hex(&log.address).to_string(),
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
                .filter(|log| is_declared_dds_address(&log.address, log.ordinal, dds_store))
                .filter_map(|log| {
                    if let Some(event) = abi::token_coin_contract::events::Initialized::match_and_decode(log) {
                        return Some(contract::TokenCoinInitialized {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            evt_address: Hex(&log.address).to_string(),
                            version: event.version.to_u64(),
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
                .filter(|log| is_declared_dds_address(&log.address, log.ordinal, dds_store))
                .filter_map(|log| {
                    if let Some(event) = abi::token_coin_contract::events::MsgInspectorSet::match_and_decode(log) {
                        return Some(contract::TokenCoinMsgInspectorSet {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            evt_address: Hex(&log.address).to_string(),
                            inspector: event.inspector,
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
                .filter(|log| is_declared_dds_address(&log.address, log.ordinal, dds_store))
                .filter_map(|log| {
                    if let Some(event) = abi::token_coin_contract::events::OftReceived::match_and_decode(log) {
                        return Some(contract::TokenCoinOftReceived {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            evt_address: Hex(&log.address).to_string(),
                            amount_received_ld: event.amount_received_ld.to_string(),
                            guid: Vec::from(event.guid),
                            src_eid: event.src_eid.to_u64(),
                            to_address: event.to_address,
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
                .filter(|log| is_declared_dds_address(&log.address, log.ordinal, dds_store))
                .filter_map(|log| {
                    if let Some(event) = abi::token_coin_contract::events::OftSent::match_and_decode(log) {
                        return Some(contract::TokenCoinOftSent {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            evt_address: Hex(&log.address).to_string(),
                            amount_received_ld: event.amount_received_ld.to_string(),
                            amount_sent_ld: event.amount_sent_ld.to_string(),
                            dst_eid: event.dst_eid.to_u64(),
                            from_address: event.from_address,
                            guid: Vec::from(event.guid),
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
                .filter(|log| is_declared_dds_address(&log.address, log.ordinal, dds_store))
                .filter_map(|log| {
                    if let Some(event) = abi::token_coin_contract::events::OwnershipTransferred::match_and_decode(log) {
                        return Some(contract::TokenCoinOwnershipTransferred {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            evt_address: Hex(&log.address).to_string(),
                            new_owner: event.new_owner,
                            previous_owner: event.previous_owner,
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
                .filter(|log| is_declared_dds_address(&log.address, log.ordinal, dds_store))
                .filter_map(|log| {
                    if let Some(event) = abi::token_coin_contract::events::PeerSet::match_and_decode(log) {
                        return Some(contract::TokenCoinPeerSet {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            evt_address: Hex(&log.address).to_string(),
                            eid: event.eid.to_u64(),
                            peer: Vec::from(event.peer),
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
                .filter(|log| is_declared_dds_address(&log.address, log.ordinal, dds_store))
                .filter_map(|log| {
                    if let Some(event) = abi::token_coin_contract::events::PreCrimeSet::match_and_decode(log) {
                        return Some(contract::TokenCoinPreCrimeSet {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            evt_address: Hex(&log.address).to_string(),
                            pre_crime_address: event.pre_crime_address,
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
                .filter(|log| is_declared_dds_address(&log.address, log.ordinal, dds_store))
                .filter_map(|log| {
                    if let Some(event) = abi::token_coin_contract::events::Transfer::match_and_decode(log) {
                        return Some(contract::TokenCoinTransfer {
                            evt_tx_hash: Hex(&view.transaction.hash).to_string(),
                            evt_index: log.block_index,
                            evt_block_time: Some(blk.timestamp().to_owned()),
                            evt_block_number: blk.number,
                            evt_address: Hex(&log.address).to_string(),
                            amount: event.amount.to_string(),
                            from: event.from,
                            to: event.to,
                        });
                    }

                    None
                })
        })
        .collect());
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
        }
    }
}
#[substreams::handlers::map]
fn map_events(
    blk: eth::Block,
    store_token_coin: StoreGetInt64,
) -> Result<contract::Events, substreams::errors::Error> {
    let mut events = contract::Events::default();
    map_registry_events(&blk, &mut events);
    map_oapp_events(&blk, &mut events);
    map_manager_events(&blk, &mut events);
    map_launchpad_events(&blk, &mut events);
    map_ip_events(&blk, &mut events);
    map_liquidity_mananager_events(&blk, &mut events);
    map_fees_events(&blk, &mut events);
    map_roles_events(&blk, &mut events);
    map_token_coin_events(&blk, &store_token_coin, &mut events);
    Ok(events)
}

