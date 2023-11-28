use starknet::ContractAddress;
use dojo::database::introspect::{
    Enum, Member, Ty, Struct, Introspect, serialize_member, serialize_member_type
};

// *************************************************************************
//                                   Model
// *************************************************************************

#[derive(Model, Copy, Drop, Serde)]
struct Waiter {
    #[key]
    lobby_id: u32,
    #[key]
    index: usize,
    waiter_id: ContractAddress,
    is_waiting: bool
}

// *************************************************************************
//                              Implementation
// *************************************************************************

#[generate_trait]
impl WaiterImpl of WaiterTrait {
    fn new(lobby_id: u32, index: usize, waiter_id: ContractAddress) -> Waiter {
        Waiter { lobby_id, index, waiter_id, is_waiting: true }
    }
}
