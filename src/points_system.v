// Send.it Points System Module — ported from Anchor to 5IVE DSL

// ---------------------------------------------------------------------------
// Accounts
// ---------------------------------------------------------------------------

account PointsConfig {
    authority: pubkey;
    points_per_trade: u64;
    points_per_launch: u64;
    points_per_referral: u64;
    points_per_hold_day: u64;
    season_id: u64;
    action_cooldown: u64;
    max_daily_points: u64;
    paused: u8;
    bump: u8;
}

account UserPoints {
    user: pubkey;
    season_id: u64;
    total_points: u64;
    available_points: u64;
    level: u64;
    last_action_ts: u64;
    streak_days: u64;
    last_action_day: u64;
    daily_points_earned: u64;
    daily_reset_day: u64;
    bump: u8;
}

// ---------------------------------------------------------------------------
// Instructions
// ---------------------------------------------------------------------------

/// Initialize the global points configuration
pub initialize_points_config(
    points_config: PointsConfig @mut @init(payer=authority, space=256) @signer,
    authority: account @mut @signer,
    points_per_trade: u64,
    points_per_launch: u64,
    points_per_referral: u64,
    points_per_hold_day: u64
) {
    points_config.authority = authority.key;
    points_config.points_per_trade = points_per_trade;
    points_config.points_per_launch = points_per_launch;
    points_config.points_per_referral = points_per_referral;
    points_config.points_per_hold_day = points_per_hold_day;
    points_config.season_id = 1;
    points_config.action_cooldown = 60;
    points_config.max_daily_points = 10000;
    points_config.paused = 0;
    points_config.bump = 0;
}

/// Update points configuration
pub update_points_config(
    points_config: PointsConfig @mut,
    authority: account @signer,
    points_per_trade: u64,
    points_per_launch: u64,
    points_per_referral: u64,
    points_per_hold_day: u64,
    action_cooldown: u64,
    max_daily_points: u64
) {
    require(authority.key == points_config.authority);

    points_config.points_per_trade = points_per_trade;
    points_config.points_per_launch = points_per_launch;
    points_config.points_per_referral = points_per_referral;
    points_config.points_per_hold_day = points_per_hold_day;
    points_config.action_cooldown = action_cooldown;
    points_config.max_daily_points = max_daily_points;
}

/// Pause/unpause points system
pub set_points_paused(
    points_config: PointsConfig @mut,
    authority: account @signer,
    paused: u8
) {
    require(authority.key == points_config.authority);
    points_config.paused = paused;
}

/// Award points to a user for a specific action
/// action: 0=Trade, 1=Launch, 2=Referral, 3=HoldDay
pub award_points(
    points_config: PointsConfig,
    user_points: UserPoints @mut @init(payer=authority, space=256) @signer,
    authority: account @mut @signer,
    user_key: pubkey,
    action: u8,
    multiplier: u64
) {
    require(points_config.paused == 0);
    require(authority.key == points_config.authority);

    let clock: u64 = get_clock();
    let today: u64 = clock / 86400;

    // First-time init
    if user_points.total_points == 0 {
        user_points.user = user_key;
        user_points.season_id = points_config.season_id;
        user_points.streak_days = 0;
        user_points.last_action_day = 0;
        user_points.daily_reset_day = today;
        user_points.daily_points_earned = 0;
        user_points.bump = 0;
    }

    // Cooldown check
    let elapsed: u64 = clock - user_points.last_action_ts;
    require(elapsed >= points_config.action_cooldown);

    // Daily cap reset
    if today != user_points.daily_reset_day {
        user_points.daily_points_earned = 0;
        user_points.daily_reset_day = today;
    }

    // Calculate base points from action type
    let mut base_points: u64 = points_config.points_per_trade;
    if action == 1 {
        base_points = points_config.points_per_launch;
    }
    if action == 2 {
        base_points = points_config.points_per_referral;
    }
    if action == 3 {
        base_points = points_config.points_per_hold_day;
    }

    let mut mult: u64 = multiplier;
    if mult == 0 {
        mult = 1;
    }
    let raw_points: u64 = base_points * mult;

    // Daily cap check
    let headroom: u64 = points_config.max_daily_points - user_points.daily_points_earned;
    require(headroom > 0);

    let mut capped_points: u64 = raw_points;
    if capped_points > headroom {
        capped_points = headroom;
    }

    // Streak logic
    let last_day: u64 = user_points.last_action_day;
    if last_day == 0 {
        user_points.streak_days = 1;
    } else {
        if today == last_day + 1 {
            user_points.streak_days = user_points.streak_days + 1;
        } else {
            if today != last_day {
                // Check grace period (48h)
                let since_last: u64 = clock - user_points.last_action_ts;
                if since_last <= 172800 {
                    user_points.streak_days = user_points.streak_days + 1;
                } else {
                    user_points.streak_days = 1;
                }
            }
        }
    }

    // Streak bonus: +1% per day, capped at 50%
    let mut streak_pct: u64 = user_points.streak_days;
    if streak_pct > 50 {
        streak_pct = 50;
    }
    let bonus: u64 = (capped_points * streak_pct) / 100;
    let mut final_points: u64 = capped_points + bonus;

    // Re-check daily cap after bonus
    let remaining: u64 = points_config.max_daily_points - user_points.daily_points_earned;
    if final_points > remaining {
        final_points = remaining;
    }

    // Update user state
    user_points.total_points = user_points.total_points + final_points;
    user_points.available_points = user_points.available_points + final_points;
    user_points.daily_points_earned = user_points.daily_points_earned + final_points;
    user_points.last_action_ts = clock;
    user_points.last_action_day = today;

    // Level calculation
    if user_points.total_points >= 250000 {
        user_points.level = 10;
    } else {
        if user_points.total_points >= 100000 {
            user_points.level = 9;
        } else {
            if user_points.total_points >= 50000 {
                user_points.level = 8;
            } else {
                if user_points.total_points >= 25000 {
                    user_points.level = 7;
                } else {
                    if user_points.total_points >= 10000 {
                        user_points.level = 6;
                    } else {
                        if user_points.total_points >= 5000 {
                            user_points.level = 5;
                        } else {
                            if user_points.total_points >= 2000 {
                                user_points.level = 4;
                            } else {
                                if user_points.total_points >= 500 {
                                    user_points.level = 3;
                                } else {
                                    if user_points.total_points >= 100 {
                                        user_points.level = 2;
                                    } else {
                                        user_points.level = 1;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

/// Claim a reward by spending points
/// reward_kind: 0=FeeDiscount, 1=EarlyAccess, 2=Badge
pub claim_reward(
    points_config: PointsConfig,
    user_points: UserPoints @mut,
    user: account @mut @signer,
    points_cost: u64
) {
    require(points_cost > 0);
    require(user_points.user == user.key);
    require(user_points.available_points >= points_cost);

    user_points.available_points = user_points.available_points - points_cost;
}

/// End current season, bump season_id
pub end_points_season(
    points_config: PointsConfig @mut,
    authority: account @signer
) {
    require(authority.key == points_config.authority);
    points_config.season_id = points_config.season_id + 1;
}

/// View: get user level
pub get_user_level(
    user_points: UserPoints
) -> u64 {
    return user_points.level;
}

/// View: get available points
pub get_available_points(
    user_points: UserPoints
) -> u64 {
    return user_points.available_points;
}
