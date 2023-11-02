mod constants;
mod models {
    mod waiter;
    mod player;
    mod lobby;
    mod game;
    mod role;
}
mod systems {
    mod lobby;
    mod game;
}
mod utils {
    mod random;
    mod settings;
    mod string;
}

// Tests

#[cfg(test)]
mod tests {
    mod models {
        mod test_waiter;
    }
    mod systems {
        mod test_lobby;
    }
}
