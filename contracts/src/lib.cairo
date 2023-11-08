mod data {
    mod compositions;
}
mod entities {
    mod role;
    mod player_actions;
}
mod models {
    mod profile;
    mod waiter;
    mod player;
    mod lobby;
    mod game;
}
mod systems {
    mod lobbies;
    mod games;
    mod profiles;
}
mod utils {
    mod random;
    mod settings;
    mod string;
    mod contract_address;
}

// Tests

#[cfg(test)]
mod tests {
    mod entities {
        mod test_role;
    }
    mod models {
        mod test_waiter;
    }
    mod systems {
        mod test_lobbies;
        mod test_profiles;
    }
    mod test_utils;
}
