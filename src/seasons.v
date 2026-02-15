// Send.it Seasons Module — ported from Anchor to 5IVE DSL

// ---------------------------------------------------------------------------
// Accounts
// ---------------------------------------------------------------------------

account Season {
    authority: pubkey;
    season_number: u64;
    start_time: u64;
    end_time: u64;
    total_participants: u64;
    prize_pool_lamports: u64;
    is_active: u8;
    is_finalized: u8;
    bump: u8;
}

account SeasonPass {
    season: pubkey;
    user: pubkey;
    xp: u64;
    level: u64;
    trades_count: u64;
    volume: u64;
    achievements_unlocked: u64;
    rewards_claimed_mask: u64;
    joined_at: u64;
    bump: u8;
}

account SeasonReward {
    season: pubkey;
    level: u64;
    min_xp: u64;
    reward_type: u8;
    reward_amount: u64;
    bump: u8;
}

// ---------------------------------------------------------------------------
// Instructions
// ---------------------------------------------------------------------------

/// Start a new season
pub start_season(
    season: Season @mut @init(payer=authority, space=256) @signer,
    authority: account @mut @signer,
    season_number: u64,
    start_time: u64,
    end_time: u64
) {
    require(end_time > start_time);

    season.authority = authority.key;
    season.season_number = season_number;
    season.start_time = start_time;
    season.end_time = end_time;
    season.total_participants = 0;
    season.prize_pool_lamports = 0;
    season.is_active = 1;
    season.is_finalized = 0;
    season.bump = 0;
}

/// Add a reward tier for a season level
pub add_season_reward(
    season: Season,
    season_reward: SeasonReward @mut @init(payer=authority, space=256) @signer,
    authority: account @mut @signer,
    level: u64,
    min_xp: u64,
    reward_type: u8,
    reward_amount: u64
) {
    require(authority.key == season.authority);

    season_reward.season = season.authority;
    season_reward.level = level;
    season_reward.min_xp = min_xp;
    season_reward.reward_type = reward_type;
    season_reward.reward_amount = reward_amount;
    season_reward.bump = 0;
}

/// Join a season
pub join_season(
    season: Season @mut,
    season_pass: SeasonPass @mut @init(payer=user, space=256) @signer,
    user: account @mut @signer
) {
    require(season.is_active == 1);

    let clock: u64 = get_clock();

    season_pass.season = season.authority;
    season_pass.user = user.key;
    season_pass.xp = 0;
    season_pass.level = 0;
    season_pass.trades_count = 0;
    season_pass.volume = 0;
    season_pass.achievements_unlocked = 0;
    season_pass.rewards_claimed_mask = 0;
    season_pass.joined_at = clock;
    season_pass.bump = 0;

    season.total_participants = season.total_participants + 1;
}

/// Record XP from actions
pub record_season_xp(
    season: Season,
    season_pass: SeasonPass @mut,
    user: account @signer,
    xp_amount: u64,
    source: u8,
    trade_volume_lamports: u64
) {
    require(season.is_active == 1);
    require(season_pass.user == user.key);

    season_pass.xp = season_pass.xp + xp_amount;

    // Update trade stats if source is TradeVolume (0)
    if source == 0 {
        season_pass.trades_count = season_pass.trades_count + 1;
        season_pass.volume = season_pass.volume + trade_volume_lamports;
    }

    // Simple level calculation: level = xp / 100
    season_pass.level = season_pass.xp / 100;
}

/// Claim a reward for reaching a specific level
pub claim_season_reward(
    season: Season @mut,
    season_pass: SeasonPass @mut,
    season_reward: SeasonReward,
    user: account @mut @signer
) {
    require(season_pass.user == user.key);
    require(season_pass.xp >= season_reward.min_xp);

    // Mark as claimed (simplified — full bitflag not feasible without bitwise ops)
    // Record the level in rewards_claimed_mask as a simple counter
    season_pass.rewards_claimed_mask = season_pass.rewards_claimed_mask + 1;
}

/// End a season (authority only)
pub end_season(
    season: Season @mut,
    authority: account @signer
) {
    require(authority.key == season.authority);
    require(season.is_active == 1);

    let clock: u64 = get_clock();
    require(clock >= season.end_time);

    season.is_active = 0;
    season.is_finalized = 1;
}

/// Fund the season prize pool (tracking only — SOL transfer via SDK)
pub fund_season(
    season: Season @mut,
    funder: account @mut @signer,
    lamports: u64
) {
    require(lamports > 0);
    season.prize_pool_lamports = season.prize_pool_lamports + lamports;
}

/// View: get season info
pub get_season_info(
    season: Season
) -> u64 {
    return season.total_participants;
}
