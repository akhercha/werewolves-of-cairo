use starknet::ContractAddress;
use dojo::database::schema::{
    Enum, Member, Ty, Struct, SchemaIntrospection, serialize_member, serialize_member_type
};

use werewolves_of_cairo::utils::random::random;

struct Role {}

#[derive(Copy, Drop, Serde, PartialEq)]
enum RoleEnum {
    Townfolk, // 0
    Werewolf, // 1
    FortuneTeller, // 2
    LittleGirl, // 3
    Witch, // 4
    Thief, // 5
    Hunter, // 6
    Cupido, // 7
}

impl RoleEnumIntoFelt252 of Into<RoleEnum, felt252> {
    fn into(self: RoleEnum) -> felt252 {
        match self {
            RoleEnum::Townfolk => 'Townfolk',
            RoleEnum::Werewolf => 'Werewolf',
            RoleEnum::FortuneTeller => 'FortuneTeller',
            RoleEnum::LittleGirl => 'LittleGirl',
            RoleEnum::Witch => 'Witch',
            RoleEnum::Thief => 'Thief',
            RoleEnum::Hunter => 'Hunter',
            RoleEnum::Cupido => 'Cupido',
        }
    }
}

impl RoleEnumIntoU8 of Into<RoleEnum, u8> {
    fn into(self: RoleEnum) -> u8 {
        match self {
            RoleEnum::Townfolk => 0,
            RoleEnum::Werewolf => 1,
            RoleEnum::FortuneTeller => 2,
            RoleEnum::LittleGirl => 3,
            RoleEnum::Witch => 4,
            RoleEnum::Thief => 5,
            RoleEnum::Hunter => 6,
            RoleEnum::Cupido => 7,
        }
    }
}

impl U8IntoRoleEnum of Into<u8, RoleEnum> {
    fn into(self: u8) -> RoleEnum {
        let self: u8 = self % 8;
        *RoleTrait::all().at(self.into())
    }
}

impl RoleEnumIntrospectionImpl of SchemaIntrospection<RoleEnum> {
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
                name: 'RoleEnum',
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


#[generate_trait]
impl RoleImpl of RoleTrait {
    fn all() -> Span<RoleEnum> {
        array![
            RoleEnum::Townfolk,
            RoleEnum::Werewolf,
            RoleEnum::FortuneTeller,
            RoleEnum::LittleGirl,
            RoleEnum::Witch,
            RoleEnum::Thief,
            RoleEnum::Hunter,
            RoleEnum::Cupido,
        ]
            .span()
    }

    fn random() -> RoleEnum {
        let roles = RoleImpl::all();
        let index = random(0, roles.len().into());

        *roles.at(index.try_into().unwrap())
    }
}
