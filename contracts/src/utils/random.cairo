fn get_seed() -> felt252 {
    starknet::get_tx_info().unbox().transaction_hash
}

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

fn shuffle<T, +Drop<T>, +Copy<T>>(ref s: Span<T>) -> Span<T> {
    let mut randomizer: Randomizer = RandomizerTrait::new();
    let mut shuffled: Array<T> = array![];
    loop {
        if (s.len() <= 0) {
            break;
        }

        let is_back: bool = randomizer.random(0, 2).into();
        let item = if is_back {
            s.pop_back().unwrap()
        } else {
            s.pop_front().unwrap()
        };
        shuffled.append(*item);
    };
    shuffled.span()
}

impl U128IntoBool of Into<u128, bool> {
    fn into(self: u128) -> bool {
        self > 0
    }
}
