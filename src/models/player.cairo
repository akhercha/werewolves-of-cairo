use starknet::{ContractAddress, contract_address_const};
use dojo::database::schema::{
    Enum, Member, Ty, Struct, SchemaIntrospection, serialize_member, serialize_member_type
};

// *************************************************************************
//                                   Model
// *************************************************************************

#[derive(Model, Copy, Drop, Serde)]
struct Player {
    #[key]
    game_id: u32,
    #[key]
    player_id: ContractAddress,
    player_status: PlayerStatus,
    player_role: PlayerRole,
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

#[derive(Copy, Drop, Serde, PartialEq)]
enum PlayerRole {
    Townfolk: (),
    Werewolf: (),
    FortuneTeller: (),
    LittleGirl: (),
    Witch: (),
    Thief: (),
    Hunter: (),
    Cupido: ()
}

// *************************************************************************
//                              Implementation
// *************************************************************************

#[generate_trait]
impl PlayerImpl of PlayerTrait {
    fn new(game_id: u32, caller_address: ContractAddress) -> Player {
        Player {
            game_id: game_id,
            player_id: caller_address,
            player_status: PlayerStatus::Alive(()),
            // TODO: randomly determine role
            player_role: PlayerRole::Townfolk(()),
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

impl PlayerRoleIntrospectionImpl of SchemaIntrospection<PlayerRole> {
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
                name: 'PlayerRole',
                attrs: array![].span(),
                children: array![
                    ('Townfolk', serialize_member_type(@Ty::Tuple(array![].span()))),
                    ('Werewolf', serialize_member_type(@Ty::Tuple(array![].span()))),
                    ('FortuneTeller', serialize_member_type(@Ty::Tuple(array![].span()))),
                    ('LittleGirl', serialize_member_type(@Ty::Tuple(array![].span()))),
                    ('Witch', serialize_member_type(@Ty::Tuple(array![].span()))),
                    ('Thief', serialize_member_type(@Ty::Tuple(array![].span()))),
                    ('Hunter', serialize_member_type(@Ty::Tuple(array![].span()))),
                    ('Cupido', serialize_member_type(@Ty::Tuple(array![].span()))),
                ]
                    .span()
            }
        )
    }
}
