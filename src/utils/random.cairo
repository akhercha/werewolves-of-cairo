#[derive(Drop)]
struct Randomizer {
    nonce: felt252
}

#[generate_trait]
impl RandomizerImpl of RandomizerTrait {
    fn new() -> Randomizer {
        Randomizer { nonce: 0 }
    }

    fn new_with_nonce(nonce: felt252) -> Randomizer {
        Randomizer { nonce }
    }

    // TODO: implement proper pseudo random number generator
    fn random_by_seed(ref self: Randomizer, seed: felt252, min: u128, max: u128) -> u128 {
        if min >= max {
            panic_with_felt252('min >= max');
        };

        let seed = pedersen::pedersen(seed, self.nonce);
        let seed: u256 = seed.into();
        self.nonce += 1;
        let range = max + 1 - min;

        (seed.low % range) + min
    }

    // TODO: implement proper pseudo random number generator
    fn random(ref self: Randomizer, min: u128, max: u128) -> u128 {
        if min >= max {
            panic_with_felt252('min >= max');
        };
        let seed = get_seed();
        let seed = pedersen::pedersen(seed, self.nonce);
        let seed: u256 = seed.into();
        self.nonce += 1;
        let range = max + 1 - min;

        (seed.low % range) + min
    }

    fn quick_random(min: u128, max: u128) -> u128 {
        if min >= max {
            panic_with_felt252('min >= max');
        };
        let seed = get_seed();
        let nonce = get_seed();
        let seed = pedersen::pedersen(seed, nonce);
        let seed: u256 = seed.into();
        let range = max + 1 - min;

        (seed.low % range) + min
    }
}

fn get_seed() -> felt252 {
    starknet::get_tx_info().unbox().transaction_hash
}
