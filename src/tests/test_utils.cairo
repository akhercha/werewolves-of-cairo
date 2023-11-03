use werewolves_of_cairo::utils::random::random;

// *************************************************************************
//                           Tests implementation
// *************************************************************************

#[test]
#[available_gas(300000000)]
fn test_random() {
    let min: u128 = 2;
    let max: u128 = 6;

    assert_is_in_range(random(min, max), min, max);
    assert_is_in_range(random(min, max), min, max);
    assert_is_in_range(random(min, max), min, max);
    assert_is_in_range(random(min, max), min, max);
    assert_is_in_range(random(min, max), min, max);
    assert_is_in_range(random(min, max), min, max);
    assert_is_in_range(random(min, max), min, max);
    assert_is_in_range(random(min, max), min, max);
    assert_is_in_range(random(min, max), min, max);
    assert_is_in_range(random(min, max), min, max);
    assert_is_in_range(random(min, max), min, max);
}

#[test]
#[available_gas(300000000)]
#[should_panic(expected: ('min >= max',))]
fn test_quick_random_min_superior_max() {
    random(min: 10, max: 9);
}


// *************************************************************************
//                                Utilities
// *************************************************************************

fn assert_is_in_range(nb: u128, min: u128, max: u128) {
    assert((nb >= min) && (nb <= max), 'nb not in range');
}
