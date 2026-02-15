// Tests for Send.it Achievements Module

// @test-params 1000 16 16
pub test_early_adopter_badge(total_users: u64, expected_badges: u64) -> u64 {
    // Users within first 1000 get EARLY_ADOPTER badge (bit 4 = 16)
    if total_users <= 1000 {
        return 16;
    }
    return 0;
}

// @test-params 1001 0 0
pub test_no_early_adopter_after_limit(total_users: u64, expected: u64) -> u64 {
    if total_users <= 1000 {
        return 16;
    }
    return 0;
}

// @test-params 1 0 1
pub test_first_launch_badge(tokens_launched: u64, badges: u64) -> u64 {
    // FIRST_LAUNCH = bit 0 = 1, awarded when tokens_launched >= 1
    let mut new_badges: u64 = badges;
    if tokens_launched >= 1 {
        let mut has_first: u64 = new_badges / 1;
        has_first = has_first - ((has_first / 2) * 2);
        if has_first == 0 {
            new_badges = new_badges + 1;
        }
    }
    return new_badges;
}

// @test-params 10000000000 0 4
pub test_whale_badge(total_volume: u64, badges: u64) -> u64 {
    // WHALE_STATUS = bit 2 = 4, awarded when volume >= 10 SOL
    let mut new_badges: u64 = badges;
    if total_volume >= 10000000000 {
        let mut has_whale: u64 = new_badges / 4;
        has_whale = has_whale - ((has_whale / 2) * 2);
        if has_whale == 0 {
            new_badges = new_badges + 4;
        }
    }
    return new_badges;
}

// @test-params 100 0 8
pub test_degen_badge(trade_count: u64, badges: u64) -> u64 {
    // DEGEN_100 = bit 3 = 8, awarded when trade_count >= 100
    let mut new_badges: u64 = badges;
    if trade_count >= 100 {
        let mut has_degen: u64 = new_badges / 8;
        has_degen = has_degen - ((has_degen / 2) * 2);
        if has_degen == 0 {
            new_badges = new_badges + 8;
        }
    }
    return new_badges;
}

// @test-params 99 0 0
pub test_degen_badge_not_yet(trade_count: u64, badges: u64) -> u64 {
    let mut new_badges: u64 = badges;
    if trade_count >= 100 {
        let mut has_degen: u64 = new_badges / 8;
        has_degen = has_degen - ((has_degen / 2) * 2);
        if has_degen == 0 {
            new_badges = new_badges + 8;
        }
    }
    return new_badges;
}
