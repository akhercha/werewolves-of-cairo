use debug::PrintTrait;
use werewolves_of_cairo::models::waiter::{Waiter, WaiterTrait};

// *************************************************************************
//                           Tests implementation
// *************************************************************************

#[test]
#[available_gas(100000)]
fn test_waiter_init() {
    let player = starknet::contract_address_const::<0x0>();
    let lobby_id = 42;
    let waiter_idx = 12;
    let waiter = WaiterTrait::new(lobby_id, waiter_idx, player);
    assert(waiter.lobby_id == lobby_id, 'wrong lobby_id');
    assert(waiter.index == waiter_idx, 'wrong index');
    assert(waiter.waiter_id == player, 'wrong waiter_id');
}
