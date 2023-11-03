use starknet::ContractAddress;
use dojo::database::schema::{
    Enum, Member, Ty, Struct, SchemaIntrospection, serialize_member, serialize_member_type
};

use werewolves_of_cairo::utils::random::random;

const NBR_OF_ROLES: usize = 8;

#[derive(Copy, Drop, Serde, PartialEq)]
enum Role {
    Townfolk, // 0
    Werewolf, // 1
    FortuneTeller, // 2
    LittleGirl, // 3
    Witch, // 4
    Thief, // 5
    Hunter, // 6
    Cupido, // 7
}

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
}

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

impl U8IntoRole of Into<u8, Role> {
    fn into(self: u8) -> Role {
        let self: u8 = self % 8;
        *RoleTrait::all().at(self.into())
    }
}

impl RoleIntrospectionImpl of SchemaIntrospection<Role> {
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
