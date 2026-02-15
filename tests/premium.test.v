// Tests for Send.it Premium Module

// @test-params 100 24 2400
pub test_total_cost(price_per_hour: u64, hours: u64) -> u64 {
    return price_per_hour * hours;
}

// @test-params 24 3600 86400
pub test_duration_seconds(hours: u64, secs_per_hour: u64) -> u64 {
    return hours * secs_per_hour;
}

// @test-params 721 0 0
pub test_max_duration_check(hours: u64, expected: u8) -> u8 {
    if hours > 0 {
        if hours <= 720 {
            return 1;
        }
    }
    return 0;
}

// @test-params 3 0 0
pub test_invalid_tier(tier: u8, expected: u8) -> u8 {
    if tier <= 2 {
        return 1;
    }
    return 0;
}
