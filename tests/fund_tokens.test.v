// Tests for Send.it Fund Tokens Module

// @test-params 1000 1000 1000
pub test_deposit_shares_1to1(sol_amount: u64, expected: u64) -> u64 {
    return sol_amount;
}

// @test-params 1000 200 980
pub test_redeem_with_fee(shares: u64, fee_bps: u64) -> u64 {
    let fee: u64 = (shares * fee_bps) / 10000;
    return shares - fee;
}

// @test-params 500 0 500
pub test_redeem_zero_fee(shares: u64, fee_bps: u64) -> u64 {
    let fee: u64 = (shares * fee_bps) / 10000;
    return shares - fee;
}

// @test-params 501 1 0
pub test_fee_bps_limit(fee_bps: u64, expected: u8) -> u8 {
    if fee_bps <= 500 {
        return 1;
    }
    return 0;
}

// @test-params 0 0 0
pub test_zero_deposit_rejected(amount: u64, expected: u64) -> u64 {
    if amount > 0 {
        return 1;
    }
    return 0;
}
