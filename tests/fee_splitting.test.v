// Tests for Send.it Fee Splitting Module

// @test-params 10000 5000 5000
pub test_split_calculation(available: u64, bps: u64) -> u64 {
    return (available * bps) / 10000;
}

// @test-params 10000 10000 10000
pub test_full_split(available: u64, bps: u64) -> u64 {
    return (available * bps) / 10000;
}

// @test-params 1000 500 500
pub test_claimable_amount(allocated: u64, claimed: u64) -> u64 {
    return allocated - claimed;
}

// @test-params 500 500 0
pub test_nothing_claimable(allocated: u64, claimed: u64) -> u64 {
    return allocated - claimed;
}
