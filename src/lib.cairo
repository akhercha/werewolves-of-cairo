mod constants;
mod data {
    mod compositions;
}
mod entities {
    mod role;
    mod randomizer;
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
    mod lobby;
    mod game;
    mod register;
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
        mod test_randomizer;
        mod test_role;
    }
    mod models {
        mod test_waiter;
    }
    mod systems {
        mod test_lobby;
        mod test_register;
    }
    mod test_utils;
}
