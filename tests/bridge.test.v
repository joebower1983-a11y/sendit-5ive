// Tests for Send.it Bridge Module

// @test-params 1000 50 5
pub test_bridge_fee_calculation(amount: u64, fee_bps: u64) -> u64 {
    let fee: u64 = (amount * fee_bps) / 10000;
    return fee;
}

// @test-params 1000 50 995
pub test_bridge_net_amount(amount: u64, fee_bps: u64) -> u64 {
    let fee: u64 = (amount * fee_bps) / 10000;
    return amount - fee;
}

// @test-params 0 1 1
pub test_request_count_increment(current: u64, dummy: u64) -> u64 {
    return current + 1;
}

// @test-params 1 0 0
pub test_paused_bridge_rejected(paused: u8, expected: u8) -> u8 {
    if paused == 0 {
        return 1;
    }
    return 0;
}

// @test-params 100 1000 0
pub test_below_min_amount(amount: u64, min_amount: u64) -> u64 {
    if amount >= min_amount {
        return 1;
    }
    return 0;
}
