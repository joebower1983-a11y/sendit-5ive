// Tests for Send.it Stable Pairs Module

// @test-params 1000 30 3
pub test_swap_fee_calc(amount_in: u64, fee_bps: u64) -> u64 {
    return (amount_in * fee_bps) / 10000;
}

// @test-params 1000000 997 1000000 996
pub test_constant_product_swap(reserve_out: u64, amount_in_after_fee: u64, reserve_in: u64) -> u64 {
    let numerator: u64 = reserve_out * amount_in_after_fee;
    let denominator: u64 = reserve_in + amount_in_after_fee;
    return numerator / denominator;
}

// @test-params 1000 2000 1500
pub test_first_lp_shares(token: u64, stable: u64) -> u64 {
    return (token + stable) / 2;
}

// @test-params 500 0 1
pub test_fee_bps_limit(bps: u64, expected: u8) -> u8 {
    if bps <= 500 {
        return 1;
    }
    return 0;
}

// @test-params 501 0 0
pub test_fee_bps_too_high(bps: u64, expected: u8) -> u8 {
    if bps <= 500 {
        return 1;
    }
    return 0;
}
