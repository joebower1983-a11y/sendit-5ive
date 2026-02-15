interface Token2022 @program("TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb") {
    @discriminator(3)
    spl_transfer(from: account @mut, to: account @mut, authority: account @signer, amount: u64);
}
// Send.it PYUSD Vault Module
// Dedicated integrations for PayPal USD (PYUSD) on Solana
//
// PYUSD Mainnet Mint: 2b1kV6DkPAnxd5ixfnxCpjxmKwqjjaYmCZfHsFu24GXo
// PYUSD is a Token-2022 stablecoin issued by PayPal
//
// Features:
//   1. PYUSD Savings Vault — deposit PYUSD, earn yield from lending pool interest
//   2. On-ramp Tracking — track PayPal → Solana PYUSD flows for analytics
//   3. PYUSD/SENDIT Liquidity Incentives — bonus points for LPs
//   4. Stablecoin Swap Helper — PYUSD ↔ USDC at near 1:1

// ---------------------------------------------------------------------------
// Accounts
// ---------------------------------------------------------------------------

account PyusdSavingsVault {
    authority: pubkey;
    pyusd_mint: pubkey;
    vault_token_account: pubkey;
    total_deposited: u64;
    total_yield_earned: u64;
    yield_rate_bps: u64;
    last_yield_update: u64;
    yield_per_share_stored: u64;
    paused: u8;
    bump: u8;
}

account PyusdSaverPosition {
    owner: pubkey;
    vault: pubkey;
    deposited: u64;
    yield_earned: u64;
    yield_per_share_paid: u64;
    deposit_timestamp: u64;
    bump: u8;
}

account OnRampRecord {
    user: pubkey;
    total_onramped: u64;
    total_transactions: u64;
    last_onramp_time: u64;
    bump: u8;
}

account LiquidityIncentive {
    authority: pubkey;
    pyusd_sendit_pair: pubkey;
    bonus_points_per_epoch: u64;
    epoch_duration: u64;
    current_epoch_start: u64;
    total_points_distributed: u64;
    paused: u8;
    bump: u8;
}

account UserIncentivePosition {
    owner: pubkey;
    incentive: pubkey;
    lp_shares_staked: u64;
    points_earned: u64;
    last_claim_epoch: u64;
    bump: u8;
}

account StableSwapPool {
    authority: pubkey;
    mint_a: pubkey;
    mint_b: pubkey;
    vault_a: pubkey;
    vault_b: pubkey;
    reserve_a: u64;
    reserve_b: u64;
    fee_bps: u64;
    total_swapped: u64;
    paused: u8;
    bump: u8;
}

// ---------------------------------------------------------------------------
// 1. PYUSD Savings Vault
// ---------------------------------------------------------------------------

/// Initialize a PYUSD savings vault
pub create_pyusd_savings_vault(
    vault: PyusdSavingsVault @mut @init(payer=authority, space=256) @signer,
    authority: account @mut @signer,
    pyusd_mint: pubkey,
    vault_token_account: pubkey,
    yield_rate_bps: u64
) {
    require(yield_rate_bps > 0);
    require(yield_rate_bps <= 2000);

    let clock: u64 = get_clock();

    vault.authority = authority.key;
    vault.pyusd_mint = pyusd_mint;
    vault.vault_token_account = vault_token_account;
    vault.total_deposited = 0;
    vault.total_yield_earned = 0;
    vault.yield_rate_bps = yield_rate_bps;
    vault.last_yield_update = clock;
    vault.yield_per_share_stored = 0;
    vault.paused = 0;
    vault.bump = 0;
}

/// Deposit PYUSD into savings vault
pub deposit_pyusd_savings(
    vault: PyusdSavingsVault @mut,
    position: PyusdSaverPosition @mut @init(payer=user, space=256) @signer,
    user: account @mut @signer,
    user_pyusd_account: account @mut,
    vault_pyusd_account: account @mut,
    token_program: account,
    amount: u64
) {
    require(amount > 0);
    require(vault.paused == 0);

    let clock: u64 = get_clock();

    // Update yield accumulator
    if vault.total_deposited > 0 {
        let elapsed: u64 = clock - vault.last_yield_update;
        let additional: u64 = (elapsed * vault.yield_rate_bps) / vault.total_deposited;
        vault.yield_per_share_stored = vault.yield_per_share_stored + additional;
    }
    vault.last_yield_update = clock;

    // Settle pending yield for user
    if position.deposited > 0 {
        let diff: u64 = vault.yield_per_share_stored - position.yield_per_share_paid;
        let pending: u64 = (position.deposited * diff) / 1000000000000;
        position.yield_earned = position.yield_earned + pending;
    }
    position.yield_per_share_paid = vault.yield_per_share_stored;

    // Transfer PYUSD into vault
    Token2022.spl_transfer(user_pyusd_account, vault_pyusd_account, user, amount);

    position.owner = user.key;
    position.vault = vault.authority;
    position.deposited = position.deposited + amount;
    if position.deposit_timestamp == 0 {
        position.deposit_timestamp = clock;
    }
    position.bump = 0;

    vault.total_deposited = vault.total_deposited + amount;
}

/// Withdraw PYUSD from savings vault
pub withdraw_pyusd_savings(
    vault: PyusdSavingsVault @mut,
    position: PyusdSaverPosition @mut,
    user: account @mut @signer,
    user_pyusd_account: account @mut,
    vault_pyusd_account: account @mut,
    vault_authority: account @signer,
    token_program: account,
    amount: u64
) {
    require(amount > 0);
    require(position.owner == user.key);
    require(position.deposited >= amount);

    let clock: u64 = get_clock();

    // Update yield accumulator
    if vault.total_deposited > 0 {
        let elapsed: u64 = clock - vault.last_yield_update;
        let additional: u64 = (elapsed * vault.yield_rate_bps) / vault.total_deposited;
        vault.yield_per_share_stored = vault.yield_per_share_stored + additional;
    }
    vault.last_yield_update = clock;

    // Settle pending yield
    if position.deposited > 0 {
        let diff: u64 = vault.yield_per_share_stored - position.yield_per_share_paid;
        let pending: u64 = (position.deposited * diff) / 1000000000000;
        position.yield_earned = position.yield_earned + pending;
    }
    position.yield_per_share_paid = vault.yield_per_share_stored;

    // Transfer PYUSD back to user
    Token2022.spl_transfer(vault_pyusd_account, user_pyusd_account, vault_authority, amount);

    position.deposited = position.deposited - amount;
    vault.total_deposited = vault.total_deposited - amount;
}

/// Claim accrued yield from savings vault
pub claim_pyusd_yield(
    vault: PyusdSavingsVault @mut,
    position: PyusdSaverPosition @mut,
    user: account @mut @signer,
    user_pyusd_account: account @mut,
    vault_pyusd_account: account @mut,
    vault_authority: account @signer,
    token_program: account
) {
    require(position.owner == user.key);

    let clock: u64 = get_clock();

    // Update yield accumulator
    if vault.total_deposited > 0 {
        let elapsed: u64 = clock - vault.last_yield_update;
        let additional: u64 = (elapsed * vault.yield_rate_bps) / vault.total_deposited;
        vault.yield_per_share_stored = vault.yield_per_share_stored + additional;
    }
    vault.last_yield_update = clock;

    // Settle pending yield
    if position.deposited > 0 {
        let diff: u64 = vault.yield_per_share_stored - position.yield_per_share_paid;
        let pending: u64 = (position.deposited * diff) / 1000000000000;
        position.yield_earned = position.yield_earned + pending;
    }
    position.yield_per_share_paid = vault.yield_per_share_stored;

    let yield_amount: u64 = position.yield_earned;
    require(yield_amount > 0);

    position.yield_earned = 0;
    vault.total_yield_earned = vault.total_yield_earned + yield_amount;

    Token2022.spl_transfer(vault_pyusd_account, user_pyusd_account, vault_authority, yield_amount);
}

/// View: get pending yield for a user
pub get_pending_pyusd_yield(
    vault: PyusdSavingsVault,
    position: PyusdSaverPosition
) -> u64 {
    let clock: u64 = get_clock();
    let mut yps: u64 = vault.yield_per_share_stored;

    if vault.total_deposited > 0 {
        let elapsed: u64 = clock - vault.last_yield_update;
        let additional: u64 = (elapsed * vault.yield_rate_bps) / vault.total_deposited;
        yps = yps + additional;
    }

    let diff: u64 = yps - position.yield_per_share_paid;
    let pending: u64 = (position.deposited * diff) / 1000000000000;
    return position.yield_earned + pending;
}

// ---------------------------------------------------------------------------
// 2. On-Ramp Tracking (PayPal → Solana PYUSD analytics)
// ---------------------------------------------------------------------------

/// Record an on-ramp event (called by oracle/crank after detecting PayPal→Solana transfer)
pub record_onramp(
    record: OnRampRecord @mut @init(payer=user, space=128) @signer,
    user: account @mut @signer,
    amount: u64
) {
    require(amount > 0);

    let clock: u64 = get_clock();

    record.user = user.key;
    record.total_onramped = record.total_onramped + amount;
    record.total_transactions = record.total_transactions + 1;
    record.last_onramp_time = clock;
    record.bump = 0;
}

/// View: get total on-ramped amount for a user
pub get_total_onramped(
    record: OnRampRecord
) -> u64 {
    return record.total_onramped;
}

// ---------------------------------------------------------------------------
// 3. PYUSD/SENDIT Liquidity Incentives
// ---------------------------------------------------------------------------

/// Create a liquidity incentive program for PYUSD/SENDIT pair
pub create_liquidity_incentive(
    incentive: LiquidityIncentive @mut @init(payer=authority, space=256) @signer,
    authority: account @mut @signer,
    pyusd_sendit_pair: pubkey,
    bonus_points_per_epoch: u64,
    epoch_duration: u64
) {
    require(bonus_points_per_epoch > 0);
    require(epoch_duration > 0);

    let clock: u64 = get_clock();

    incentive.authority = authority.key;
    incentive.pyusd_sendit_pair = pyusd_sendit_pair;
    incentive.bonus_points_per_epoch = bonus_points_per_epoch;
    incentive.epoch_duration = epoch_duration;
    incentive.current_epoch_start = clock;
    incentive.total_points_distributed = 0;
    incentive.paused = 0;
    incentive.bump = 0;
}

/// Stake LP shares to earn bonus points
pub stake_lp_for_incentive(
    incentive: LiquidityIncentive @mut,
    user_position: UserIncentivePosition @mut @init(payer=user, space=256) @signer,
    user: account @mut @signer,
    lp_shares: u64
) {
    require(lp_shares > 0);
    require(incentive.paused == 0);

    let clock: u64 = get_clock();

    user_position.owner = user.key;
    user_position.incentive = incentive.authority;
    user_position.lp_shares_staked = user_position.lp_shares_staked + lp_shares;
    user_position.bump = 0;
}

/// Claim bonus points for providing PYUSD/SENDIT liquidity
pub claim_incentive_points(
    incentive: LiquidityIncentive @mut,
    user_position: UserIncentivePosition @mut,
    user: account @signer
) {
    require(user_position.owner == user.key);
    require(user_position.lp_shares_staked > 0);
    require(incentive.paused == 0);

    let clock: u64 = get_clock();

    // Check epoch has passed
    let epoch_end: u64 = incentive.current_epoch_start + incentive.epoch_duration;
    require(clock >= epoch_end);

    // Points proportional to LP shares (simplified: flat bonus per epoch)
    let points: u64 = incentive.bonus_points_per_epoch;

    user_position.points_earned = user_position.points_earned + points;
    user_position.last_claim_epoch = clock;
    incentive.total_points_distributed = incentive.total_points_distributed + points;
    incentive.current_epoch_start = clock;
}

/// View: get user incentive points
pub get_incentive_points(
    user_position: UserIncentivePosition
) -> u64 {
    return user_position.points_earned;
}

// ---------------------------------------------------------------------------
// 4. Stablecoin Swap Helper (PYUSD ↔ USDC at 1:1 minus fee)
// ---------------------------------------------------------------------------

/// Create a stablecoin swap pool (PYUSD ↔ USDC)
pub create_stable_swap_pool(
    pool: StableSwapPool @mut @init(payer=authority, space=256) @signer,
    authority: account @mut @signer,
    mint_a: pubkey,
    mint_b: pubkey,
    vault_a: pubkey,
    vault_b: pubkey,
    fee_bps: u64
) {
    // Stablecoin swap should have very low fee (1-5 bps)
    require(fee_bps <= 50);

    pool.authority = authority.key;
    pool.mint_a = mint_a;
    pool.mint_b = mint_b;
    pool.vault_a = vault_a;
    pool.vault_b = vault_b;
    pool.reserve_a = 0;
    pool.reserve_b = 0;
    pool.fee_bps = fee_bps;
    pool.total_swapped = 0;
    pool.paused = 0;
    pool.bump = 0;
}

/// Add liquidity to the stable swap pool (equal amounts of both stables)
pub add_stable_swap_liquidity(
    pool: StableSwapPool @mut,
    provider: account @mut @signer,
    provider_a_account: account @mut,
    provider_b_account: account @mut,
    vault_a: account @mut,
    vault_b: account @mut,
    token_program: account,
    amount_a: u64,
    amount_b: u64
) {
    require(amount_a > 0);
    require(amount_b > 0);
    require(pool.paused == 0);

    Token2022.spl_transfer(provider_a_account, vault_a, provider, amount_a);
    Token2022.spl_transfer(provider_b_account, vault_b, provider, amount_b);

    pool.reserve_a = pool.reserve_a + amount_a;
    pool.reserve_b = pool.reserve_b + amount_b;
}

/// Swap mint_a for mint_b (e.g. PYUSD → USDC)
/// Uses 1:1 rate minus fee (stableswap curve)
pub swap_a_for_b(
    pool: StableSwapPool @mut,
    user: account @mut @signer,
    user_a_account: account @mut,
    user_b_account: account @mut,
    vault_a: account @mut,
    vault_b: account @mut,
    vault_authority: account @signer,
    token_program: account,
    amount_in: u64,
    min_amount_out: u64
) {
    require(amount_in > 0);
    require(pool.paused == 0);

    let fee: u64 = (amount_in * pool.fee_bps) / 10000;
    let amount_out: u64 = amount_in - fee;

    require(amount_out >= min_amount_out);
    require(pool.reserve_b >= amount_out);

    Token2022.spl_transfer(user_a_account, vault_a, user, amount_in);
    Token2022.spl_transfer(vault_b, user_b_account, vault_authority, amount_out);

    pool.reserve_a = pool.reserve_a + amount_in;
    pool.reserve_b = pool.reserve_b - amount_out;
    pool.total_swapped = pool.total_swapped + amount_in;
}

/// Swap mint_b for mint_a (e.g. USDC → PYUSD)
pub swap_b_for_a(
    pool: StableSwapPool @mut,
    user: account @mut @signer,
    user_a_account: account @mut,
    user_b_account: account @mut,
    vault_a: account @mut,
    vault_b: account @mut,
    vault_authority: account @signer,
    token_program: account,
    amount_in: u64,
    min_amount_out: u64
) {
    require(amount_in > 0);
    require(pool.paused == 0);

    let fee: u64 = (amount_in * pool.fee_bps) / 10000;
    let amount_out: u64 = amount_in - fee;

    require(amount_out >= min_amount_out);
    require(pool.reserve_a >= amount_out);

    Token2022.spl_transfer(user_b_account, vault_b, user, amount_in);
    Token2022.spl_transfer(vault_a, user_a_account, vault_authority, amount_out);

    pool.reserve_b = pool.reserve_b + amount_in;
    pool.reserve_a = pool.reserve_a - amount_out;
    pool.total_swapped = pool.total_swapped + amount_in;
}

/// Pause/unpause stable swap pool
pub set_stable_swap_paused(
    pool: StableSwapPool @mut,
    authority: account @signer,
    paused: u8
) {
    require(authority.key == pool.authority);
    pool.paused = paused;
}

/// View: get swap output amount (1:1 minus fee)
pub get_stable_swap_output(
    pool: StableSwapPool,
    amount_in: u64
) -> u64 {
    let fee: u64 = (amount_in * pool.fee_bps) / 10000;
    return amount_in - fee;
}
