// Send.it Daily Rewards Module — ported from Anchor to 5IVE DSL

// ---------------------------------------------------------------------------
// Accounts
// ---------------------------------------------------------------------------

account DailyRewardsConfig {
    authority: pubkey;
    points_per_checkin: u64;
    streak_multiplier: u64;
    points_per_trade_sol: u64;
    total_checkins: u64;
    bump: u8;
}

account UserDailyRewards {
    user: pubkey;
    current_streak: u64;
    longest_streak: u64;
    last_checkin_day: u64;
    total_points: u64;
    tier: u8;
    total_redeemed: u64;
    bump: u8;
}

// ---------------------------------------------------------------------------
// Instructions
// ---------------------------------------------------------------------------

/// Initialize daily rewards config
pub initialize_daily_rewards(
    config: DailyRewardsConfig @mut @init(payer=authority, space=256) @signer,
    authority: account @mut @signer,
    points_per_checkin: u64,
    streak_multiplier: u64,
    points_per_trade_sol: u64
) {
    config.authority = authority.key;
    config.points_per_checkin = points_per_checkin;
    config.streak_multiplier = streak_multiplier;
    config.points_per_trade_sol = points_per_trade_sol;
    config.total_checkins = 0;
    config.bump = 0;
}

/// Daily check-in to earn points
pub daily_checkin(
    config: DailyRewardsConfig @mut,
    user_rewards: UserDailyRewards @mut @init(payer=user, space=256) @signer,
    user: account @mut @signer
) {
    let clock: u64 = get_clock();
    let today: u64 = clock / 86400;

    // First-time init
    if user_rewards.user == 0 {
        user_rewards.user = user.key;
        user_rewards.bump = 0;
    }

    // Must not have checked in today
    require(user_rewards.last_checkin_day < today);

    // Update streak
    if user_rewards.last_checkin_day == today - 1 {
        user_rewards.current_streak = user_rewards.current_streak + 1;
    } else {
        user_rewards.current_streak = 1;
    }

    if user_rewards.current_streak > user_rewards.longest_streak {
        user_rewards.longest_streak = user_rewards.current_streak;
    }
    user_rewards.last_checkin_day = today;

    // Calculate points with streak multiplier (capped at 3x)
    let mut multiplier: u64 = 100 + (config.streak_multiplier * user_rewards.current_streak);
    if multiplier > 300 {
        multiplier = 300;
    }
    let points: u64 = (config.points_per_checkin * multiplier) / 100;

    user_rewards.total_points = user_rewards.total_points + points;

    // Update tier: 0=Bronze, 1=Silver, 2=Gold, 3=Platinum, 4=Diamond
    if user_rewards.total_points >= 10000 {
        user_rewards.tier = 4;
    } else {
        if user_rewards.total_points >= 2000 {
            user_rewards.tier = 3;
        } else {
            if user_rewards.total_points >= 500 {
                user_rewards.tier = 2;
            } else {
                if user_rewards.total_points >= 100 {
                    user_rewards.tier = 1;
                } else {
                    user_rewards.tier = 0;
                }
            }
        }
    }

    config.total_checkins = config.total_checkins + 1;
}

/// Record trade reward points
pub record_trade_reward(
    config: DailyRewardsConfig,
    user_rewards: UserDailyRewards @mut @init(payer=user, space=256) @signer,
    user: account @mut @signer,
    trade_sol_amount: u64
) {
    let points: u64 = (trade_sol_amount * config.points_per_trade_sol) / 1000000000;

    if points > 0 {
        if user_rewards.user == 0 {
            user_rewards.user = user.key;
            user_rewards.bump = 0;
        }
        user_rewards.total_points = user_rewards.total_points + points;

        // Update tier
        if user_rewards.total_points >= 10000 {
            user_rewards.tier = 4;
        } else {
            if user_rewards.total_points >= 2000 {
                user_rewards.tier = 3;
            } else {
                if user_rewards.total_points >= 500 {
                    user_rewards.tier = 2;
                } else {
                    if user_rewards.total_points >= 100 {
                        user_rewards.tier = 1;
                    } else {
                        user_rewards.tier = 0;
                    }
                }
            }
        }
    }
}

/// Redeem points
pub redeem_points(
    user_rewards: UserDailyRewards @mut,
    user: account @signer,
    points_to_spend: u64
) {
    require(user_rewards.user == user.key);
    require(user_rewards.total_points >= points_to_spend);

    user_rewards.total_points = user_rewards.total_points - points_to_spend;
    user_rewards.total_redeemed = user_rewards.total_redeemed + points_to_spend;

    // Update tier after spending
    if user_rewards.total_points >= 10000 {
        user_rewards.tier = 4;
    } else {
        if user_rewards.total_points >= 2000 {
            user_rewards.tier = 3;
        } else {
            if user_rewards.total_points >= 500 {
                user_rewards.tier = 2;
            } else {
                if user_rewards.total_points >= 100 {
                    user_rewards.tier = 1;
                } else {
                    user_rewards.tier = 0;
                }
            }
        }
    }
}

/// Get user points (view)
pub get_user_points(
    user_rewards: UserDailyRewards
) -> u64 {
    return user_rewards.total_points;
}
