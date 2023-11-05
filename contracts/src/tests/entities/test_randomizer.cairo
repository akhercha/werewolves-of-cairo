use werewolves_of_cairo::entities::randomizer::{Randomizer, RandomizerTrait};

// *************************************************************************
//                           Tests implementation
// *************************************************************************

#[test]
#[available_gas(300000000)]
fn test_randomizer_init() {
    let randomizer = RandomizerTrait::new();
    assert(randomizer.nonce == 0, 'should be 0');

    let randomizer = RandomizerTrait::new_with_nonce(420);
    assert(randomizer.nonce == 420, 'should be 420');
}

#[test]
#[available_gas(300000000)]
fn test_randomizer_random() {
    let mut randomizer = RandomizerTrait::new();

    let min: u128 = 2;
    let max: u128 = 6;

    assert_is_in_range(randomizer.random(min, max), min, max);
    assert_is_in_range(randomizer.random(min, max), min, max);
    assert_is_in_range(randomizer.random(min, max), min, max);
    assert_is_in_range(randomizer.random(min, max), min, max);
    assert_is_in_range(randomizer.random(min, max), min, max);
    assert_is_in_range(randomizer.random(min, max), min, max);
    assert_is_in_range(randomizer.random(min, max), min, max);
    assert_is_in_range(randomizer.random(min, max), min, max);
    assert_is_in_range(randomizer.random(min, max), min, max);
    assert_is_in_range(randomizer.random(min, max), min, max);
    assert_is_in_range(randomizer.random(min, max), min, max);
}

#[test]
#[available_gas(300000000)]
fn test_randomizer_random_by_seed() {
    let mut randomizer = RandomizerTrait::new();

    let min: u128 = 2;
    let max: u128 = 6;

    assert_is_in_range(randomizer.random_by_seed('a', min, max), min, max);
    assert_is_in_range(randomizer.random_by_seed('b', min, max), min, max);
    assert_is_in_range(randomizer.random_by_seed('c', min, max), min, max);
    assert_is_in_range(randomizer.random_by_seed('d', min, max), min, max);
    assert_is_in_range(randomizer.random_by_seed('e', min, max), min, max);
    assert_is_in_range(randomizer.random_by_seed('f', min, max), min, max);
    assert_is_in_range(randomizer.random_by_seed('g', min, max), min, max);
    assert_is_in_range(randomizer.random_by_seed('h', min, max), min, max);
    assert_is_in_range(randomizer.random_by_seed('i', min, max), min, max);
    assert_is_in_range(randomizer.random_by_seed('j', min, max), min, max);
    assert_is_in_range(randomizer.random_by_seed('k', min, max), min, max);
}

#[test]
#[available_gas(300000000)]
#[should_panic(expected: ('min >= max',))]
fn test_randomizer_random_min_superior_max() {
    let mut randomizer = RandomizerTrait::new();
    let min: u128 = 10;
    let max: u128 = 9;
    randomizer.random(min, max);
}

// *************************************************************************
//                                Utilities
// *************************************************************************

fn assert_is_in_range(nb: u128, min: u128, max: u128) {
    assert((nb >= min) && (nb <= max), 'nb not in range');
}
