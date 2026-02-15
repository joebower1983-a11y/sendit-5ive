// Tests for Send.it Copy Trading Module

// @test-params 5 3 10000 6250
pub test_win_rate_calculation(winning: u64, total_extra: u64) -> u64 {
    let total: u64 = winning + total_extra;
    if total == 0 {
        return 0;
    }
    return (winning * 10000) / total;
}

// @test-params 0 0 0 0
pub test_win_rate_zero_trades(winning: u64, total: u64) -> u64 {
    if total == 0 {
        return 0;
    }
    return (winning * 10000) / total;
}

// @test-params 100 1000 500 200
pub test_follower_amount_calc(leader_amount: u64, max_alloc: u64, leader_balance: u64) -> u64 {
    if leader_balance > 0 {
        return (leader_amount * max_alloc) / leader_balance;
    }
    return 0;
}

// @test-params 0 1 1
pub test_followers_count_increment(current: u64, expected: u64) -> u64 {
    return current + 1;
}

// @test-params 5 1 4
pub test_followers_count_decrement(current: u64, expected: u64) -> u64 {
    if current > 0 {
        return current - 1;
    }
    return 0;
}
