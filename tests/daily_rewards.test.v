// Tests for Send.it Daily Rewards Module

// @test-params 100 10 1 110
pub test_streak_multiplier_basic(base_points: u64, streak_mult: u64, streak: u64) -> u64 {
    let mut multiplier: u64 = 100 + (streak_mult * streak);
    if multiplier > 300 {
        multiplier = 300;
    }
    return (base_points * multiplier) / 100;
}

// @test-params 100 10 20 300
pub test_streak_multiplier_capped(base_points: u64, streak_mult: u64, streak: u64) -> u64 {
    let mut multiplier: u64 = 100 + (streak_mult * streak);
    if multiplier > 300 {
        multiplier = 300;
    }
    return (base_points * multiplier) / 100;
}

// @test-params 500 2 2
pub test_tier_silver(total_points: u64, dummy: u64) -> u8 {
    if total_points >= 10000 {
        return 4;
    }
    if total_points >= 2000 {
        return 3;
    }
    if total_points >= 500 {
        return 2;
    }
    if total_points >= 100 {
        return 1;
    }
    return 0;
}

// @test-params 10000 0 4
pub test_tier_diamond(total_points: u64, dummy: u64) -> u8 {
    if total_points >= 10000 {
        return 4;
    }
    if total_points >= 2000 {
        return 3;
    }
    if total_points >= 500 {
        return 2;
    }
    if total_points >= 100 {
        return 1;
    }
    return 0;
}

// @test-params 2000000000 10 20
pub test_trade_reward_points(trade_sol: u64, pts_per_sol: u64) -> u64 {
    return (trade_sol * pts_per_sol) / 1000000000;
}

// @test-params 1000 500 500
pub test_redeem_points(total: u64, spend: u64) -> u64 {
    return total - spend;
}
