use starknet::{ContractAddress, contract_address_const};
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
    // ------- current phase -------
    day_current: u32,
    is_night: bool,
    // ------- game parameters -------
    /// [Cupido]
    /// If Cupido selects two lovers, their IDs are stored here
    designed_lovers: (ContractAddress, ContractAddress),
    /// [Witch]
    /// Once per game, the witch can save someone that was supposed to die
    witch_can_save: bool
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

    fn new(game_id: u32, creator: ContractAddress, start_time: u64, num_players: usize) -> Game {
        Game {
            game_id: game_id,
            creator: creator,
            start_time: start_time,
            is_active: true,
            num_players: num_players,
            day_current: 0,
            is_night: true,
            designed_lovers: (contract_address_const::<0>(), contract_address_const::<0>()),
            witch_can_save: true
        }
    }
}

// *************************************************************************
//                           Schema Introspections
// *************************************************************************

impl DesignedLoversIntrospectionImpl of SchemaIntrospection<(ContractAddress, ContractAddress)> {
    #[inline(always)]
    fn size() -> usize {
        1
    }

    #[inline(always)]
    fn layout(ref layout: Array<u8>) {
        layout.append(8);
    }

    #[inline(always)]
    fn ty() -> Ty {
        Ty::Enum(
            Enum {
                name: 'DesignedLovers',
                attrs: array![].span(),
                children: array![
                    ('DesignedLovers', serialize_member_type(@Ty::Tuple(array![].span()))),
                ]
                    .span()
            }
        )
    }
}
