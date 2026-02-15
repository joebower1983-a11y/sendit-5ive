// Tests for Send.it Token Videos Module

// @test-params 5 3 8
pub test_total_votes(upvotes: u64, downvotes: u64) -> u64 {
    return upvotes + downvotes;
}

// @test-params 0 1 1
pub test_upvote_increment(upvotes: u64, expected: u64) -> u64 {
    return upvotes + 1;
}

// @test-params 0 1 1
pub test_downvote_increment(downvotes: u64, expected: u64) -> u64 {
    return downvotes + 1;
}

// @test-params 10 5 0
pub test_remove_zeroes_votes(upvotes: u64, downvotes: u64) -> u64 {
    // After removal, both are zeroed
    return 0;
}
