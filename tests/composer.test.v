// Tests for Send.it Composer (Cross-Module Composition Layer)

// ---------------------------------------------------------------------------
// Composition 1: Staking <-> Reputation
// ---------------------------------------------------------------------------

// @test-params 5000000000 1 20
pub test_staking_rep_boost_large_stake(staked_amount: u64, boost_per_1000: u64) -> u64 {
    // 5 SOL staked * 1 / 1e9 = 5 boost, bucketed to 5
    let boost_raw: u64 = (staked_amount * boost_per_1000) / 1000000000;
    if boost_raw >= 20 {
        return 20;
    }
    if boost_raw >= 15 {
        return 15;
    }
    if boost_raw >= 10 {
        return 10;
    }
    if boost_raw >= 5 {
        return 5;
    }
    if boost_raw > 0 {
        return 1;
    }
    return 0;
}

// @test-params 500000000 1 0
pub test_staking_rep_boost_small_stake(staked_amount: u64, boost_per_1000: u64) -> u64 {
    // 0.5 SOL -> boost_raw = 0
    let boost_raw: u64 = (staked_amount * boost_per_1000) / 1000000000;
    if boost_raw >= 5 {
        return 5;
    }
    if boost_raw > 0 {
        return 1;
    }
    return 0;
}

// @test-params 2 2 1
pub test_rep_staking_gate_pass(tier: u8, gate: u8) -> u8 {
    // tier 2 >= gate 2 -> allowed
    if tier >= gate {
        return 1;
    }
    return 0;
}

// @test-params 1 2 0
pub test_rep_staking_gate_fail(tier: u8, gate: u8) -> u8 {
    // tier 1 < gate 2 -> blocked
    if tier >= gate {
        return 1;
    }
    return 0;
}

// ---------------------------------------------------------------------------
// Composition 2: Points <-> Achievements
// ---------------------------------------------------------------------------

// @test-params 7 2 2
pub test_achievement_multiplier_two_badges(badges: u64, max_mult: u64) -> u64 {
    // badges=7 means bits 0,1,2 set -> 3 badges -> +3 -> 4, capped to max 2
    let mut multiplier: u64 = 1;

    let has_first: u64 = badges / 1;
    let rem_first: u64 = has_first - ((has_first / 2) * 2);
    if rem_first == 1 {
        multiplier = multiplier + 1;
    }

    let has_diamond: u64 = badges / 2;
    let rem_diamond: u64 = has_diamond - ((has_diamond / 2) * 2);
    if rem_diamond == 1 {
        multiplier = multiplier + 1;
    }

    let has_whale: u64 = badges / 4;
    let rem_whale: u64 = has_whale - ((has_whale / 2) * 2);
    if rem_whale == 1 {
        multiplier = multiplier + 1;
    }

    if multiplier > max_mult {
        multiplier = max_mult;
    }
    return multiplier;
}

// @test-params 0 5 1
pub test_achievement_multiplier_no_badges(badges: u64, max_mult: u64) -> u64 {
    let mut multiplier: u64 = 1;
    let has_first: u64 = badges / 1;
    let rem_first: u64 = has_first - ((has_first / 2) * 2);
    if rem_first == 1 {
        multiplier = multiplier + 1;
    }
    if multiplier > max_mult {
        multiplier = max_mult;
    }
    return multiplier;
}

// @test-params 5 8
pub test_points_unlock_degen_badge(level: u64) -> u64 {
    // Level 5+ unlocks DEGEN_100 (bit 3 = 8)
    let mut new_badges: u64 = 0;
    if level >= 5 {
        new_badges = new_badges + 8;
    }
    return new_badges;
}

// @test-params 8 12
pub test_points_unlock_whale_and_degen(level: u64) -> u64 {
    // Level 8+ unlocks both WHALE (4) and DEGEN (8) = 12
    let mut new_badges: u64 = 0;
    if level >= 5 {
        new_badges = new_badges + 8;
    }
    if level >= 8 {
        new_badges = new_badges + 4;
    }
    return new_badges;
}

// ---------------------------------------------------------------------------
// Composition 3: Lending <-> Staking
// ---------------------------------------------------------------------------

// @test-params 10000000000 5000 5000000000
pub test_staking_collateral_value(staked: u64, ratio_bps: u64) -> u64 {
    // 10 SOL staked at 50% ratio = 5 SOL collateral
    let collateral: u64 = (staked * ratio_bps) / 10000;
    return collateral;
}

// @test-params 1000000 2000 200000
pub test_interest_to_staking(interest_owed: u64, route_bps: u64) -> u64 {
    // 1M interest at 20% route = 200K to staking
    let to_staking: u64 = (interest_owed * route_bps) / 10000;
    return to_staking;
}

// ---------------------------------------------------------------------------
// Composition 4: Referral <-> Points
// ---------------------------------------------------------------------------

// @test-params 10 50 500
pub test_referral_points_calc(total_referred: u64, points_per: u64) -> u64 {
    let points: u64 = total_referred * points_per;
    return points;
}

// @test-params 6000 5000 500
pub test_referral_bonus_eligible(total_points: u64, threshold: u64) -> u64 {
    // 6000 >= 5000 threshold -> bonus 500
    if total_points >= threshold {
        return 500;
    }
    return 0;
}

// @test-params 3000 5000 0
pub test_referral_bonus_not_eligible(total_points: u64, threshold: u64) -> u64 {
    if total_points >= threshold {
        return 500;
    }
    return 0;
}

// ---------------------------------------------------------------------------
// Composition 5: Reputation <-> Prediction
// ---------------------------------------------------------------------------

// @test-params 40 30 1
pub test_prediction_rep_gate_pass(fairscore: u8, min_score: u8) -> u8 {
    if fairscore >= min_score {
        return 1;
    }
    return 0;
}

// @test-params 20 30 0
pub test_prediction_rep_gate_fail(fairscore: u8, min_score: u8) -> u8 {
    if fairscore >= min_score {
        return 1;
    }
    return 0;
}

// ---------------------------------------------------------------------------
// Composition 6: Fee Splitting <-> Holder Rewards
// ---------------------------------------------------------------------------

// @test-params 10000000 3000 3000000
pub test_fee_to_holder_rewards(total_distributed: u64, route_bps: u64) -> u64 {
    let to_holders: u64 = (total_distributed * route_bps) / 10000;
    return to_holders;
}

// @test-params 0 3000 0
pub test_fee_to_holder_rewards_zero(total_distributed: u64, route_bps: u64) -> u64 {
    let to_holders: u64 = (total_distributed * route_bps) / 10000;
    return to_holders;
}
