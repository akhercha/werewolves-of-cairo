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
    fn create_game(self: @TContractState, lobby: Lobby) -> (u32, ContractAddress);
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
    use debug::PrintTrait;

    use werewolves_of_cairo::models::lobby::{Lobby, LobbyTrait};
    use werewolves_of_cairo::models::waiter::{Waiter, WaiterTrait};
    use werewolves_of_cairo::models::player::{Player, PlayerStatus, PlayerRole};
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

            let creator = WaiterTrait::new(lobby_id, caller_address);
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
            let lobby = get!(self.world(), (lobby_id, caller_address), Lobby);

            assert(lobby.can_start(), 'lobby cant start game');
        }
    }
}
