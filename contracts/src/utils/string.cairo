fn assert_valid_string(name: felt252) {
    let name_256: u256 = name.into();
    assert(name_256 > 0xffff, 'Name too short');
    assert(name_256 < 0xffffffffffffffffffffffffffffffffffffffff, 'Name too long');
}
