interface Token2022 @program("TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb") {
    @discriminator(3)
    spl_transfer(from: account @mut, to: account @mut, authority: account @signer, amount: u64);
}
// Send.it Stable Pairs Module — ported from Anchor to 5IVE DSL
// Constant-product AMM for token/stablecoin pairs
//
// Supported stablecoin mints (Token-2022):
//   PYUSD (PayPal USD) — Mainnet: 2b1kV6DkPAnxd5ixfnxCpjxmKwqjjaYmCZfHsFu24GXo
//   USDC, USDT, and any Token-2022 compatible mint
//
// Example pairs:
//   PYUSD/SOL  — create_stable_pair(token_mint=SOL_MINT, stable_mint=PYUSD_MINT, fee_bps=10)
//   PYUSD/USDC — create_stable_pair(token_mint=PYUSD_MINT, stable_mint=USDC_MINT, fee_bps=5)
//                Low fee recommended for stablecoin-to-stablecoin pairs
//   TOKEN/PYUSD — any graduated token paired against PYUSD


// ---------------------------------------------------------------------------
// Accounts
// ---------------------------------------------------------------------------

account StablePairConfig {
    token_mint: pubkey;
    stable_mint: pubkey;
    pool_token_reserve: u64;
    pool_stable_reserve: u64;
    fee_bps: u64;
    creator: pubkey;
    total_lp_shares: u64;
    paused: u8;
    bump: u8;
    token_vault_bump: u8;
    stable_vault_bump: u8;
}

account LPPosition {
    pair: pubkey;
    owner: pubkey;
    lp_shares: u64;
    bump: u8;
}

// ---------------------------------------------------------------------------
// Instructions
// ---------------------------------------------------------------------------

/// Create a new token/stablecoin pair
pub create_stable_pair(
    stable_pair: StablePairConfig @mut @init(payer=creator, space=256) @signer,
    creator: account @mut @signer,
    token_mint: pubkey,
    stable_mint: pubkey,
    fee_bps: u64
) {
    require(fee_bps <= 500);

    stable_pair.token_mint = token_mint;
    stable_pair.stable_mint = stable_mint;
    stable_pair.pool_token_reserve = 0;
    stable_pair.pool_stable_reserve = 0;
    stable_pair.fee_bps = fee_bps;
    stable_pair.creator = creator.key;
    stable_pair.total_lp_shares = 0;
    stable_pair.paused = 0;
    stable_pair.bump = 0;
    stable_pair.token_vault_bump = 0;
    stable_pair.stable_vault_bump = 0;
}

/// Swap token for stablecoin
pub swap_token_for_stable(
    stable_pair: StablePairConfig @mut,
    user: account @mut @signer,
    user_token_account: account @mut,
    user_stable_account: account @mut,
    token_vault: account @mut,
    stable_vault: account @mut,
    vault_authority: account @signer,
    token_program: account,
    amount_in: u64,
    min_amount_out: u64
) {
    require(amount_in > 0);
    require(stable_pair.paused == 0);
    require(stable_pair.pool_token_reserve > 0);
    require(stable_pair.pool_stable_reserve > 0);

    // Compute fee
    let fee: u64 = (amount_in * stable_pair.fee_bps) / 10000;
    let amount_in_after_fee: u64 = amount_in - fee;

    // Constant product: amount_out = reserve_out * amount_in_after_fee / (reserve_in + amount_in_after_fee)
    let numerator: u64 = stable_pair.pool_stable_reserve * amount_in_after_fee;
    let denominator: u64 = stable_pair.pool_token_reserve + amount_in_after_fee;
    let amount_out: u64 = numerator / denominator;

    require(amount_out > 0);
    require(amount_out >= min_amount_out);

    // Transfer tokens in
    Token2022.spl_transfer(user_token_account, token_vault, user, amount_in);

    // Transfer stables out
    Token2022.spl_transfer(stable_vault, user_stable_account, vault_authority, amount_out);

    // Update reserves
    stable_pair.pool_token_reserve = stable_pair.pool_token_reserve + amount_in;
    stable_pair.pool_stable_reserve = stable_pair.pool_stable_reserve - amount_out;
}

/// Swap stablecoin for token
pub swap_stable_for_token(
    stable_pair: StablePairConfig @mut,
    user: account @mut @signer,
    user_stable_account: account @mut,
    user_token_account: account @mut,
    stable_vault: account @mut,
    token_vault: account @mut,
    vault_authority: account @signer,
    token_program: account,
    amount_in: u64,
    min_amount_out: u64
) {
    require(amount_in > 0);
    require(stable_pair.paused == 0);
    require(stable_pair.pool_token_reserve > 0);
    require(stable_pair.pool_stable_reserve > 0);

    // Compute fee
    let fee: u64 = (amount_in * stable_pair.fee_bps) / 10000;
    let amount_in_after_fee: u64 = amount_in - fee;

    // Constant product
    let numerator: u64 = stable_pair.pool_token_reserve * amount_in_after_fee;
    let denominator: u64 = stable_pair.pool_stable_reserve + amount_in_after_fee;
    let amount_out: u64 = numerator / denominator;

    require(amount_out > 0);
    require(amount_out >= min_amount_out);

    // Transfer stables in
    Token2022.spl_transfer(user_stable_account, stable_vault, user, amount_in);

    // Transfer tokens out
    Token2022.spl_transfer(token_vault, user_token_account, vault_authority, amount_out);

    // Update reserves
    stable_pair.pool_stable_reserve = stable_pair.pool_stable_reserve + amount_in;
    stable_pair.pool_token_reserve = stable_pair.pool_token_reserve - amount_out;
}

/// Add liquidity to a stable pair
pub add_liquidity(
    stable_pair: StablePairConfig @mut,
    lp_position: LPPosition @mut @init(payer=provider, space=128) @signer,
    provider: account @mut @signer,
    user_token_account: account @mut,
    user_stable_account: account @mut,
    token_vault: account @mut,
    stable_vault: account @mut,
    token_program: account,
    token_amount: u64,
    stable_amount: u64
) {
    require(token_amount > 0);
    require(stable_amount > 0);
    require(stable_pair.paused == 0);

    // Calculate LP shares
    let mut lp_shares: u64 = 0;
    if stable_pair.total_lp_shares == 0 {
        // First deposit: shares = sqrt(token * stable) approximated
        // Simple approximation: shares = (token + stable) / 2
        lp_shares = (token_amount + stable_amount) / 2;
        require(lp_shares >= 1000);
    } else {
        // Proportional: min(dT/T, dS/S) * total
        let share_by_token: u64 = (token_amount * stable_pair.total_lp_shares) / stable_pair.pool_token_reserve;
        let share_by_stable: u64 = (stable_amount * stable_pair.total_lp_shares) / stable_pair.pool_stable_reserve;
        if share_by_token < share_by_stable {
            lp_shares = share_by_token;
        } else {
            lp_shares = share_by_stable;
        }
    }
    require(lp_shares > 0);

    // Transfer tokens in
    Token2022.spl_transfer(user_token_account, token_vault, provider, token_amount);
    Token2022.spl_transfer(user_stable_account, stable_vault, provider, stable_amount);

    // Update reserves
    stable_pair.pool_token_reserve = stable_pair.pool_token_reserve + token_amount;
    stable_pair.pool_stable_reserve = stable_pair.pool_stable_reserve + stable_amount;
    stable_pair.total_lp_shares = stable_pair.total_lp_shares + lp_shares;

    // Update LP position
    lp_position.pair = stable_pair.creator;
    lp_position.owner = provider.key;
    lp_position.lp_shares = lp_position.lp_shares + lp_shares;
    lp_position.bump = 0;
}

/// Remove liquidity from a stable pair
pub remove_liquidity(
    stable_pair: StablePairConfig @mut,
    lp_position: LPPosition @mut,
    provider: account @mut @signer,
    user_token_account: account @mut,
    user_stable_account: account @mut,
    token_vault: account @mut,
    stable_vault: account @mut,
    vault_authority: account @signer,
    token_program: account,
    lp_shares_to_burn: u64,
    min_token_out: u64,
    min_stable_out: u64
) {
    require(lp_shares_to_burn > 0);
    require(lp_position.owner == provider.key);
    require(lp_position.lp_shares >= lp_shares_to_burn);

    // Calculate proportional amounts
    let token_out: u64 = (stable_pair.pool_token_reserve * lp_shares_to_burn) / stable_pair.total_lp_shares;
    let stable_out: u64 = (stable_pair.pool_stable_reserve * lp_shares_to_burn) / stable_pair.total_lp_shares;

    require(token_out >= min_token_out);
    require(stable_out >= min_stable_out);

    // Transfer out
    Token2022.spl_transfer(token_vault, user_token_account, vault_authority, token_out);
    Token2022.spl_transfer(stable_vault, user_stable_account, vault_authority, stable_out);

    // Update state
    stable_pair.pool_token_reserve = stable_pair.pool_token_reserve - token_out;
    stable_pair.pool_stable_reserve = stable_pair.pool_stable_reserve - stable_out;
    stable_pair.total_lp_shares = stable_pair.total_lp_shares - lp_shares_to_burn;
    lp_position.lp_shares = lp_position.lp_shares - lp_shares_to_burn;
}

/// Pause/unpause a pair (creator only)
pub set_pair_paused(
    stable_pair: StablePairConfig @mut,
    authority: account @signer,
    paused: u8
) {
    require(authority.key == stable_pair.creator);
    stable_pair.paused = paused;
}

/// Update fee (creator only)
pub update_pair_fee(
    stable_pair: StablePairConfig @mut,
    authority: account @signer,
    new_fee_bps: u64
) {
    require(authority.key == stable_pair.creator);
    require(new_fee_bps <= 500);
    stable_pair.fee_bps = new_fee_bps;
}

/// View: get token reserve
pub get_token_reserve(
    stable_pair: StablePairConfig
) -> u64 {
    return stable_pair.pool_token_reserve;
}

/// View: get stable reserve
pub get_stable_reserve(
    stable_pair: StablePairConfig
) -> u64 {
    return stable_pair.pool_stable_reserve;
}

// ---------------------------------------------------------------------------
// PYUSD Helpers
// ---------------------------------------------------------------------------

/// Recommended fee for stablecoin-to-stablecoin pairs (PYUSD/USDC): 5 bps (0.05%)
/// For volatile token/PYUSD pairs: 30 bps (0.30%) default
/// These are suggestions — create_stable_pair accepts any fee_bps <= 500

/// Calculate swap output for a stablecoin-to-stablecoin pair
/// At equal reserves this approximates 1:1 minus fee
pub calc_stable_swap_output(
    reserve_in: u64,
    reserve_out: u64,
    amount_in: u64,
    fee_bps: u64
) -> u64 {
    let fee: u64 = (amount_in * fee_bps) / 10000;
    let net: u64 = amount_in - fee;
    let numerator: u64 = reserve_out * net;
    let denominator: u64 = reserve_in + net;
    return numerator / denominator;
}

/// Check if a pair is a stablecoin-to-stablecoin pair (both sides are stables)
/// Returns 1 if fee_bps <= 10 (heuristic: low-fee pairs are stable/stable)
pub is_stable_stable_pair(
    stable_pair: StablePairConfig
) -> u64 {
    if stable_pair.fee_bps <= 10 {
        return 1;
    }
    return 0;
}
