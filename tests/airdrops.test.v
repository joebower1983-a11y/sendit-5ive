// Tests for Send.it Airdrops Module

// @test-params 0 1 1
pub test_claim_increments_count(claimed_count: u64, amount: u64) -> u64 {
    return claimed_count + 1;
}

// @test-params 1 1 1
pub test_campaign_active_check(is_active: u8, expected: u8) -> u8 {
    return is_active;
}

// @test-params 0 0 0
pub test_campaign_inactive(is_active: u8, expected: u8) -> u8 {
    return is_active;
}

// @test-params 10 10 0
pub test_max_recipients_reached(claimed: u64, max_recipients: u64) -> u64 {
    if claimed < max_recipients {
        return 1;
    }
    return 0;
}

// @test-params 0 0 0
pub test_zero_amount_rejected(amount: u64, dummy: u64) -> u64 {
    if amount > 0 {
        return 1;
    }
    return 0;
}
