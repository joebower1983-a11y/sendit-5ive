interface Token2022 @program("TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb") {
    @discriminator(3)
    spl_transfer(from: account @mut, to: account @mut, authority: account @signer, amount: u64);
}
// Send.it Fund Tokens Module — ported from Anchor to 5IVE DSL
// Index fund / basket token management


// ---------------------------------------------------------------------------
// Accounts
// ---------------------------------------------------------------------------

account FundConfig {
    name_hash: pubkey;
    creator: pubkey;
    share_mint: pubkey;
    total_deposits_sol: u64;
    management_fee_bps: u64;
    active: u8;
    created_at: u64;
    num_tokens: u64;
    weight_sum: u64;
    bump: u8;
    share_mint_bump: u8;
}

account UserFundPosition {
    user: pubkey;
    fund: pubkey;
    shares_held: u64;
    total_deposited_sol: u64;
    total_redeemed_sol: u64;
    first_deposit_at: u64;
    bump: u8;
}

// ---------------------------------------------------------------------------
// Instructions
// ---------------------------------------------------------------------------

/// Create a new fund
pub create_fund(
    fund_config: FundConfig @mut @init(payer=creator, space=512) @signer,
    creator: account @mut @signer,
    share_mint: pubkey,
    name_hash: pubkey,
    management_fee_bps: u64,
    num_tokens: u64
) {
    require(management_fee_bps <= 500);
    require(num_tokens > 0);
    require(num_tokens <= 10);

    let clock: u64 = get_clock();

    fund_config.name_hash = name_hash;
    fund_config.creator = creator.key;
    fund_config.share_mint = share_mint;
    fund_config.total_deposits_sol = 0;
    fund_config.management_fee_bps = management_fee_bps;
    fund_config.active = 1;
    fund_config.created_at = clock;
    fund_config.num_tokens = num_tokens;
    fund_config.weight_sum = 10000;
    fund_config.bump = 0;
    fund_config.share_mint_bump = 0;
}

/// Deposit SOL into a fund (tracking only — actual SOL/share transfers via SDK)
pub deposit_to_fund(
    fund_config: FundConfig @mut,
    user_position: UserFundPosition @mut @init(payer=depositor, space=256) @signer,
    depositor: account @mut @signer,
    sol_amount: u64
) {
    require(sol_amount > 0);
    require(fund_config.active == 1);

    let clock: u64 = get_clock();

    // Track deposit
    fund_config.total_deposits_sol = fund_config.total_deposits_sol + sol_amount;

    // Update user position
    if user_position.first_deposit_at == 0 {
        user_position.user = depositor.key;
        user_position.fund = fund_config.creator;
        user_position.first_deposit_at = clock;
        user_position.shares_held = 0;
        user_position.total_deposited_sol = 0;
        user_position.total_redeemed_sol = 0;
        user_position.bump = 0;
    }

    // Shares minted = sol_amount (1:1 simplified)
    user_position.shares_held = user_position.shares_held + sol_amount;
    user_position.total_deposited_sol = user_position.total_deposited_sol + sol_amount;
}

/// Redeem shares for SOL (tracking only)
pub redeem_shares(
    fund_config: FundConfig @mut,
    user_position: UserFundPosition @mut,
    redeemer: account @mut @signer,
    share_amount: u64
) {
    require(share_amount > 0);
    require(user_position.user == redeemer.key);
    require(user_position.shares_held >= share_amount);

    // Calculate management fee
    let gross_sol: u64 = share_amount;
    let fee: u64 = (gross_sol * fund_config.management_fee_bps) / 10000;
    let net_sol: u64 = gross_sol - fee;

    user_position.shares_held = user_position.shares_held - share_amount;
    user_position.total_redeemed_sol = user_position.total_redeemed_sol + net_sol;
}

/// Rebalance fund weights (creator only, tracking)
pub rebalance_fund(
    fund_config: FundConfig @mut,
    creator: account @signer,
    new_weight_sum: u64
) {
    require(creator.key == fund_config.creator);
    require(new_weight_sum == 10000);
    fund_config.weight_sum = new_weight_sum;
}

/// Toggle fund active status (creator only)
pub set_fund_active(
    fund_config: FundConfig @mut,
    creator: account @signer,
    active: u8
) {
    require(creator.key == fund_config.creator);
    fund_config.active = active;
}

/// View: get total deposits
pub get_total_deposits(
    fund_config: FundConfig
) -> u64 {
    return fund_config.total_deposits_sol;
}
