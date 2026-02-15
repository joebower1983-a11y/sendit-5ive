// Send.it Achievements Module — ported from Anchor to 5IVE DSL
// Badges stored as u64 bitflags:
//   bit 0 (1)  = FIRST_LAUNCH
//   bit 1 (2)  = DIAMOND_HANDS
//   bit 2 (4)  = WHALE_STATUS
//   bit 3 (8)  = DEGEN_100
//   bit 4 (16) = EARLY_ADOPTER
// Thresholds:
//   DIAMOND_HANDS_SECONDS = 2592000 (30 days)
//   WHALE_VOLUME_LAMPORTS = 10000000000 (10 SOL)
//   DEGEN_TRADE_COUNT = 100
//   EARLY_ADOPTER_LIMIT = 1000

// ---------------------------------------------------------------------------
// Accounts
// ---------------------------------------------------------------------------

account AchievementConfig {
    total_users: u64;
    authority: pubkey;
    bump: u8;
}

account UserAchievements {
    user: pubkey;
    badges: u64;
    trade_count: u64;
    total_volume: u64;
    tokens_launched: u64;
    earliest_hold_start: u64;
    created_at: u64;
    bump: u8;
}

// ---------------------------------------------------------------------------
// Instructions
// ---------------------------------------------------------------------------

/// Initialize global achievement config
pub initialize_achievement_config(
    config: AchievementConfig @mut @init(payer=authority, space=128) @signer,
    authority: account @mut @signer
) {
    config.total_users = 0;
    config.authority = authority.key;
    config.bump = 0;
}

/// Initialize achievements for a user
pub initialize_user_achievements(
    user_achievements: UserAchievements @mut @init(payer=payer, space=256) @signer,
    config: AchievementConfig @mut,
    payer: account @mut @signer,
    user: account
) {
    let clock: u64 = get_clock();

    user_achievements.user = user.key;
    user_achievements.badges = 0;
    user_achievements.trade_count = 0;
    user_achievements.total_volume = 0;
    user_achievements.tokens_launched = 0;
    user_achievements.earliest_hold_start = 0;
    user_achievements.created_at = clock;
    user_achievements.bump = 0;

    config.total_users = config.total_users + 1;

    // Award early adopter if within first 1000 users
    if config.total_users <= 1000 {
        user_achievements.badges = 16;
    }
}

/// Record activity and check for new badge awards
pub record_activity(
    user_achievements: UserAchievements @mut,
    cranker: account @signer,
    trades: u64,
    volume_lamports: u64,
    tokens_launched: u64,
    hold_start: u64
) {
    let clock: u64 = get_clock();

    user_achievements.trade_count = user_achievements.trade_count + trades;
    user_achievements.total_volume = user_achievements.total_volume + volume_lamports;
    user_achievements.tokens_launched = user_achievements.tokens_launched + tokens_launched;

    if hold_start > 0 {
        if user_achievements.earliest_hold_start == 0 {
            user_achievements.earliest_hold_start = hold_start;
        }
        if hold_start < user_achievements.earliest_hold_start {
            user_achievements.earliest_hold_start = hold_start;
        }
    }

    // Check FIRST_LAUNCH (bit 0 = 1)
    if user_achievements.tokens_launched >= 1 {
        // Set bit 0 — use addition if not already set
        // Since we can't do bitwise ops, we track via simple flag checks
        // badges encoding: sum of flag values
        let mut new_badges: u64 = user_achievements.badges;

        // FIRST_LAUNCH = 1
        let mut has_first: u64 = new_badges / 1;
        has_first = has_first - ((has_first / 2) * 2);
        if has_first == 0 {
            new_badges = new_badges + 1;
        }

        user_achievements.badges = new_badges;
    }

    // Check DIAMOND_HANDS (bit 1 = 2): held 30+ days
    if user_achievements.earliest_hold_start > 0 {
        if clock >= user_achievements.earliest_hold_start + 2592000 {
            let mut b: u64 = user_achievements.badges;
            let mut has_dh: u64 = b / 2;
            has_dh = has_dh - ((has_dh / 2) * 2);
            if has_dh == 0 {
                user_achievements.badges = user_achievements.badges + 2;
            }
        }
    }

    // Check WHALE_STATUS (bit 2 = 4): >= 10 SOL volume
    if user_achievements.total_volume >= 10000000000 {
        let mut b2: u64 = user_achievements.badges;
        let mut has_whale: u64 = b2 / 4;
        has_whale = has_whale - ((has_whale / 2) * 2);
        if has_whale == 0 {
            user_achievements.badges = user_achievements.badges + 4;
        }
    }

    // Check DEGEN_100 (bit 3 = 8): >= 100 trades
    if user_achievements.trade_count >= 100 {
        let mut b3: u64 = user_achievements.badges;
        let mut has_degen: u64 = b3 / 8;
        has_degen = has_degen - ((has_degen / 2) * 2);
        if has_degen == 0 {
            user_achievements.badges = user_achievements.badges + 8;
        }
    }
}

/// Permissionless crank: re-evaluate badges
pub check_and_award(
    user_achievements: UserAchievements @mut,
    cranker: account @signer
) {
    let clock: u64 = get_clock();

    if user_achievements.tokens_launched >= 1 {
        let mut has_first: u64 = user_achievements.badges / 1;
        has_first = has_first - ((has_first / 2) * 2);
        if has_first == 0 {
            user_achievements.badges = user_achievements.badges + 1;
        }
    }

    if user_achievements.earliest_hold_start > 0 {
        if clock >= user_achievements.earliest_hold_start + 2592000 {
            let mut has_dh: u64 = user_achievements.badges / 2;
            has_dh = has_dh - ((has_dh / 2) * 2);
            if has_dh == 0 {
                user_achievements.badges = user_achievements.badges + 2;
            }
        }
    }

    if user_achievements.total_volume >= 10000000000 {
        let mut has_whale: u64 = user_achievements.badges / 4;
        has_whale = has_whale - ((has_whale / 2) * 2);
        if has_whale == 0 {
            user_achievements.badges = user_achievements.badges + 4;
        }
    }

    if user_achievements.trade_count >= 100 {
        let mut has_degen: u64 = user_achievements.badges / 8;
        has_degen = has_degen - ((has_degen / 2) * 2);
        if has_degen == 0 {
            user_achievements.badges = user_achievements.badges + 8;
        }
    }
}

/// Get user badges (view)
pub get_achievements(
    user_achievements: UserAchievements
) -> u64 {
    return user_achievements.badges;
}
