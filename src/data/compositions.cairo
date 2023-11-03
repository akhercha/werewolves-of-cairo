// TODO: make this configurable or add multiple choices

use werewolves_of_cairo::entities::role::Role;
use werewolves_of_cairo::utils::settings::{LobbySettings, LobbySettingsImpl};

fn get_comp_for_num_players(num_players: usize) -> Span<Role> {
    let lobby_settings = LobbySettingsImpl::get();
    assert(
        num_players >= lobby_settings.min_players && num_players <= lobby_settings.max_players,
        'invalid nb of players'
    );
    let empty_span: Span<Role> = array![].span();
    let possible_comps: Array<Span<Role>> = array![
        empty_span,
        empty_span,
        empty_span,
        three_players_comp(),
        four_players_comp(),
        five_players_comp(),
        six_players_comp(),
        seven_players_comp(),
        eight_players_comp(),
        nine_players_comp(),
        ten_players_comp(),
        eleven_players_comp(),
        twelve_players_comp(),
    ];

    *possible_comps.at(num_players)
}

fn three_players_comp() -> Span<Role> {
    array![Role::Townfolk, Role::Townfolk, Role::Werewolf].span()
}

fn four_players_comp() -> Span<Role> {
    array![Role::Townfolk, Role::Townfolk, Role::Werewolf, Role::FortuneTeller].span()
}

fn five_players_comp() -> Span<Role> {
    array![Role::Townfolk, Role::Townfolk, Role::Werewolf, Role::FortuneTeller, Role::Hunter].span()
}

fn six_players_comp() -> Span<Role> {
    array![
        Role::Townfolk,
        Role::Townfolk,
        Role::Werewolf,
        Role::Werewolf,
        Role::FortuneTeller,
        Role::Witch
    ]
        .span()
}

fn seven_players_comp() -> Span<Role> {
    array![
        Role::Townfolk,
        Role::Townfolk,
        Role::Werewolf,
        Role::Werewolf,
        Role::FortuneTeller,
        Role::Witch,
        Role::Hunter
    ]
        .span()
}

fn eight_players_comp() -> Span<Role> {
    array![
        Role::Townfolk,
        Role::Townfolk,
        Role::Werewolf,
        Role::Werewolf,
        Role::FortuneTeller,
        Role::Witch,
        Role::Hunter,
        Role::LittleGirl,
    ]
        .span()
}

fn nine_players_comp() -> Span<Role> {
    array![
        Role::Townfolk,
        Role::Townfolk,
        Role::Werewolf,
        Role::Werewolf,
        Role::Werewolf,
        Role::FortuneTeller,
        Role::Witch,
        Role::Hunter,
        Role::Cupido,
    ]
        .span()
}

fn ten_players_comp() -> Span<Role> {
    array![
        Role::Townfolk,
        Role::Townfolk,
        Role::Townfolk,
        Role::Werewolf,
        Role::Werewolf,
        Role::Werewolf,
        Role::FortuneTeller,
        Role::Witch,
        Role::Hunter,
        Role::Thief,
    ]
        .span()
}

fn eleven_players_comp() -> Span<Role> {
    array![
        Role::Townfolk,
        Role::Townfolk,
        Role::Townfolk,
        Role::Werewolf,
        Role::Werewolf,
        Role::Werewolf,
        Role::FortuneTeller,
        Role::Witch,
        Role::Hunter,
        Role::Thief,
        Role::LittleGirl
    ]
        .span()
}

fn twelve_players_comp() -> Span<Role> {
    array![
        Role::Townfolk,
        Role::Townfolk,
        Role::Townfolk,
        Role::Werewolf,
        Role::Werewolf,
        Role::Werewolf,
        Role::Werewolf,
        Role::FortuneTeller,
        Role::Witch,
        Role::Hunter,
        Role::Thief,
        Role::Cupido
    ]
        .span()
}
