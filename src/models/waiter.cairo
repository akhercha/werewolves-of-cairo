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
    index: usize,
    waiter_id: ContractAddress,
    has_left_lobby: bool
}

// *************************************************************************
//                              Implementation
// *************************************************************************

#[generate_trait]
impl WaiterImpl of WaiterTrait {
    fn new(lobby_id: u32, index: usize, waiter_id: ContractAddress) -> Waiter {
        Waiter { lobby_id, index, waiter_id, has_left_lobby: false }
    }
}
