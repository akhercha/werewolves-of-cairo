use starknet::ContractAddress;

// *************************************************************************
//                                Interface
// *************************************************************************

#[starknet::interface]
trait IProfile<TContractState> {
    // Register a new profile
    fn register(self: @TContractState, user_name: felt252) -> (ContractAddress, felt252);
}

// *************************************************************************
//                           Contract Implementation
// *************************************************************************

#[dojo::contract]
mod profile {
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use starknet::info::get_tx_info;

    use werewolves_of_cairo::models::profile::{Profile, ProfileTrait};
    use werewolves_of_cairo::utils::string::assert_valid_string;

    use super::IProfile;

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
        ProfileRegistered: ProfileRegistered,
    }

    #[derive(Drop, starknet::Event)]
    struct ProfileRegistered {
        user_id: ContractAddress,
        name: felt252,
    }

    #[external(v0)]
    impl LobbyImpl of IProfile<ContractState> {
        fn register(self: @ContractState, user_name: felt252) -> (ContractAddress, felt252) {
            let caller: ContractAddress = get_caller_address();

            // Check if the caller does not have a profile already
            let maybe_existing_profile: Profile = get!(self.world(), caller, Profile);
            assert(maybe_existing_profile.user_name == 0, 'profile already exists');

            // Check if the user_name is a valid string
            assert_valid_string(user_name);

            // Create a new Profile
            let new_profile: Profile = ProfileTrait::new(caller, user_name);
            set!(self.world(), (new_profile));
            emit!(self.world(), ProfileRegistered { user_id: caller, name: user_name });
            return (caller, user_name);
        }
    }
}
