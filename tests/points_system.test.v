// Tests for Send.it Points System Module

// @test-params 100 2 200
pub test_base_points_with_multiplier(base: u64, mult: u64) -> u64 {
    return base * mult;
}

// @test-params 100 10 10
pub test_streak_bonus(points: u64, streak_days: u64) -> u64 {
    let mut pct: u64 = streak_days;
    if pct > 50 {
        pct = 50;
    }
    return (points * pct) / 100;
}

// @test-params 100 60 50
pub test_streak_bonus_capped(points: u64, streak_days: u64) -> u64 {
    let mut pct: u64 = streak_days;
    if pct > 50 {
        pct = 50;
    }
    return (points * pct) / 100;
}

// @test-params 500 3 3
pub test_level_calc(total_points: u64, expected: u64) -> u64 {
    if total_points >= 250000 {
        return 10;
    }
    if total_points >= 100000 {
        return 9;
    }
    if total_points >= 50000 {
        return 8;
    }
    if total_points >= 25000 {
        return 7;
    }
    if total_points >= 10000 {
        return 6;
    }
    if total_points >= 5000 {
        return 5;
    }
    if total_points >= 2000 {
        return 4;
    }
    if total_points >= 500 {
        return 3;
    }
    if total_points >= 100 {
        return 2;
    }
    return 1;
}

// @test-params 1000 500 500
pub test_claim_reward_deducts(available: u64, cost: u64) -> u64 {
    return available - cost;
}
