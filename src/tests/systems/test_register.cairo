use starknet::testing;
use starknet::class_hash::Felt252TryIntoClassHash;
use starknet::{ContractAddress, contract_address_const};
use dojo::world::{IWorldDispatcherTrait, IWorldDispatcher};
use dojo::test_utils::{spawn_test_world, deploy_contract};

use werewolves_of_cairo::models::profile::{profile, Profile};

use werewolves_of_cairo::systems::register::{
    IRegisterDispatcher, IRegisterDispatcherTrait, register as register_system
};

// *************************************************************************
//                           Tests implementation
// *************************************************************************

// register()

#[test]
#[available_gas(300000000)]
fn test_register_user() {
    let (caller_address, world, register_system) = setup();
    testing::set_contract_address(caller_address);

    // register new profile from address
    let user_name: felt252 = 'adel';
    register_system.register(user_name);

    // check new profile
    let profile: Profile = get!(world, caller_address, Profile);
    assert(profile.user_name == user_name, 'should be user_name');
}

#[test]
#[available_gas(300000000)]
#[should_panic(expected: ('profile already exists', 'ENTRYPOINT_FAILED'))]
fn test_register_user_twice() {
    let (caller_address, world, register_system) = setup();
    testing::set_contract_address(caller_address);

    // register new profile from address
    let user_name: felt252 = 'adel';
    register_system.register(user_name);
    register_system.register(user_name);
}

#[test]
#[available_gas(300000000)]
#[should_panic(expected: ('Name too short', 'ENTRYPOINT_FAILED'))]
fn test_register_invalid_user_name() {
    let (caller_address, world, register_system) = setup();
    testing::set_contract_address(caller_address);

    // register new profile from address
    let user_name: felt252 = 1;
    register_system.register(user_name);
}

// *************************************************************************
//                                 Utilities
// *************************************************************************
fn setup() -> (ContractAddress, IWorldDispatcher, IRegisterDispatcher) {
    // define caller address
    let caller_address = contract_address_const::<'caller'>();

    // models used
    let mut models = array![profile::TEST_CLASS_HASH];

    // deploy world
    let world = spawn_test_world(models);

    // deploy system contract
    let contract_address = world
        .deploy_contract('salt', register_system::TEST_CLASS_HASH.try_into().unwrap());
    let register_system = IRegisterDispatcher { contract_address };

    return (caller_address, world, register_system);
}
