use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde)]
struct Game {
    #[key]
    game_id: u32,
    start_time: u64,
    max_players: usize,
    num_players: usize,
    is_finished: bool,
    creator: ContractAddress,
}
