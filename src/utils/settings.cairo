#[derive(Copy, Drop, Serde)]
struct LobbySettings {
    min_players: usize,
    max_players: usize,
}

trait SettingsTrait<T> {
    fn get() -> T;
}

impl LobbySettingsImpl of SettingsTrait<LobbySettings> {
    fn get() -> LobbySettings {
        let lobby_settings = LobbySettings { min_players: 2, max_players: 12 };
        lobby_settings
    }
}
