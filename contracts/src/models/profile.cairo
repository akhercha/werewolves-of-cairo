use starknet::ContractAddress;
use dojo::database::schema::{
    Enum, Member, Ty, Struct, SchemaIntrospection, serialize_member, serialize_member_type
};

// *************************************************************************
//                                   Model
// *************************************************************************

#[derive(Model, Copy, Drop, Serde)]
struct Profile {
    #[key]
    user_id: ContractAddress,
    user_name: felt252,
}

// *************************************************************************
//                              Implementation
// *************************************************************************

#[generate_trait]
impl ProfileImpl of ProfileTrait {
    fn new(user_id: ContractAddress, user_name: felt252) -> Profile {
        Profile { user_id, user_name }
    }
}
