use starknet::ContractAddress;
use dojo::database::introspect::{
    Enum, Member, Ty, Struct, Introspect, serialize_member, serialize_member_type
};

use werewolves_of_cairo::data::compositions::get_comp_for_num_players;
use werewolves_of_cairo::utils::random::{random, shuffle};

const NBR_OF_ROLES: usize = 8;

#[derive(Copy, Drop, Serde, PartialEq)]
enum Role {
    Townfolk, // 0
    Werewolf, // 1
    FortuneTeller, // 2
    /// LittleGirl:
    ///
    /// can take the risk to read the wolves chat; but has 20% chance of dying
    LittleGirl, // 3
    Witch, // 4
    /// Thief:
    ///
    /// can swap his card with another player or become townfolk
    Thief, // 5
    Hunter, // 6
    Cupido, // 7
}

// *************************************************************************
//                              Implementation
// *************************************************************************

#[generate_trait]
impl RoleImpl of RoleTrait {
    fn all() -> Span<Role> {
        array![
            Role::Townfolk,
            Role::Werewolf,
            Role::FortuneTeller,
            Role::LittleGirl,
            Role::Witch,
            Role::Thief,
            Role::Hunter,
            Role::Cupido,
        ]
            .span()
    }

    fn random() -> Role {
        let roles = RoleImpl::all();
        let index = random(0, roles.len().into());

        *roles.at(index.try_into().unwrap())
    }

    fn composition_for(nb_players: usize) -> Span<Role> {
        get_comp_for_num_players(nb_players)
    }

    fn play_order_night() -> Span<Role> {
        array![Role::Werewolf, Role::FortuneTeller, Role::Witch, Role::LittleGirl,].span()
    }

    fn play_order_specials_first_night() -> Span<Role> {
        array![Role::Thief, Role::Cupido,].span()
    }

    fn is_townfolk(role: @Role) -> bool {
        match role {
            Role::Townfolk => true,
            Role::Werewolf => false,
            Role::FortuneTeller => false,
            Role::LittleGirl => false,
            Role::Witch => false,
            Role::Thief => false,
            Role::Hunter => false,
            Role::Cupido => false
        }
    }

    fn is_werewolf(role: @Role) -> bool {
        match role {
            Role::Townfolk => false,
            Role::Werewolf => true,
            Role::FortuneTeller => false,
            Role::LittleGirl => false,
            Role::Witch => false,
            Role::Thief => false,
            Role::Hunter => false,
            Role::Cupido => false
        }
    }

    fn is_fortune_teller(role: @Role) -> bool {
        match role {
            Role::Townfolk => false,
            Role::Werewolf => false,
            Role::FortuneTeller => true,
            Role::LittleGirl => false,
            Role::Witch => false,
            Role::Thief => false,
            Role::Hunter => false,
            Role::Cupido => false
        }
    }

    fn is_little_girl(role: @Role) -> bool {
        match role {
            Role::Townfolk => false,
            Role::Werewolf => false,
            Role::FortuneTeller => false,
            Role::LittleGirl => true,
            Role::Witch => false,
            Role::Thief => false,
            Role::Hunter => false,
            Role::Cupido => false
        }
    }

    fn is_witch(role: @Role) -> bool {
        match role {
            Role::Townfolk => false,
            Role::Werewolf => false,
            Role::FortuneTeller => false,
            Role::LittleGirl => false,
            Role::Witch => true,
            Role::Thief => false,
            Role::Hunter => false,
            Role::Cupido => false
        }
    }

    fn is_thief(role: @Role) -> bool {
        match role {
            Role::Townfolk => false,
            Role::Werewolf => false,
            Role::FortuneTeller => false,
            Role::LittleGirl => false,
            Role::Witch => false,
            Role::Thief => true,
            Role::Hunter => false,
            Role::Cupido => false
        }
    }

    fn is_hunter(role: @Role) -> bool {
        match role {
            Role::Townfolk => false,
            Role::Werewolf => false,
            Role::FortuneTeller => false,
            Role::LittleGirl => false,
            Role::Witch => false,
            Role::Thief => false,
            Role::Hunter => true,
            Role::Cupido => false
        }
    }

    fn is_cupido(role: @Role) -> bool {
        match role {
            Role::Townfolk => false,
            Role::Werewolf => false,
            Role::FortuneTeller => false,
            Role::LittleGirl => false,
            Role::Witch => false,
            Role::Thief => false,
            Role::Hunter => false,
            Role::Cupido => true
        }
    }
}

// *************************************************************************
//                           Utility traits
// *************************************************************************

impl RoleIntoFelt252 of Into<Role, felt252> {
    fn into(self: Role) -> felt252 {
        match self {
            Role::Townfolk => 'Townfolk',
            Role::Werewolf => 'Werewolf',
            Role::FortuneTeller => 'FortuneTeller',
            Role::LittleGirl => 'LittleGirl',
            Role::Witch => 'Witch',
            Role::Thief => 'Thief',
            Role::Hunter => 'Hunter',
            Role::Cupido => 'Cupido',
        }
    }
}

impl RoleIntoU8 of Into<Role, u8> {
    fn into(self: Role) -> u8 {
        match self {
            Role::Townfolk => 0,
            Role::Werewolf => 1,
            Role::FortuneTeller => 2,
            Role::LittleGirl => 3,
            Role::Witch => 4,
            Role::Thief => 5,
            Role::Hunter => 6,
            Role::Cupido => 7,
        }
    }
}

impl RoleIntoU32 of Into<Role, u32> {
    fn into(self: Role) -> u32 {
        match self {
            Role::Townfolk => 0,
            Role::Werewolf => 1,
            Role::FortuneTeller => 2,
            Role::LittleGirl => 3,
            Role::Witch => 4,
            Role::Thief => 5,
            Role::Hunter => 6,
            Role::Cupido => 7,
        }
    }
}

impl U8IntoRole of Into<u8, Role> {
    fn into(self: u8) -> Role {
        let self: u8 = self % 8;
        *RoleTrait::all().at(self.into())
    }
}

// *************************************************************************
//                           Schema Introspections
// *************************************************************************

impl RoleIntrospectionImpl of Introspect<Role> {
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
                name: 'Role',
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
