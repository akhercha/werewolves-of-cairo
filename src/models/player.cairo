use starknet::{ContractAddress, contract_address_const};
use dojo::database::schema::{
    Enum, Member, Ty, Struct, SchemaIntrospection, serialize_member, serialize_member_type
};
use werewolves_of_cairo::entities::role::Role;

// *************************************************************************
//                                   Model
// *************************************************************************

#[derive(Model, Copy, Drop, Serde)]
struct Player {
    #[key]
    game_id: u32,
    #[key]
    index: usize,
    player_id: ContractAddress,
    player_status: PlayerStatus,
    player_role: Role,
    vote_for: ContractAddress
}

// *************************************************************************
//                               Model Enums
// *************************************************************************

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
    fn new(game_id: u32, index: usize, caller_address: ContractAddress) -> Player {
        Player {
            game_id,
            index,
            player_id: caller_address,
            player_status: PlayerStatus::Alive(()),
            // TODO: randomly determine role
            player_role: Role::Townfolk,
            vote_for: contract_address_const::<0>()
        }
    }
}

// *************************************************************************
//                           Schema Introspections
// *************************************************************************

impl PlayerStatusIntrospectionImpl of SchemaIntrospection<PlayerStatus> {
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
