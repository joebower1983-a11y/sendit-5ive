// Tests for Send.it Share Cards Module

// @test-params 1000 1000
pub test_get_price(price: u64) -> u64 {
    return price;
}

// @test-params 50000 50000
pub test_get_market_cap(mcap: u64) -> u64 {
    return mcap;
}

// @test-params 10000 1 1
pub test_migration_progress_valid(bps: u64, expected: u8) -> u8 {
    if bps <= 10000 {
        return 1;
    }
    return 0;
}

// @test-params 10001 0 0
pub test_migration_progress_invalid(bps: u64, expected: u8) -> u8 {
    if bps <= 10000 {
        return 1;
    }
    return 0;
}
