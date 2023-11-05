use starknet::ContractAddress;

use werewolves_of_cairo::models::lobby::Lobby;

// *************************************************************************
//                                Interface
// *************************************************************************

#[starknet::interface]
trait ILobby<TContractState> {
    // Create a new lobby
    fn create_lobby(self: @TContractState, lobby_name: felt252) -> (u32, ContractAddress);

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
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::get_block_timestamp;
    use starknet::info::get_tx_info;

    use werewolves_of_cairo::models::lobby::{Lobby, LobbyTrait};
    use werewolves_of_cairo::models::game::{Game, GameTrait};
    use werewolves_of_cairo::models::waiter::{Waiter, WaiterTrait};
    use werewolves_of_cairo::models::player::{Player, PlayerTrait};
    use werewolves_of_cairo::models::profile::{Profile, ProfileTrait};
    use werewolves_of_cairo::utils::string::assert_valid_string;
    use werewolves_of_cairo::utils::contract_address::assert_address_is_not_zero;

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
        player_address: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct PlayerLeftLobby {
        lobby_id: u32,
        player_address: ContractAddress,
    }

    #[external(v0)]
    impl LobbyImpl of ILobby<ContractState> {
        fn create_lobby(self: @ContractState, lobby_name: felt252) -> (u32, ContractAddress) {
            assert_valid_string(lobby_name);

            let caller_address = get_caller_address();
            self._assert_caller_has_profile(caller_address);

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
            emit!(self.world(), PlayerJoinedLobby { lobby_id, player_address: caller_address });

            (lobby_id, caller_address)
        }

        fn join_lobby(self: @ContractState, lobby_id: u32) -> (u32, ContractAddress) {
            let caller_address = get_caller_address();
            self._assert_caller_has_profile(caller_address);

            let mut lobby = get!(self.world(), lobby_id, Lobby);
            assert_address_is_not_zero(lobby.creator, 'lobby doesnt exists');
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
            emit!(self.world(), PlayerJoinedLobby { lobby_id, player_address: caller_address });
            (lobby_id, caller_address)
        }

        fn leave_lobby(self: @ContractState, lobby_id: u32) -> (u32, ContractAddress) {
            let caller_address = get_caller_address();
            self._assert_caller_has_profile(caller_address);

            let mut lobby = get!(self.world(), lobby_id, Lobby);
            assert_address_is_not_zero(lobby.creator, 'lobby doesnt exists');
            assert(lobby.creator != caller_address, 'creator cant leave lobby');
            let (is_in_lobby, waiter) = self._is_in_lobby(caller_address, lobby);
            assert(is_in_lobby, 'caller not in lobby');

            let mut waiter = waiter.unwrap();
            waiter.is_waiting = false;
            lobby.num_players = lobby.num_players - 1;

            set!(self.world(), (lobby, waiter));
            emit!(self.world(), PlayerLeftLobby { lobby_id, player_address: caller_address });
            (lobby_id, caller_address)
        }

        fn open_lobby(self: @ContractState, lobby_id: u32) -> (u32, ContractAddress) {
            let caller_address = get_caller_address();
            self._assert_caller_has_profile(caller_address);

            let mut lobby = get!(self.world(), lobby_id, Lobby);
            assert_address_is_not_zero(lobby.creator, 'lobby doesnt exists');
            assert(lobby.creator == caller_address, 'insufficient rights');
            assert(!lobby.is_open, 'lobby is already open');

            lobby.is_open = true;
            set!(self.world(), (lobby));
            emit!(self.world(), LobbyOpened { lobby_id });
            (lobby_id, caller_address)
        }

        fn close_lobby(self: @ContractState, lobby_id: u32) -> (u32, ContractAddress) {
            let caller_address = get_caller_address();
            self._assert_caller_has_profile(caller_address);

            let mut lobby = get!(self.world(), lobby_id, Lobby);
            assert_address_is_not_zero(lobby.creator, 'lobby doesnt exists');
            assert(lobby.creator == caller_address, 'insufficient rights');
            assert(lobby.is_open, 'lobby is already closed');

            lobby.is_open = false;
            set!(self.world(), (lobby));
            emit!(self.world(), LobbyOpened { lobby_id });
            (lobby_id, caller_address)
        }
    }
    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _is_in_lobby(
            self: @ContractState, caller: ContractAddress, lobby: Lobby
        ) -> (bool, Option<Waiter>) {
            let lobby_id: usize = lobby.lobby_id;
            let max_waiter_id: usize = lobby.waiter_next_id;

            let mut found_waiter: bool = false;
            let mut waiter_option: Option = Option::None(());

            let mut waiter_index: u32 = 1;
            loop {
                if (waiter_index >= max_waiter_id) {
                    break;
                }
                let waiter = get!(self.world(), (lobby_id, waiter_index), Waiter);
                assert_address_is_not_zero(waiter.waiter_id, 'waiter should have addr');
                if (waiter.is_waiting && waiter.waiter_id == caller) {
                    found_waiter = true;
                    waiter_option = Option::Some(waiter);
                }
                waiter_index += 1;
            };
            return (found_waiter, waiter_option);
        }

        fn _assert_caller_has_profile(self: @ContractState, caller_address: ContractAddress) {
            let profile: Profile = get!(self.world(), caller_address, Profile);
            assert(profile.user_name != 0, 'caller have no profile');
        }
    }
}
