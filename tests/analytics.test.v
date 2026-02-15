// Tests for Send.it Analytics Module

// @test-params 500 200 700
pub test_volume_accumulation(existing: u64, trade: u64) -> u64 {
    return existing + trade;
}

// @test-params 10 1 11
pub test_trade_count_increment(trades: u64, new_trade: u64) -> u64 {
    return trades + 1;
}

// @test-params 1000000000 1 1
pub test_whale_threshold_met(volume: u64, expected: u64) -> u64 {
    if volume >= 1000000000 {
        return 1;
    }
    return 0;
}

// @test-params 999999999 0 0
pub test_whale_threshold_not_met(volume: u64, expected: u64) -> u64 {
    if volume >= 1000000000 {
        return 1;
    }
    return 0;
}

// @test-params 100 200 300
pub test_hourly_volume_accumulation(current: u64, trade: u64) -> u64 {
    return current + trade;
}
