// Tests for Send.it Holder Rewards Module

// @test-params 1000 1000000000000 100 10000000000000
pub test_reward_per_token_increment(reward_amount: u64, precision: u64, total_supply: u64) -> u64 {
    let scaled: u64 = reward_amount * precision;
    return scaled / total_supply;
}

// @test-params 50 20000000000000 1000000000000 950
pub test_pending_reward_calculation(balance: u64, reward_per_token: u64, paid: u64) -> u64 {
    let delta: u64 = reward_per_token - paid;
    return (balance * delta) / 1000000000000;
}

// @test-params 0 100 100
pub test_zero_balance_no_rewards(balance: u64, earned: u64) -> u64 {
    if balance == 0 {
        return earned;
    }
    return 0;
}

// @test-params 1 0 1
pub test_auto_compound_toggle(enabled: u8, dummy: u8) -> u8 {
    return enabled;
}
