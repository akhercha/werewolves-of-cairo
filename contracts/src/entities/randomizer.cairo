use werewolves_of_cairo::utils::random::get_seed;

// TODO: implement proper pseudo random number generator
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

    fn random(ref self: Randomizer, min: u128, max: u128) -> u128 {
        if min >= max {
            panic_with_felt252('min >= max');
        };
        let seed = get_seed();
        let seed = pedersen::pedersen(seed, self.nonce);
        let seed: u256 = seed.into();
        self.nonce += 1;
        let range = max - min;

        (seed.low % range) + min
    }

    fn random_by_seed(ref self: Randomizer, seed: felt252, min: u128, max: u128) -> u128 {
        if min >= max {
            panic_with_felt252('min >= max');
        };

        let seed = pedersen::pedersen(seed, self.nonce);
        let seed: u256 = seed.into();
        self.nonce += 1;
        let range = max - min;

        (seed.low % range) + min
    }
}
