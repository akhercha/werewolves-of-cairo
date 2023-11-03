use starknet::{ContractAddress, contract_address_const};

fn assert_address_is_not_zero(addr: ContractAddress, err_msg: felt252) {
    assert(addr != contract_address_const::<0>(), err_msg);
}
