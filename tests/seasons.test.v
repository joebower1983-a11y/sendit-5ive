// Tests for Send.it Seasons Module

// @test-params 0 1 1
pub test_participant_increment(current: u64, expected: u64) -> u64 {
    return current + 1;
}

// @test-params 500 100 5
pub test_level_from_xp(xp: u64, divisor: u64) -> u64 {
    return xp / divisor;
}

// @test-params 1000 500 1500
pub test_xp_accumulation(current: u64, earned: u64) -> u64 {
    return current + earned;
}

// @test-params 0 100 1
pub test_end_time_must_exceed_start(start: u64, end_time: u64) -> u8 {
    if end_time > start {
        return 1;
    }
    return 0;
}

// @test-params 1000 500 1500
pub test_fund_prize_pool(current: u64, added: u64) -> u64 {
    return current + added;
}
