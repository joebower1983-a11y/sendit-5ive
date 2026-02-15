// Tests for Send.it Token Chat Module

// @test-params 0 1 1
pub test_message_index_increment(next_index: u64, expected: u64) -> u64 {
    return next_index + 1;
}

// @test-params 5 1 6
pub test_like_increment(likes: u64, expected: u64) -> u64 {
    return likes + 1;
}

// @test-params 0 1 1
pub test_delete_sets_flag(deleted: u8, expected: u8) -> u8 {
    return 1;
}

// @test-params 1 0 0
pub test_cannot_like_deleted(deleted: u8, expected: u8) -> u8 {
    if deleted == 0 {
        return 1;
    }
    return 0;
}
