// Tests for Send.it Referral Module

// @test-params 10000 500 500
pub test_referral_reward_calc(fee: u64, bps: u64) -> u64 {
    return (fee * bps) / 10000;
}

// @test-params 10000 0 0
pub test_zero_bps_no_reward(fee: u64, bps: u64) -> u64 {
    return (fee * bps) / 10000;
}

// @test-params 500 0 500
pub test_claimable_accumulation(existing: u64, reward: u64) -> u64 {
    return existing + reward;
}

// @test-params 500 500 0
pub test_claim_clears_balance(claimable: u64, claimed: u64) -> u64 {
    return claimable - claimed;
}
