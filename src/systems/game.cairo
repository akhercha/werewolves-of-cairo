use starknet::ContractAddress;

// *************************************************************************
//                                Interface
// *************************************************************************

#[starknet::interface]
trait IGame<TContractState> {
    // Create a game from a lobby id
    fn create_game(self: @TContractState, lobby_id: u32) -> (u32, ContractAddress);
}

// *************************************************************************
//                           Contract Implementation
// *************************************************************************

#[dojo::contract]
mod lobby {
    use starknet::{ContractAddress, contract_address_const};
    use starknet::get_caller_address;
    use starknet::get_block_timestamp;
    use starknet::info::get_tx_info;

    use werewolves_of_cairo::models::lobby::{Lobby, LobbyTrait};
    use werewolves_of_cairo::models::game::{Game, GameTrait};
    use werewolves_of_cairo::models::waiter::{Waiter, WaiterTrait};
    use werewolves_of_cairo::models::player::{Player, PlayerTrait, PlayerStatus};
    use werewolves_of_cairo::models::role::{RoleEnum};
    use werewolves_of_cairo::utils::string::assert_valid_string;

    use super::IGame;

    #[starknet::interface]
    trait ISystem<TContractState> {
        fn world(self: @TContractState) -> IWorldDispatcher;
    }

    impl ISystemImpl of ISystem<ContractState> {
        fn world(self: @ContractState) -> IWorldDispatcher {
            self.world_dispatcher.read()
        }
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        GameCreated: GameCreated,
    }

    #[derive(Drop, starknet::Event)]
    struct GameCreated {
        game_id: u32,
        creator: ContractAddress,
        start_time: u64,
        num_players: usize,
    }

    #[external(v0)]
    impl GameImpl of IGame<ContractState> {
        fn create_game(self: @ContractState, lobby_id: u32) -> (u32, ContractAddress) {
            let caller_address = get_caller_address();
            let lobby = get!(self.world(), lobby_id, Lobby);

            assert(lobby.creator != contract_address_const::<0>(), 'lobby doesnt exists');
            assert(lobby.creator == caller_address, 'insufficient rights');
            assert(lobby.can_start(), 'cant start game');

            let game_id = self.world().uuid();
            let start_time = get_block_timestamp();

            // create players for each waiters for the game
            let mut waiter_idx: u32 = 0;
            loop {
                if (waiter_idx >= lobby.waiter_next_id) {
                    break;
                }
                let waiter = get!(self.world(), (lobby.lobby_id, waiter_idx), Waiter);
                assert(
                    waiter.waiter_id != contract_address_const::<0>(), 'waiter should have addr'
                );

                let player_from_waiter = PlayerTrait::new(game_id, waiter.waiter_id);
                set!(self.world(), (player_from_waiter));
                waiter_idx += 1;
            };

            // create the game if everything went well
            let game = GameTrait::new(game_id, caller_address, start_time, lobby.num_players);

            // emit game created
            emit!(
                self.world(),
                GameCreated {
                    game_id, creator: caller_address, start_time, num_players: lobby.num_players
                }
            );

            (game_id, caller_address)
        }
    }
    #[generate_trait]
    impl InternalImpl of InternalTrait {}
}
