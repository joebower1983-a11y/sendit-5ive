// Tests for Send.it Reputation Module

// @test-params 60 30 0 1
pub test_standard_launch_eligible(score: u8, min_score: u8, premium: u8) -> u8 {
    if premium == 0 {
        if score >= min_score {
            return 1;
        }
    }
    return 0;
}

// @test-params 60 60 1 1
pub test_premium_launch_eligible(score: u8, min_premium: u8, premium: u8) -> u8 {
    if premium == 1 {
        if score >= min_premium {
            return 1;
        }
    }
    return 0;
}

// @test-params 50 60 1 0
pub test_premium_launch_ineligible(score: u8, min_premium: u8, premium: u8) -> u8 {
    if premium == 1 {
        if score >= min_premium {
            return 1;
        }
    }
    return 0;
}

// @test-params 3 1000 1000
pub test_gold_fee_discount(tier: u8, gold_bps: u64) -> u64 {
    if tier == 3 {
        return gold_bps;
    }
    return 0;
}

// @test-params 30 40 2
pub test_vesting_multiplier_low_rep(score: u8, threshold: u8) -> u8 {
    if score < threshold {
        return 2;
    }
    return 1;
}
