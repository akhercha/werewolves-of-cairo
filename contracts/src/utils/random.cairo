fn get_seed() -> felt252 {
    starknet::get_tx_info().unbox().transaction_hash
}

fn random(min: u128, max: u128) -> u128 {
    if min >= max {
        panic_with_felt252('min >= max');
    };
    let seed = get_seed();
    let nonce = get_seed();
    let seed = pedersen::pedersen(seed, nonce);
    let seed: u256 = seed.into();
    let range = max - min;

    (seed.low % range) + min
}
