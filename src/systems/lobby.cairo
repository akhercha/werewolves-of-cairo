use starknet::ContractAddress;

use werewolves_of_cairo::models::lobby::Lobby;

// *************************************************************************
//                                Interface
// *************************************************************************

#[starknet::interface]
trait ILobby<TContractState> {
    // Create a new lobby
    fn create_lobby(self: @TContractState, lobby_name: felt252) -> (u32, ContractAddress);

    // Create a game from a lobby
    fn create_game(self: @TContractState, lobby_id: u32) -> (u32, ContractAddress);

    // Join a lobby
    fn join_lobby(self: @TContractState, lobby_id: u32) -> (u32, ContractAddress);

    // Leave a lobby
    fn leave_lobby(self: @TContractState, lobby_id: u32) -> (u32, ContractAddress);

    // Opens a lobby
    fn open_lobby(self: @TContractState, lobby_id: u32) -> (u32, ContractAddress);

    // Close a lobby
    fn close_lobby(self: @TContractState, lobby_id: u32) -> (u32, ContractAddress);
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
    use werewolves_of_cairo::models::lobby::{Game, GameTrait};
    use werewolves_of_cairo::models::waiter::{Waiter, WaiterTrait};
    use werewolves_of_cairo::models::player::{Player, PlayerTrait, PlayerStatus, PlayerRole};
    use werewolves_of_cairo::utils::string::assert_valid_string;

    use super::ILobby;

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
        LobbyCreated: LobbyCreated,
        LobbyOpened: LobbyOpened,
        LobbyClosed: LobbyClosed,
        PlayerJoinedLobby: PlayerJoinedLobby,
        PlayerLeftLobby: PlayerLeftLobby,
        GameCreated: GameCreated,
    }

    #[derive(Drop, starknet::Event)]
    struct LobbyCreated {
        lobby_id: u32,
        creator: ContractAddress,
        name: felt252,
        min_players: usize,
        max_players: usize,
    }

    #[derive(Drop, starknet::Event)]
    struct LobbyOpened {
        lobby_id: u32
    }

    #[derive(Drop, starknet::Event)]
    struct LobbyClosed {
        lobby_id: u32
    }

    #[derive(Drop, starknet::Event)]
    struct PlayerJoinedLobby {
        lobby_id: u32,
        player_id: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct PlayerLeftLobby {
        lobby_id: u32,
        player_id: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct GameCreated {
        game_id: u32,
        creator: ContractAddress,
        start_time: u64,
        num_players: usize,
    }

    #[external(v0)]
    impl LobbyImpl of ILobby<ContractState> {
        fn create_lobby(self: @TContractState, lobby_name: felt252) -> (u32, ContractAddress) {
            assert_valid_name(lobby_name);

            let caller_address = get_caller_address();
            let lobby_id: u32 = self.world().uuid();

            let creator = WaiterTrait::new(lobby_id, 0, caller_address);
            let lobby = LobbyTrait::new(lobby_id, caller_address, lobby_name);

            set!(self.world(), (lobby, creator));

            // emit lobby created + player joined lobby
            emit!(
                self.world(),
                LobbyCreated {
                    lobby_id: lobby_id,
                    creator: caller_address,
                    name: lobby_name,
                    min_players: lobby.min_players,
                    max_players: lobby.max_players
                }
            );
            emit!(self.world(), PlayerJoinedLobby { lobby_id, player_id: caller_address });

            (lobby_id, caller_address)
        }

        fn create_game(self: @TContractState, lobby_id: u32) -> (u32, ContractAddress) {
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
                set!(self.world(), player_from_waiter);
                waiter_idx += 1;
            }

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

        fn join_lobby(self: @TContractState, lobby_id: u32) -> (u32, ContractAddress) {
            let caller_address = get_caller_address();

            let mut lobby = get!(self.world(), lobby_id, Lobby);
            assert(lobby.creator != contract_address_const::<0>(), 'lobby doesnt exists');
            assert(lobby.creator != caller_address, 'creator cant join lobby');
            assert(lobby.is_open, 'lobby isnt open');
            assert(lobby.num_players < lobby.max_players, 'lobby is full');
            let (is_in_lobby, _) = self._is_in_lobby(caller_address, lobby);
            assert(!is_in_lobby, 'caller already in lobby');

            let waiter_id = lobby.waiter_next_id;
            let new_waiter = WaiterTrait::new(lobby_id, waiter_id, caller_address);
            lobby.waiter_next_id = waiter_id + 1;
            lobby.num_players = lobby.num_players + 1;

            set!(self.world(), (lobby, new_waiter));
            emit!(self.world(), PlayerJoinedLobby { lobby_id, player_id: caller_address });
        }

        fn leave_lobby(self: @TContractState, lobby_id: u32) -> (u32, ContractAddress) {
            let caller_address = get_caller_address();

            let mut lobby = get!(self.world(), lobby_id, Lobby);
            assert(lobby.creator != contract_address_const::<0>(), 'lobby doesnt exists');
            assert(lobby.creator != caller_address, 'creator cant leave lobby');
            let (is_in_lobby, waiter) = self._is_in_lobby(caller_address, lobby);
            assert(is_in_lobby, 'caller not in lobby');

            let mut waiter = waiter.unwrap();
            waiter.has_left_lobby = true;
            lobby.num_players = lobby.num_players - 1;

            set!(self.world(), (lobby, waiter));
            emit!(self.world(), PlayerLeftLobby { lobby_id, player_id: caller_address });
        }

        fn open_lobby(self: @TContractState, lobby_id: u32) -> (u32, ContractAddress) {
            let caller_address = get_caller_address();

            let mut lobby = get!(self.world(), lobby_id, Lobby);
            assert(lobby.creator != contract_address_const::<0>(), 'lobby doesnt exists');
            assert(lobby.creator == caller_address, 'insufficient rights');
            assert(!lobby.is_open, 'lobby is already open');

            lobby.is_open = true;
            set!(self.world(), (lobby));
            emit!(self.world(), LobbyOpened { lobby_id });
        }

        fn close_lobby(self: @TContractState, lobby_id: u32) -> (u32, ContractAddress) {
            let caller_address = get_caller_address();

            let mut lobby = get!(self.world(), lobby_id, Lobby);
            assert(lobby.creator != contract_address_const::<0>(), 'lobby doesnt exists');
            assert(lobby.creator == caller_address, 'insufficient rights');
            assert(lobby.is_open, 'lobby is already closed');

            lobby.is_open = false;
            set!(self.world(), (lobby));
            emit!(self.world(), LobbyOpened { lobby_id });
        }

        #[generate_trait]
        impl InternalImpl of InternalTrait {
            fn _is_in_lobby(
                ref self: TContractState, caller: ContractAddress, lobby: Lobby
            ) -> (bool, Option<Waiter>) {
                let lobby_id: usize = lobby.lobby_id;
                let max_waiter_id: usize = lobby.waiter_next_id;

                let mut waiter_idx: u32 = 1;
                loop {
                    if (waiter_idx >= max_waiter_id) {
                        break;
                    }
                    let waiter = get!(self.world(), (lobby_id, waiter_idx), Waiter);
                    assert(
                        waiter.waiter_id != contract_address_const::<0>(), 'waiter should have addr'
                    );
                    if (!waiter.has_left_lobby() && waiter.waiter_id == caller) {
                        return (true, Option::Some(waiter));
                    }
                    waiter_idx += 1;
                }
                return (false, Option::None(()));
            }
        }
    }
}
