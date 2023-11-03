use starknet::{ContractAddress, contract_address_const};
use dojo::database::schema::{
    Enum, Member, Ty, Struct, SchemaIntrospection, serialize_member, serialize_member_type
};

/// In game possible actions for player depending on its role
#[derive(Copy, Drop, Serde, PartialEq)]
struct PlayerActions {
    /// [Wolf]
    /// Vote for the person to eat
    wolf_vote: Vote,
    /// [Townfolk]
    /// Vote for the person to execute
    townfolk_vote: Vote,
    /// [LittleGirl]
    /// If true, the little girl spies some random messages
    /// from wolves chat, but she takes the risk of being eaten
    littlegirl_spies: bool,
    /// [Thief]
    /// At the start of the game, the thief can choose to swap
    /// his card with someone else
    thief_vote: Vote,
    /// [FortuneTeller]
    /// Every turn, the fortune teller can spy on someone and reveal his role
    fortuneteller_vote: Vote,
    /// [Cupido]
    /// At the start of the game, Cupido choose 2 persons
    /// that will be in love. If one person dies, the other dies too.
    cupido_vote: CupidoVote,
    /// [Witch]
    /// When someone is supposed to be announced killed in the morning,
    /// the witcher can either save this person or kill someone else.
    witch_vote: WitchVote,
}

#[derive(Copy, Drop, Serde, PartialEq)]
enum Vote {
    None,
    Target: ContractAddress
}

#[derive(Copy, Drop, Serde, PartialEq)]
enum CupidoVote {
    None,
    Target: (ContractAddress, ContractAddress)
}

#[derive(Copy, Drop, Serde, PartialEq)]
enum WitchVote {
    None,
    Kill: ContractAddress,
    Save: ContractAddress
}

// *************************************************************************
//                              Implementation
// *************************************************************************

impl DefaultPlayerActions of Default<PlayerActions> {
    fn default() -> PlayerActions {
        PlayerActions {
            wolf_vote: Vote::None,
            townfolk_vote: Vote::None,
            littlegirl_spies: false,
            thief_vote: Vote::None,
            fortuneteller_vote: Vote::None,
            cupido_vote: CupidoVote::None,
            witch_vote: WitchVote::None
        }
    }
}


// *************************************************************************
//                           Schema Introspections
// *************************************************************************

impl PlayerActionsIntrospectionImpl of SchemaIntrospection<PlayerActions> {
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
                name: 'PlayerActions',
                attrs: array![].span(),
                children: array![
                    ('wolf_vote', serialize_member_type(@Ty::Tuple(array![].span()))),
                    ('townfolk_vote', serialize_member_type(@Ty::Tuple(array![].span()))),
                    ('littlegirl_spying', serialize_member_type(@Ty::Tuple(array![].span()))),
                    ('thief_vote', serialize_member_type(@Ty::Tuple(array![].span()))),
                    ('fortuneteller_vote', serialize_member_type(@Ty::Tuple(array![].span()))),
                    ('cupido_vote', serialize_member_type(@Ty::Tuple(array![].span()))),
                    ('witch_vote', serialize_member_type(@Ty::Tuple(array![].span()))),
                ]
                    .span()
            }
        )
    }
}
