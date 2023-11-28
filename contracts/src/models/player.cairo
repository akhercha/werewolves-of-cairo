use traits::Default;
use starknet::{ContractAddress, contract_address_const};
use dojo::database::introspect::{
    Enum, Member, Ty, Struct, Introspect, serialize_member, serialize_member_type
};

use werewolves_of_cairo::entities::role::Role;
use werewolves_of_cairo::entities::player_actions::{PlayerActions, DefaultPlayerActions};

// *************************************************************************
//                                   Model
// *************************************************************************

#[derive(Model, Copy, Drop, Serde)]
struct Player {
    #[key]
    game_id: u32,
    #[key]
    index: usize,
    player_address: ContractAddress,
    status: PlayerStatus,
    role: Role,
    actions: PlayerActions
}

#[derive(Copy, Drop, Serde, PartialEq)]
enum PlayerStatus {
    Alive: (),
    Dead: ()
}

// *************************************************************************
//                              Implementation
// *************************************************************************

#[generate_trait]
impl PlayerImpl of PlayerTrait {
    fn new(game_id: u32, index: usize, caller_address: ContractAddress, role: Role) -> Player {
        Player {
            game_id,
            index,
            player_address: caller_address,
            status: PlayerStatus::Alive(()),
            role: role,
            actions: Default::default()
        }
    }
}

// *************************************************************************
//                           Schema Introspections
// *************************************************************************

impl PlayerStatusIntrospectionImpl of Introspect<PlayerStatus> {
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
                name: 'PlayerStatus',
                attrs: array![].span(),
                children: array![
                    ('Alive', serialize_member_type(@Ty::Tuple(array![].span()))),
                    ('Dead', serialize_member_type(@Ty::Tuple(array![].span()))),
                ]
                    .span()
            }
        )
    }
}
