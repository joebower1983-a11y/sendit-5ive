// Send.it Staking Module — ported from Anchor to 5IVE DSL
// With SPL Token CPI for actual token transfers

// ---------------------------------------------------------------------------
// SPL Token-2022 CPI Interface
// ---------------------------------------------------------------------------

interface Token2022 @program("TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb") {
    @discriminator(3)
    spl_transfer(from: account @mut, to: account @mut, authority: account @signer, amount: u64);
}

// ---------------------------------------------------------------------------
// Accounts
// ---------------------------------------------------------------------------

account StakePool {
    mint: pubkey;
    creator: pubkey;
    vault: pubkey;
    total_staked: u64;
    reward_rate: u64;
    reward_per_token_stored: u64;
    last_update: u64;
    graduated: u8;
    bump: u8;
    vault_bump: u8;
}

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

// ---------------------------------------------------------------------------
// Instructions
// ---------------------------------------------------------------------------

/// Create a stake pool for a graduated token
pub create_stake_pool(
    stake_pool: StakePool @mut @init(payer=creator, space=256) @signer,
    creator: account @mut @signer,
    mint: account,
    vault: account,
    reward_rate: u64
) {
    require(reward_rate > 0);

    let clock: u64 = get_clock();

    stake_pool.mint = mint.key;
    stake_pool.creator = creator.key;
    stake_pool.vault = vault.key;
    stake_pool.total_staked = 0;
    stake_pool.reward_rate = reward_rate;
    stake_pool.reward_per_token_stored = 0;
    stake_pool.last_update = clock;
    stake_pool.graduated = 1;
    stake_pool.bump = 0;
    stake_pool.vault_bump = 0;
}

/// Stake tokens into the pool
pub stake_tokens(
    stake_pool: StakePool @mut,
    user_stake: UserStake @mut @init(payer=user, space=256) @signer,
    user: account @mut @signer,
    user_token_account: account @mut,
    vault_token_account: account @mut,
    token_program: account,
    amount: u64
) {
    require(amount > 0);

    let clock: u64 = get_clock();

    // Update global reward accumulator
    if stake_pool.total_staked > 0 {
        let elapsed: u64 = clock - stake_pool.last_update;
        let additional: u64 = (elapsed * stake_pool.reward_rate) / stake_pool.total_staked;
        stake_pool.reward_per_token_stored = stake_pool.reward_per_token_stored + additional;
    }
    stake_pool.last_update = clock;

    // Settle pending user rewards
    if user_stake.amount > 0 {
        let diff: u64 = stake_pool.reward_per_token_stored - user_stake.reward_per_token_paid;
        let pending: u64 = (user_stake.amount * diff) / 1000000000000;
        user_stake.rewards_earned = user_stake.rewards_earned + pending;
    }
    user_stake.reward_per_token_paid = stake_pool.reward_per_token_stored;

    // CPI transfer from user_token_account to vault_token_account
    Token2022.spl_transfer(user_token_account, vault_token_account, user, amount);

    // Update balances
    user_stake.amount = user_stake.amount + amount;
    if user_stake.start_time == 0 {
        user_stake.start_time = clock;
    }
    stake_pool.total_staked = stake_pool.total_staked + amount;

    // Set user reference
    user_stake.user = user.key;
    user_stake.mint = stake_pool.mint;
    user_stake.pool = stake_pool.mint;
    user_stake.bump = 0;
}

/// Unstake tokens from the pool
pub unstake_tokens(
    stake_pool: StakePool @mut,
    user_stake: UserStake @mut,
    user: account @mut @signer,
    user_token_account: account @mut,
    vault_token_account: account @mut,
    vault_authority: account @signer,
    token_program: account,
    amount: u64
) {
    require(amount > 0);
    require(user_stake.amount >= amount);
    require(user_stake.user == user.key);

    let clock: u64 = get_clock();

    // Update global reward accumulator
    if stake_pool.total_staked > 0 {
        let elapsed: u64 = clock - stake_pool.last_update;
        let additional: u64 = (elapsed * stake_pool.reward_rate) / stake_pool.total_staked;
        stake_pool.reward_per_token_stored = stake_pool.reward_per_token_stored + additional;
    }
    stake_pool.last_update = clock;

    // Settle pending user rewards
    if user_stake.amount > 0 {
        let diff: u64 = stake_pool.reward_per_token_stored - user_stake.reward_per_token_paid;
        let pending: u64 = (user_stake.amount * diff) / 1000000000000;
        user_stake.rewards_earned = user_stake.rewards_earned + pending;
    }
    user_stake.reward_per_token_paid = stake_pool.reward_per_token_stored;

    // CPI transfer from vault_token_account to user_token_account
    Token2022.spl_transfer(vault_token_account, user_token_account, vault_authority, amount);

    // Update balances
    user_stake.amount = user_stake.amount - amount;
    stake_pool.total_staked = stake_pool.total_staked - amount;
}

/// Claim accumulated staking rewards
pub claim_staking_rewards(
    stake_pool: StakePool @mut,
    user_stake: UserStake @mut,
    user: account @mut @signer,
    user_token_account: account @mut,
    vault_token_account: account @mut,
    vault_authority: account @signer,
    token_program: account
) {
    require(user_stake.user == user.key);

    let clock: u64 = get_clock();

    // Update global reward accumulator
    if stake_pool.total_staked > 0 {
        let elapsed: u64 = clock - stake_pool.last_update;
        let additional: u64 = (elapsed * stake_pool.reward_rate) / stake_pool.total_staked;
        stake_pool.reward_per_token_stored = stake_pool.reward_per_token_stored + additional;
    }
    stake_pool.last_update = clock;

    // Settle pending user rewards
    if user_stake.amount > 0 {
        let diff: u64 = stake_pool.reward_per_token_stored - user_stake.reward_per_token_paid;
        let pending: u64 = (user_stake.amount * diff) / 1000000000000;
        user_stake.rewards_earned = user_stake.rewards_earned + pending;
    }
    user_stake.reward_per_token_paid = stake_pool.reward_per_token_stored;

    let rewards: u64 = user_stake.rewards_earned;
    require(rewards > 0);

    user_stake.rewards_earned = 0;

    // CPI transfer reward tokens from vault to user
    Token2022.spl_transfer(vault_token_account, user_token_account, vault_authority, rewards);
}

/// Get the pending rewards for a user (view-like)
pub get_pending_rewards(
    stake_pool: StakePool,
    user_stake: UserStake
) -> u64 {
    let clock: u64 = get_clock();
    let mut rpt: u64 = stake_pool.reward_per_token_stored;

    if stake_pool.total_staked > 0 {
        let elapsed: u64 = clock - stake_pool.last_update;
        let additional: u64 = (elapsed * stake_pool.reward_rate) / stake_pool.total_staked;
        rpt = rpt + additional;
    }

    let diff: u64 = rpt - user_stake.reward_per_token_paid;
    let pending: u64 = (user_stake.amount * diff) / 1000000000000;
    return user_stake.rewards_earned + pending;
}
