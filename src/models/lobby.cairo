use starknet::{ContractAddress, contract_address_const};
use dojo::database::schema::{
    Enum, Member, Ty, Struct, SchemaIntrospection, serialize_member, serialize_member_type
};
use dojo::world::{IWorld, IWorldDispatcher, IWorldDispatcherTrait};

use werewolves_of_cairo::utils::settings::{LobbySettings, LobbySettingsImpl};

// *************************************************************************
//                                     MODEL
// *************************************************************************

#[derive(Model, Copy, Drop, Serde)]
struct Lobby {
    #[key]
    lobby_id: u32,
    creator: ContractAddress,
    name: felt252,
    is_open: bool,
    min_players: usize,
    max_players: usize,
    num_players: usize,
    waiter_next_id: u32
}

// *************************************************************************
//                              Implementation
// *************************************************************************

#[generate_trait]
impl LobbyImpl of LobbyTrait {
    fn new(lobby_id: u32, creator: ContractAddress, lobby_name: felt252) -> Lobby {
        let lobby_settings = LobbySettingsImpl::get();

        Lobby {
            lobby_id,
            creator,
            name: lobby_name,
            is_open: true,
            min_players: lobby_settings.min_players,
            max_players: lobby_settings.max_players,
            num_players: 1,
            waiter_next_id: 1
        }
    }

    fn can_start(self: Lobby) -> bool {
        self.num_players >= self.min_players && self.num_players <= self.max_players
    }
}
