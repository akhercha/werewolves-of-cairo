use starknet::ContractAddress;
use dojo::database::schema::{
    Enum, Member, Ty, Struct, SchemaIntrospection, serialize_member, serialize_member_type
};
use dojo::world::{IWorld, IWorldDispatcher, IWorldDispatcherTrait};

// *************************************************************************
//                                     MODEL
// *************************************************************************

#[derive(Model, Copy, Drop, Serde)]
struct Game {
    #[key]
    game_id: u32,
    #[key]
    creator: ContractAddress,
    start_time: u64,
    is_active: bool,
    num_players: usize,
}

// *************************************************************************
//                              Implementation
// *************************************************************************

#[generate_trait]
impl GameImpl of GameTrait {
    #[inline(always)]
    fn tick(self: Game) -> bool {
        let info = starknet::get_block_info().unbox();

        if info.block_timestamp < self.start_time {
            return false;
        }
        if !self.is_active {
            return false;
        }

        true
    }
}
