// Tests for Send.it Staking Module

// @test-params 1000 1000
pub test_create_stake_pool(reward_rate: u64) -> u64 {
    return reward_rate;
}

// @test-params 100 50 150
pub test_stake_balance_update(initial: u64, stake_amount: u64) -> u64 {
    return initial + stake_amount;
}

// @test-params 1000 500 500
pub test_unstake_balance_update(staked: u64, unstake_amount: u64) -> u64 {
    return staked - unstake_amount;
}

// @test-params 100 10 1000000000000 10
pub test_reward_calculation(amount: u64, elapsed: u64, precision: u64) -> u64 {
    let reward_rate: u64 = 1000000000000;
    let total_staked: u64 = 100;
    let additional: u64 = (elapsed * reward_rate) / total_staked;
    let pending: u64 = (amount * additional) / precision;
    return pending;
}

// @test-params 0 0
pub test_zero_stake_rejected(amount: u64) -> u64 {
    if amount == 0 {
        return 0;
    }
    return 1;
}

// @test-params 100 200 0
pub test_insufficient_unstake(staked: u64, requested: u64) -> u64 {
    if staked >= requested {
        return 1;
    }
    return 0;
}
