// Tests for Send.it Lending Module

// @test-params 1000 500 5000
pub test_pool_utilization(deposited: u64, borrowed: u64) -> u64 {
    if deposited == 0 {
        return 0;
    }
    return (borrowed * 10000) / deposited;
}

// @test-params 0 0 0
pub test_pool_utilization_empty(deposited: u64, borrowed: u64) -> u64 {
    if deposited == 0 {
        return 0;
    }
    return (borrowed * 10000) / deposited;
}

// @test-params 10000 5000 5000
pub test_max_borrow_ltv(collateral: u64, ltv_ratio: u64) -> u64 {
    return (collateral * ltv_ratio) / 10000;
}

// @test-params 1000 500 86400 0
pub test_interest_accrual(borrowed: u64, rate_bps: u64, elapsed: u64) -> u64 {
    return (borrowed * rate_bps * elapsed) / (10000 * 31536000);
}

// @test-params 50 100 50
pub test_repay_interest_first(amount: u64, interest: u64) -> u64 {
    if amount <= interest {
        return interest - amount;
    }
    return 0;
}
