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
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::get_block_timestamp;
    use starknet::info::get_tx_info;

    use werewolves_of_cairo::data::compositions::get_comp_for_num_players;
    use werewolves_of_cairo::models::lobby::{Lobby, LobbyTrait};
    use werewolves_of_cairo::models::game::{Game, GameTrait};
    use werewolves_of_cairo::models::waiter::{Waiter, WaiterTrait};
    use werewolves_of_cairo::models::player::{Player, PlayerTrait, PlayerStatus};
    use werewolves_of_cairo::entities::role::{Role, RoleTrait};
    use werewolves_of_cairo::utils::string::assert_valid_string;
    use werewolves_of_cairo::utils::contract_address::assert_address_is_not_zero;

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

            assert_address_is_not_zero(lobby.creator, 'lobby doesnt exists');
            assert(lobby.creator == caller_address, 'insufficient rights');
            assert(lobby.can_start(), 'cant start game');

            let game_id = self.world().uuid();
            let start_time = get_block_timestamp();

            // create the players from the waiters in the lobby
            self._create_players_from_lobby(lobby, game_id);

            // create the game if everything went well
            let game = GameTrait::new(game_id, caller_address, start_time, lobby.num_players);

            // emit game created
            emit!(
                self.world(),
                GameCreated {
                    game_id, creator: caller_address, start_time, num_players: game.num_players
                }
            );

            (game_id, caller_address)
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _create_players_from_lobby(self: @ContractState, lobby: Lobby, game_id: u32) {
            // create & shuffle the roles
            let mut roles: Span<Role> = get_comp_for_num_players(lobby.num_players);
            let mut shuffled_roles: Span<Role> = RoleTrait::shuffle(ref roles);

            // traversal indexes
            let mut waiter_index: u32 = 0;
            let mut player_index: u32 = 0;

            // create players for each waiters for the game
            loop {
                // Quit loop if all waiters have been traversed
                if (waiter_index >= lobby.waiter_next_id) {
                    break;
                }

                // Check next waiter
                let mut waiter = get!(self.world(), (lobby.lobby_id, waiter_index), Waiter);
                assert_address_is_not_zero(waiter.waiter_id, 'waiter should have addr');

                // If this waiter is no longer in the lobby; ignore
                if (!waiter.is_waiting) {
                    waiter_index += 1;
                    continue;
                }

                // Create the player from the active waiter
                let player_role = shuffled_roles.pop_front().expect('role shouldnt be None');
                let player_from_waiter = PlayerTrait::new(
                    game_id, player_index, waiter.waiter_id, *player_role
                );
                waiter.is_waiting = false;
                set!(self.world(), (player_from_waiter, waiter));
                waiter_index += 1;
                player_index += 1;
            };
        }
    }
}
