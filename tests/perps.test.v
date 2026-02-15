// Tests for Send.it Perps Module

// @test-params 500000 2000000 1000000
pub test_mul_precision(a: u64, b: u64) -> u64 {
    return (a * b) / 1000000;
}

// @test-params 5000000 2000000 2500000
pub test_div_precision(a: u64, b: u64) -> u64 {
    return (a * 1000000) / b;
}

// @test-params 10000000 2000000 20000000
pub test_calc_notional(size: u64, price: u64) -> u64 {
    return (size * price) / 1000000;
}

// @test-params 20000000 600 12000
pub test_calc_fee(notional: u64, fee_rate: u64) -> u64 {
    return (notional * fee_rate) / 1000000;
}

// @test-params 1000000 2000000 1500000 1500000
pub test_pnl_long_profit(entry: u64, mark: u64, size: u64) -> u64 {
    // mark > entry → profit
    let diff: u64 = mark - entry;
    return (diff * size) / 1000000;
}

// @test-params 2000000 1000000 1500000 1500000
pub test_pnl_short_profit(entry: u64, mark: u64, size: u64) -> u64 {
    // entry > mark → short profit
    let diff: u64 = entry - mark;
    return (diff * size) / 1000000;
}
