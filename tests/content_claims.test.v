// Tests for Send.it Content Claims Module

// @test-params 0 5000 5000
pub test_default_fee_redirect(fee_bps: u64, default_bps: u64) -> u64 {
    if fee_bps == 0 {
        return 5000;
    }
    return fee_bps;
}

// @test-params 3000 0 3000
pub test_custom_fee_redirect(fee_bps: u64, dummy: u64) -> u64 {
    if fee_bps == 0 {
        return 5000;
    }
    return fee_bps;
}

// @test-params 1000 5000 500
pub test_redirect_amount_calc(amount: u64, bps: u64) -> u64 {
    return (amount * bps) / 10000;
}

// @test-params 0 1 1
pub test_claim_status_unclaimed(status: u8, expected: u8) -> u8 {
    if status == 0 {
        return 1;
    }
    return 0;
}

// @test-params 1 0 0
pub test_claim_status_already_pending(status: u8, expected: u8) -> u8 {
    if status == 0 {
        return 1;
    }
    return 0;
}
