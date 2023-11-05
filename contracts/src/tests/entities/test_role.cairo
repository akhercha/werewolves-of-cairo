use werewolves_of_cairo::entities::role::{Role, RoleTrait, NBR_OF_ROLES};
use werewolves_of_cairo::data::compositions::eight_players_comp;
// *************************************************************************
//                           Tests implementation
// *************************************************************************

#[test]
#[available_gas(300000000)]
fn test_all() {
    assert(RoleTrait::all().len() == NBR_OF_ROLES, 'len of all roles invalid');
}

#[test]
#[available_gas(300000000)]
fn test_random_role() {
    let random_role: u32 = RoleTrait::random().into();
    assert(random_role >= 0 && random_role < NBR_OF_ROLES, 'should be in range');

    let random_role: u32 = RoleTrait::random().into();
    assert(random_role >= 0 && random_role < NBR_OF_ROLES, 'should be in range');

    let random_role: u32 = RoleTrait::random().into();
    assert(random_role >= 0 && random_role < NBR_OF_ROLES, 'should be in range');

    let random_role: u32 = RoleTrait::random().into();
    assert(random_role >= 0 && random_role < NBR_OF_ROLES, 'should be in range');

    let random_role: u32 = RoleTrait::random().into();
    assert(random_role >= 0 && random_role < NBR_OF_ROLES, 'should be in range');

    let random_role: u32 = RoleTrait::random().into();
    assert(random_role >= 0 && random_role < NBR_OF_ROLES, 'should be in range');

    let random_role: u32 = RoleTrait::random().into();
    assert(random_role >= 0 && random_role < NBR_OF_ROLES, 'should be in range');

    let random_role: u32 = RoleTrait::random().into();
    assert(random_role >= 0 && random_role < NBR_OF_ROLES, 'should be in range');

    let random_role: u32 = RoleTrait::random().into();
    assert(random_role >= 0 && random_role < NBR_OF_ROLES, 'should be in range');
}
