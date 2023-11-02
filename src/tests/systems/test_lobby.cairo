use starknet::testing;
use starknet::class_hash::Felt252TryIntoClassHash;
use starknet::{ContractAddress, contract_address_const};
use dojo::world::{IWorldDispatcherTrait, IWorldDispatcher};
use dojo::test_utils::{spawn_test_world, deploy_contract};

use werewolves_of_cairo::models::waiter::{waiter, Waiter};
use werewolves_of_cairo::models::lobby::{lobby, Lobby};

use werewolves_of_cairo::systems::lobby::{
    ILobbyDispatcher, ILobbyDispatcherTrait, lobby as lobby_system
};

// *************************************************************************
//                           Tests implementation
// *************************************************************************

#[test]
#[available_gas(30000000)]
fn test_create_lobby() {
    let (caller_address, world, lobby_system) = setup();
    testing::set_caller_address(caller_address);
    assert(1 == 1, 'wtf');
}

// *************************************************************************
//                                 Utilities
// *************************************************************************
fn setup() -> (ContractAddress, IWorldDispatcher, ILobbyDispatcher) {
    // define caller address
    let caller_address = contract_address_const::<'admin'>();

    // models used
    let mut models = array![waiter::TEST_CLASS_HASH, lobby::TEST_CLASS_HASH];

    // deploy world
    let world = spawn_test_world(models);

    // deploy system contract
    let contract_address = world
        .deploy_contract('salt', lobby_system::TEST_CLASS_HASH.try_into().unwrap());
    let lobby_system = ILobbyDispatcher { contract_address };

    return (caller_address, world, lobby_system);
}
