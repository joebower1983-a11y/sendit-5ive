// Send.it Holder Rewards Module — ported from Anchor to 5IVE DSL
// Simplified: no u128, no i64, no bool, no events

account RewardPool {
    mint: pubkey;
    authority: pubkey;
    reward_per_token_stored: u64;
    total_supply_eligible: u64;
    last_update_ts: u64;
    min_hold_seconds: u64;
    reward_fee_bps: u64;
    bump: u8;
    vault_bump: u8;
}

account UserRewardState {
    user: pubkey;
    mint: pubkey;
    reward_per_token_paid: u64;
    rewards_earned: u64;
    balance: u64;
    first_hold_ts: u64;
    auto_compound: u8;
    bump: u8;
}

pub initialize_reward_pool(
    pool: RewardPool @mut @init(payer=authority, space=256) @signer,
    authority: account @mut @signer,
    mint: pubkey,
    reward_fee_bps: u64,
    min_hold_seconds: u64
) {
    require(reward_fee_bps <= 10000);

    let clock: u64 = get_clock();
    pool.mint = mint;
    pool.authority = authority.key;
    pool.reward_per_token_stored = 0;
    pool.total_supply_eligible = 0;
    pool.last_update_ts = clock;
    pool.min_hold_seconds = min_hold_seconds;
    pool.reward_fee_bps = reward_fee_bps;
    pool.bump = 0;
    pool.vault_bump = 0;
}

pub accrue_rewards(
    pool: RewardPool @mut,
    authority: account @signer,
    reward_amount: u64
) {
    require(pool.authority == authority.key);

    if pool.total_supply_eligible > 0 {
        let scaled: u64 = reward_amount * 1000000000000;
        let increment: u64 = scaled / pool.total_supply_eligible;
        pool.reward_per_token_stored = pool.reward_per_token_stored + increment;
    }

    let clock: u64 = get_clock();
    pool.last_update_ts = clock;
}

pub update_user_reward_state(
    pool: RewardPool @mut,
    user_state: UserRewardState @mut,
    authority: account @signer,
    user_key: pubkey,
    new_balance: u64
) {
    require(pool.authority == authority.key);

    // First time init
    if user_state.user == 0 {
        user_state.user = user_key;
        user_state.mint = pool.mint;
        user_state.reward_per_token_paid = pool.reward_per_token_stored;
        let clock: u64 = get_clock();
        user_state.first_hold_ts = clock;
        user_state.bump = 0;
    }

    // Calculate pending rewards
    if user_state.balance > 0 {
        let delta: u64 = pool.reward_per_token_stored - user_state.reward_per_token_paid;
        let pending: u64 = (user_state.balance * delta) / 1000000000000;
        user_state.rewards_earned = user_state.rewards_earned + pending;
    }
    user_state.reward_per_token_paid = pool.reward_per_token_stored;

    // Update eligible supply
    if pool.total_supply_eligible >= user_state.balance {
        pool.total_supply_eligible = pool.total_supply_eligible - user_state.balance;
    }
    pool.total_supply_eligible = pool.total_supply_eligible + new_balance;

    let old_balance: u64 = user_state.balance;
    user_state.balance = new_balance;

    if old_balance == 0 {
        if new_balance > 0 {
            let clock2: u64 = get_clock();
            user_state.first_hold_ts = clock2;
        }
    }
    if new_balance == 0 {
        user_state.first_hold_ts = 0;
    }
}

pub claim_holder_rewards(
    pool: RewardPool,
    user_state: UserRewardState @mut,
    user: account @signer
) -> u64 {
    require(user_state.user == user.key);

    // Settle pending
    if user_state.balance > 0 {
        let delta: u64 = pool.reward_per_token_stored - user_state.reward_per_token_paid;
        let pending: u64 = (user_state.balance * delta) / 1000000000000;
        user_state.rewards_earned = user_state.rewards_earned + pending;
    }

    let total_claimable: u64 = user_state.rewards_earned;
    require(total_claimable > 0);

    // Check min hold time
    if pool.min_hold_seconds > 0 {
        if user_state.balance > 0 {
            let clock: u64 = get_clock();
            let held_for: u64 = clock - user_state.first_hold_ts;
            require(held_for >= pool.min_hold_seconds);
        }
    }

    user_state.rewards_earned = 0;
    user_state.reward_per_token_paid = pool.reward_per_token_stored;

    return total_claimable;
}

pub toggle_auto_compound(
    user_state: UserRewardState @mut,
    user: account @signer,
    enabled: u8
) {
    require(user_state.user == user.key);
    user_state.auto_compound = enabled;
}

pub get_pending_holder_rewards(
    pool: RewardPool,
    user_state: UserRewardState
) -> u64 {
    if user_state.balance == 0 {
        return user_state.rewards_earned;
    }
    let delta: u64 = pool.reward_per_token_stored - user_state.reward_per_token_paid;
    let pending: u64 = (user_state.balance * delta) / 1000000000000;
    return user_state.rewards_earned + pending;
}
