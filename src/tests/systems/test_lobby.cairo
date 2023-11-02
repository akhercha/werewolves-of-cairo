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
    testing::set_contract_address(caller_address);
    
    // Create a lobby
    let lobby_name: felt252 = 'good lobby';
    let (lobby_id, creator) = lobby_system.create_lobby('good lobby');

    // Check world state
    let lobby_created: Lobby = get!(world, lobby_id, Lobby);
    assert(lobby_created.creator == caller_address, 'should be caller');
    assert(lobby_created.name == lobby_name, 'should be lobby_name');
    assert(lobby_created.num_players == 1, 'should have 1 player');
}

#[test]
#[available_gas(30000000)]
#[should_panic(expected: ('Name too short', 'ENTRYPOINT_FAILED'))]
fn test_create_lobby_invalid_name_too_short() {
    let (_, _, lobby_system) = setup();

    lobby_system.create_lobby(0);
}

#[test]
#[available_gas(30000000)]
#[should_panic(expected: ('Name too long', 'ENTRYPOINT_FAILED'))]
fn test_assert_valid_string_name_too_long() {
    let (_, _, lobby_system) = setup();

    let lobby_name: felt252 = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
    lobby_system.create_lobby(lobby_name);
}


// *************************************************************************
//                                 Utilities
// *************************************************************************
fn setup() -> (ContractAddress, IWorldDispatcher, ILobbyDispatcher) {
    // define caller address
    let caller_address = contract_address_const::<'caller'>();

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
