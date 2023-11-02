use starknet::testing;
use starknet::class_hash::Felt252TryIntoClassHash;
use starknet::{ContractAddress, contract_address_const, Felt252TryIntoContractAddress};
use dojo::world::{IWorldDispatcherTrait, IWorldDispatcher};
use dojo::test_utils::{spawn_test_world, deploy_contract};

use werewolves_of_cairo::models::waiter::{waiter, Waiter};
use werewolves_of_cairo::models::lobby::{lobby, Lobby};
use werewolves_of_cairo::utils::settings::{LobbySettings, LobbySettingsImpl};

use werewolves_of_cairo::systems::lobby::{
    ILobbyDispatcher, ILobbyDispatcherTrait, lobby as lobby_system
};

// *************************************************************************
//                           Tests implementation
// *************************************************************************

#[test]
#[available_gas(300000000)]
fn test_create_lobby() {
    let (caller_address, world, lobby_system) = setup();
    testing::set_contract_address(caller_address);

    // Create a lobby
    let lobby_name: felt252 = 'good lobby';
    let (lobby_id, creator) = lobby_system.create_lobby(lobby_name);
    assert(creator == caller_address, 'wrong returned creator');

    // Check lobby in world state
    let lobby_created: Lobby = get!(world, lobby_id, Lobby);
    assert(lobby_created.creator == caller_address, 'should be caller');
    assert(lobby_created.name == lobby_name, 'should be lobby_name');
    assert(lobby_created.num_players == 1, 'should have 1 player');
    assert(lobby_created.is_open == true, 'should be open');
    assert(lobby_created.waiter_next_id == 1, 'should be 1');
}

#[test]
#[available_gas(300000000)]
#[should_panic(expected: ('Name too short', 'ENTRYPOINT_FAILED'))]
fn test_create_lobby_invalid_name_too_short() {
    let (_, _, lobby_system) = setup();

    lobby_system.create_lobby(0);
}

#[test]
#[available_gas(300000000)]
#[should_panic(expected: ('Name too long', 'ENTRYPOINT_FAILED'))]
fn test_create_lobby_invalid_name_too_long() {
    let (_, _, lobby_system) = setup();

    let lobby_name: felt252 = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
    lobby_system.create_lobby(lobby_name);
}

#[test]
#[available_gas(300000000)]
fn test_join_lobby() {
    let (creator_address, world, lobby_system) = setup();

    // Create a lobby
    testing::set_contract_address(creator_address);
    let (lobby_id, _) = lobby_system.create_lobby('lobby');

    // New player joins lobby
    let new_player: ContractAddress = contract_address_const::<'satoshi'>();
    testing::set_contract_address(new_player);
    lobby_system.join_lobby(lobby_id);

    // Check new player in world state
    let waiter = get!(world, (lobby_id, 1), Waiter);
    assert(waiter.lobby_id == lobby_id, 'should be lobby_id');
    assert(waiter.waiter_id == new_player, 'should be new player');
    assert(waiter.has_left_lobby == false, 'should be in lobby');

    // Check lobby new world state
    let lobby: Lobby = get!(world, lobby_id, Lobby);
    assert(lobby.waiter_next_id == 2, 'should be 2');
    assert(lobby.num_players == 2, 'should be 2');
}

#[test]
#[available_gas(300000000)]
#[should_panic(expected: ('lobby doesnt exists', 'ENTRYPOINT_FAILED'))]
fn test_join_lobby_does_not_exist() {
    let (creator_address, world, lobby_system) = setup();

    // New player tries to joins lobby
    let new_player: ContractAddress = contract_address_const::<'satoshi'>();
    testing::set_contract_address(new_player);
    lobby_system.join_lobby(45678);
}

#[test]
#[available_gas(300000000)]
#[should_panic(expected: ('creator cant join lobby', 'ENTRYPOINT_FAILED'))]
fn test_join_lobby_by_creator() {
    let (creator_address, world, lobby_system) = setup();

    // Create a lobby
    testing::set_contract_address(creator_address);
    let (lobby_id, _) = lobby_system.create_lobby('lobby');

    // Creator tries to join lobby
    lobby_system.join_lobby(lobby_id);
}

#[test]
#[available_gas(300000000)]
#[should_panic(expected: ('lobby isnt open', 'ENTRYPOINT_FAILED'))]
fn test_join_lobby_closed() {
    let (creator_address, world, lobby_system) = setup();

    // Create a lobby
    testing::set_contract_address(creator_address);
    let (lobby_id, _) = lobby_system.create_lobby('lobby');
    // Close the lobby
    lobby_system.close_lobby(lobby_id);

    // New player tries to join lobby
    let new_player: ContractAddress = contract_address_const::<'satoshi'>();
    testing::set_contract_address(new_player);
    lobby_system.join_lobby(lobby_id);
}

#[test]
#[available_gas(300000000)]
#[should_panic(expected: ('caller already in lobby', 'ENTRYPOINT_FAILED'))]
fn test_join_lobby_already_in() {
    let (creator_address, world, lobby_system) = setup();

    // Create a lobby
    testing::set_contract_address(creator_address);
    let (lobby_id, _) = lobby_system.create_lobby('lobby');

    // New player tries to join lobby one time...
    let new_player: ContractAddress = contract_address_const::<'satoshi'>();
    testing::set_contract_address(new_player);
    lobby_system.join_lobby(lobby_id);
    // ... and a second time
    lobby_system.join_lobby(lobby_id);
}

#[test]
#[available_gas(300000000)]
#[should_panic(expected: ('lobby is full', 'ENTRYPOINT_FAILED'))]
fn test_join_lobby_full() {
    let (creator_address, world, lobby_system) = setup();
    let lobby_settings = LobbySettingsImpl::get();

    // Create a lobby
    testing::set_contract_address(creator_address);
    let (lobby_id, _) = lobby_system.create_lobby('lobby');

    // New players tries to join lobby one time in loop to break limit...
    let offset_new_player: usize = 16;
    let mut new_player: felt252 = offset_new_player.into();
    loop {
        if (lobby_settings.max_players + offset_new_player < new_player.try_into().unwrap()) {
            break;
        }
        testing::set_contract_address(Felt252TryIntoContractAddress::try_into(new_player).unwrap());
        lobby_system.join_lobby(lobby_id);
        new_player += 1;
    };
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
