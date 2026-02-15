// Send.it Cross-Module Composition Layer
// Orchestrates interactions between modules within the same VM
// Uses bridge pattern: composer owns state tracking cross-module effects

// ---------------------------------------------------------------------------
// External Account References (read-only mirrors for cross-module access)
// These mirror the account layouts from other modules so the composer
// can read their fields. Actual writes happen in the owning module.
// ---------------------------------------------------------------------------

account UserStake {
    user: pubkey;
    mint: pubkey;
    pool: pubkey;
    amount: u64;
    start_time: u64;
    rewards_earned: u64;
    reward_per_token_paid: u64;
    bump: u8;
}

account ReputationAttestation {
    wallet: pubkey;
    fairscore: u8;
    tier: u8;
    last_updated: u64;
    attested_by: pubkey;
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

account UserLendPosition {
    user: pubkey;
    collateral_token: pubkey;
    deposited: u64;
    borrowed: u64;
    collateral_amount: u64;
    last_interest_update: u64;
    interest_owed: u64;
    bump: u8;
}

account ReferralAccount {
    user: pubkey;
    referrer: pubkey;
    total_referred: u64;
    total_earned: u64;
    claimable: u64;
    registered_at: u64;
    bump: u8;
}

account UserBet {
    user: pubkey;
    market: pubkey;
    side: u8;
    amount: u64;
    claimed: u8;
}

account FeeConfig {
    token_mint: pubkey;
    creator: pubkey;
    split_count: u8;
    split1_recipient: pubkey;
    split1_bps: u64;
    split2_recipient: pubkey;
    split2_bps: u64;
    split3_recipient: pubkey;
    split3_bps: u64;
    split4_recipient: pubkey;
    split4_bps: u64;
    split5_recipient: pubkey;
    split5_bps: u64;
    total_distributed: u64;
    has_distributed: u8;
    allow_update: u8;
    bump: u8;
}

// ---------------------------------------------------------------------------
// Composer State Accounts
// ---------------------------------------------------------------------------

account ComposerConfig {
    authority: pubkey;
    staking_rep_boost_per_1000: u64;
    rep_staking_tier_gate: u8;
    lending_collateral_ratio_bps: u64;
    lending_interest_to_staking_bps: u64;
    referral_points_per_action: u64;
    referral_bonus_point_threshold: u64;
    referral_bonus_amount: u64;
    prediction_min_rep_to_create: u8;
    prediction_rep_boost: u8;
    fee_to_holder_reward_bps: u64;
    points_achievement_multiplier: u64;
    paused: u8;
    bump: u8;
}

account UserComposerState {
    user: pubkey;
    staking_rep_pending: u64;
    prediction_rep_pending: u8;
    referral_points_pending: u64;
    lending_interest_routed: u64;
    fee_routed_to_holders: u64;
    last_compose_ts: u64;
    bump: u8;
}

// ---------------------------------------------------------------------------
// Initialize
// ---------------------------------------------------------------------------

pub initialize_composer(
    config: ComposerConfig @mut @init(payer=authority, space=512) @signer,
    authority: account @mut @signer
) {
    config.authority = authority.key;
    config.staking_rep_boost_per_1000 = 1;
    config.rep_staking_tier_gate = 2;
    config.lending_collateral_ratio_bps = 5000;
    config.lending_interest_to_staking_bps = 2000;
    config.referral_points_per_action = 50;
    config.referral_bonus_point_threshold = 5000;
    config.referral_bonus_amount = 500;
    config.prediction_min_rep_to_create = 30;
    config.prediction_rep_boost = 5;
    config.fee_to_holder_reward_bps = 3000;
    config.points_achievement_multiplier = 2;
    config.paused = 0;
    config.bump = 0;
}

pub update_composer_config(
    config: ComposerConfig @mut,
    authority: account @signer,
    staking_rep_boost_per_1000: u64,
    rep_staking_tier_gate: u8,
    lending_collateral_ratio_bps: u64,
    lending_interest_to_staking_bps: u64,
    referral_points_per_action: u64,
    referral_bonus_point_threshold: u64,
    referral_bonus_amount: u64,
    prediction_min_rep_to_create: u8,
    prediction_rep_boost: u8,
    fee_to_holder_reward_bps: u64,
    points_achievement_multiplier: u64
) {
    require(config.authority == authority.key);

    config.staking_rep_boost_per_1000 = staking_rep_boost_per_1000;
    config.rep_staking_tier_gate = rep_staking_tier_gate;
    config.lending_collateral_ratio_bps = lending_collateral_ratio_bps;
    config.lending_interest_to_staking_bps = lending_interest_to_staking_bps;
    config.referral_points_per_action = referral_points_per_action;
    config.referral_bonus_point_threshold = referral_bonus_point_threshold;
    config.referral_bonus_amount = referral_bonus_amount;
    config.prediction_min_rep_to_create = prediction_min_rep_to_create;
    config.prediction_rep_boost = prediction_rep_boost;
    config.fee_to_holder_reward_bps = fee_to_holder_reward_bps;
    config.points_achievement_multiplier = points_achievement_multiplier;
}

pub init_user_composer_state(
    user_state: UserComposerState @mut @init(payer=user, space=256) @signer,
    user: account @mut @signer
) {
    user_state.user = user.key;
    user_state.staking_rep_pending = 0;
    user_state.prediction_rep_pending = 0;
    user_state.referral_points_pending = 0;
    user_state.lending_interest_routed = 0;
    user_state.fee_routed_to_holders = 0;
    user_state.last_compose_ts = 0;
    user_state.bump = 0;
}

// ---------------------------------------------------------------------------
// Composition 1: Staking <-> Reputation
// Staking amount boosts reputation; reputation tier gates staking access
// ---------------------------------------------------------------------------

/// Calculate reputation boost from staking amount
/// Returns boost points (0-100 scale addition to fairscore)
pub calc_staking_rep_boost(
    config: ComposerConfig,
    user_stake: UserStake
) -> u8 {
    let staked: u64 = user_stake.amount;
    let boost_raw: u64 = (staked * config.staking_rep_boost_per_1000) / 1000000000;
    let mut boost: u8 = 0;
    if boost_raw > 25 {
        boost = 25;
    } else {
        if boost_raw > 0 {
            // Safe narrowing: boost_raw is 0..25
            let b_trunc: u64 = boost_raw;
            if b_trunc >= 20 {
                boost = 20;
            } else {
                if b_trunc >= 15 {
                    boost = 15;
                } else {
                    if b_trunc >= 10 {
                        boost = 10;
                    } else {
                        if b_trunc >= 5 {
                            boost = 5;
                        } else {
                            boost = 1;
                        }
                    }
                }
            }
        }
    }
    return boost;
}

/// Check if user's reputation tier allows staking
/// Returns 1 if allowed, 0 if gated
pub check_rep_staking_gate(
    config: ComposerConfig,
    attestation: ReputationAttestation
) -> u8 {
    if attestation.tier >= config.rep_staking_tier_gate {
        return 1;
    }
    return 0;
}

/// Apply staking reputation boost — records pending boost for oracle to consume
pub record_staking_rep_boost(
    config: ComposerConfig,
    user_state: UserComposerState @mut,
    user: account @signer,
    user_stake: UserStake
) {
    require(config.paused == 0);
    require(user_state.user == user.key);
    require(user_stake.user == user.key);

    let clock: u64 = get_clock();
    let staked: u64 = user_stake.amount;
    let boost_raw: u64 = (staked * config.staking_rep_boost_per_1000) / 1000000000;

    let mut boost: u64 = boost_raw;
    if boost > 25 {
        boost = 25;
    }

    user_state.staking_rep_pending = boost;
    user_state.last_compose_ts = clock;
}

// ---------------------------------------------------------------------------
// Composition 2: Points <-> Achievements
// Earning points triggers achievement checks; achievements grant multipliers
// ---------------------------------------------------------------------------

/// Calculate points multiplier from achievements
/// Returns multiplier (1 = no bonus, 2 = double, etc.)
pub calc_achievement_points_multiplier(
    config: ComposerConfig,
    user_achievements: UserAchievements
) -> u64 {
    let badges: u64 = user_achievements.badges;
    let mut multiplier: u64 = 1;

    // Each badge adds +1 to multiplier, capped at config max
    // bit 0 = FIRST_LAUNCH
    let has_first: u64 = badges / 1;
    let rem_first: u64 = has_first - ((has_first / 2) * 2);
    if rem_first == 1 {
        multiplier = multiplier + 1;
    }

    // bit 1 = DIAMOND_HANDS
    let has_diamond: u64 = badges / 2;
    let rem_diamond: u64 = has_diamond - ((has_diamond / 2) * 2);
    if rem_diamond == 1 {
        multiplier = multiplier + 1;
    }

    // bit 2 = WHALE_STATUS
    let has_whale: u64 = badges / 4;
    let rem_whale: u64 = has_whale - ((has_whale / 2) * 2);
    if rem_whale == 1 {
        multiplier = multiplier + 1;
    }

    // bit 3 = DEGEN_100
    let has_degen: u64 = badges / 8;
    let rem_degen: u64 = has_degen - ((has_degen / 2) * 2);
    if rem_degen == 1 {
        multiplier = multiplier + 1;
    }

    // bit 4 = EARLY_ADOPTER
    let has_early: u64 = badges / 16;
    let rem_early: u64 = has_early - ((has_early / 2) * 2);
    if rem_early == 1 {
        multiplier = multiplier + 1;
    }

    // Cap at configured max
    if multiplier > config.points_achievement_multiplier {
        multiplier = config.points_achievement_multiplier;
    }

    return multiplier;
}

/// Check if points total unlocks new achievements
/// Returns bitflag of newly eligible badges (caller merges with existing)
pub check_points_achievements(
    user_points: UserPoints
) -> u64 {
    let mut new_badges: u64 = 0;

    // Level 5+ unlocks DEGEN_100 equivalent (bit 3 = 8)
    if user_points.level >= 5 {
        new_badges = new_badges + 8;
    }

    // Level 8+ unlocks WHALE_STATUS equivalent (bit 2 = 4)
    if user_points.level >= 8 {
        new_badges = new_badges + 4;
    }

    return new_badges;
}

// ---------------------------------------------------------------------------
// Composition 3: Lending <-> Staking
// Staked positions count as collateral; interest partially routes to staking
// ---------------------------------------------------------------------------

/// Calculate additional collateral value from staked tokens
/// Returns collateral value in base units scaled by config ratio
pub calc_staking_collateral_value(
    config: ComposerConfig,
    user_stake: UserStake
) -> u64 {
    let staked: u64 = user_stake.amount;
    let collateral: u64 = (staked * config.lending_collateral_ratio_bps) / 10000;
    return collateral;
}

/// Calculate how much lending interest should route to staking rewards
pub calc_interest_to_staking(
    config: ComposerConfig,
    lending_position: UserLendPosition
) -> u64 {
    let interest: u64 = lending_position.interest_owed;
    let to_staking: u64 = (interest * config.lending_interest_to_staking_bps) / 10000;
    return to_staking;
}

/// Record interest routing from lending to staking pool
pub record_lending_interest_route(
    config: ComposerConfig,
    user_state: UserComposerState @mut,
    user: account @signer,
    lending_position: UserLendPosition
) {
    require(config.paused == 0);
    require(user_state.user == user.key);
    require(lending_position.user == user.key);

    let interest: u64 = lending_position.interest_owed;
    let to_staking: u64 = (interest * config.lending_interest_to_staking_bps) / 10000;

    user_state.lending_interest_routed = user_state.lending_interest_routed + to_staking;

    let clock: u64 = get_clock();
    user_state.last_compose_ts = clock;
}

// ---------------------------------------------------------------------------
// Composition 4: Referral <-> Points
// Referral actions earn points; point milestones unlock referral bonuses
// ---------------------------------------------------------------------------

/// Calculate points earned from referral activity
pub calc_referral_points(
    config: ComposerConfig,
    referral_account: ReferralAccount
) -> u64 {
    let referred: u64 = referral_account.total_referred;
    let points: u64 = referred * config.referral_points_per_action;
    return points;
}

/// Check if point milestone unlocks referral bonus
/// Returns bonus amount (0 if not eligible)
pub check_referral_point_bonus(
    config: ComposerConfig,
    user_points: UserPoints
) -> u64 {
    if user_points.total_points >= config.referral_bonus_point_threshold {
        return config.referral_bonus_amount;
    }
    return 0;
}

/// Record referral points pending for award
pub record_referral_points(
    config: ComposerConfig,
    user_state: UserComposerState @mut,
    user: account @signer,
    referral_account: ReferralAccount
) {
    require(config.paused == 0);
    require(user_state.user == user.key);
    require(referral_account.user == user.key);

    let referred: u64 = referral_account.total_referred;
    let points: u64 = referred * config.referral_points_per_action;

    user_state.referral_points_pending = points;

    let clock: u64 = get_clock();
    user_state.last_compose_ts = clock;
}

// ---------------------------------------------------------------------------
// Composition 5: Reputation <-> Prediction
// Reputation gates market creation; correct predictions boost reputation
// ---------------------------------------------------------------------------

/// Check if user can create prediction market based on reputation
/// Returns 1 if allowed, 0 if not
pub check_prediction_rep_gate(
    config: ComposerConfig,
    attestation: ReputationAttestation
) -> u8 {
    if attestation.fairscore >= config.prediction_min_rep_to_create {
        return 1;
    }
    return 0;
}

/// Record reputation boost from correct prediction
pub record_prediction_rep_boost(
    config: ComposerConfig,
    user_state: UserComposerState @mut,
    user: account @signer,
    user_bet: UserBet
) {
    require(config.paused == 0);
    require(user_state.user == user.key);
    require(user_bet.user == user.key);
    // Only claimed (winning) bets boost rep
    require(user_bet.claimed == 1);

    user_state.prediction_rep_pending = config.prediction_rep_boost;

    let clock: u64 = get_clock();
    user_state.last_compose_ts = clock;
}

// ---------------------------------------------------------------------------
// Composition 6: Fee Splitting <-> Holder Rewards
// Protocol fees are partially routed to holder reward pools
// ---------------------------------------------------------------------------

/// Calculate fee amount to route to holder rewards
pub calc_fee_to_holder_rewards(
    config: ComposerConfig,
    fee_config: FeeConfig
) -> u64 {
    let total: u64 = fee_config.total_distributed;
    let to_holders: u64 = (total * config.fee_to_holder_reward_bps) / 10000;
    return to_holders;
}

/// Record fee routing to holder reward pool
pub record_fee_to_holders(
    config: ComposerConfig,
    user_state: UserComposerState @mut,
    authority: account @signer,
    fee_config: FeeConfig
) {
    require(config.paused == 0);
    require(config.authority == authority.key);

    let total: u64 = fee_config.total_distributed;
    let to_holders: u64 = (total * config.fee_to_holder_reward_bps) / 10000;

    user_state.fee_routed_to_holders = user_state.fee_routed_to_holders + to_holders;

    let clock: u64 = get_clock();
    user_state.last_compose_ts = clock;
}

// ---------------------------------------------------------------------------
// View Functions
// ---------------------------------------------------------------------------

/// Get all pending cross-module effects for a user
pub get_pending_staking_rep(
    user_state: UserComposerState
) -> u64 {
    return user_state.staking_rep_pending;
}

pub get_pending_prediction_rep(
    user_state: UserComposerState
) -> u8 {
    return user_state.prediction_rep_pending;
}

pub get_pending_referral_points(
    user_state: UserComposerState
) -> u64 {
    return user_state.referral_points_pending;
}

pub get_routed_lending_interest(
    user_state: UserComposerState
) -> u64 {
    return user_state.lending_interest_routed;
}

pub get_routed_fees_to_holders(
    user_state: UserComposerState
) -> u64 {
    return user_state.fee_routed_to_holders;
}
