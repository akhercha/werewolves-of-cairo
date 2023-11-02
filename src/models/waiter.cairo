use starknet::ContractAddress;
use dojo::database::schema::{
    Enum, Member, Ty, Struct, SchemaIntrospection, serialize_member, serialize_member_type
};

// *************************************************************************
//                                   Model
// *************************************************************************

#[derive(Model, Copy, Drop, Serde)]
struct Waiter {
    #[key]
    lobby_id: u32,
    #[key]
    waiter_id: ContractAddress,
    is_waiting: bool
}

// *************************************************************************
//                              Implementation
// *************************************************************************

#[generate_trait]
impl WaiterImpl of WaiterTrait {
    fn new(lobby_id: u32, waiter_id: ContractAddress) -> Waiter {
        Waiter { lobby_id: lobby_id, waiter_id: waiter_id, is_waiting: true }
    }
}
