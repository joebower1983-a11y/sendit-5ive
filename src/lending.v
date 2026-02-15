// Send.it Lending Module — ported from Anchor to 5IVE DSL

interface Token2022 @program("TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb") {
    @discriminator(3)
    spl_transfer(from: account @mut, to: account @mut, authority: account @signer, amount: u64);
}

// ---------------------------------------------------------------------------
// Accounts
// ---------------------------------------------------------------------------

account LendingPool {
    collateral_mint: pubkey;
    authority: pubkey;
    total_deposited: u64;
    total_borrowed: u64;
    interest_rate_bps: u64;
    ltv_ratio: u64;
    liquidation_threshold_bps: u64;
    last_update: u64;
    graduated: u8;
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

// ---------------------------------------------------------------------------
// Instructions
// ---------------------------------------------------------------------------

/// Create a lending pool for a graduated token
pub create_lending_pool(
    lending_pool: LendingPool @mut @init(payer=authority, space=256) @signer,
    authority: account @mut @signer,
    collateral_mint: pubkey,
    interest_rate_bps: u64,
    ltv_ratio: u64,
    liquidation_threshold_bps: u64
) {
    require(interest_rate_bps > 0);
    require(interest_rate_bps <= 5000);
    require(ltv_ratio > 0);
    require(ltv_ratio < 10000);

    let clock: u64 = get_clock();

    lending_pool.collateral_mint = collateral_mint;
    lending_pool.authority = authority.key;
    lending_pool.total_deposited = 0;
    lending_pool.total_borrowed = 0;
    lending_pool.interest_rate_bps = interest_rate_bps;
    lending_pool.ltv_ratio = ltv_ratio;
    lending_pool.liquidation_threshold_bps = liquidation_threshold_bps;
    lending_pool.last_update = clock;
    lending_pool.graduated = 1;
    lending_pool.bump = 0;
}

/// Deposit SOL into the lending pool (tracking — actual SOL transfer via SDK)
pub deposit_sol(
    lending_pool: LendingPool @mut,
    user_position: UserLendPosition @mut @init(payer=user, space=256) @signer,
    user: account @mut @signer,
    amount: u64
) {
    require(amount > 0);

    let clock: u64 = get_clock();

    lending_pool.total_deposited = lending_pool.total_deposited + amount;

    user_position.user = user.key;
    user_position.collateral_token = lending_pool.collateral_mint;
    user_position.deposited = user_position.deposited + amount;
    if user_position.last_interest_update == 0 {
        user_position.last_interest_update = clock;
    }
}

/// Borrow SOL against token collateral
pub borrow_against_tokens(
    lending_pool: LendingPool @mut,
    user_position: UserLendPosition @mut,
    user: account @mut @signer,
    user_token_account: account @mut,
    token_vault: account @mut,
    token_program: account,
    collateral_amount: u64,
    borrow_amount: u64
) {
    require(collateral_amount > 0);
    require(borrow_amount > 0);
    require(user_position.user == user.key);

    // Check pool has enough liquidity
    let available: u64 = lending_pool.total_deposited - lending_pool.total_borrowed;
    require(borrow_amount <= available);

    // Accrue interest
    let clock: u64 = get_clock();
    if user_position.borrowed > 0 {
        let elapsed: u64 = clock - user_position.last_interest_update;
        let interest: u64 = (user_position.borrowed * lending_pool.interest_rate_bps * elapsed) / (10000 * 31536000);
        user_position.interest_owed = user_position.interest_owed + interest;
    }
    user_position.last_interest_update = clock;

    // LTV check: total_debt <= total_collateral * ltv / 10000
    let total_collateral: u64 = user_position.collateral_amount + collateral_amount;
    let max_borrow: u64 = (total_collateral * lending_pool.ltv_ratio) / 10000;
    let total_debt: u64 = user_position.borrowed + user_position.interest_owed + borrow_amount;
    require(total_debt <= max_borrow);

    // Lock collateral tokens
    Token2022.spl_transfer(user_token_account, token_vault, user, collateral_amount);

    // Update state
    user_position.borrowed = user_position.borrowed + borrow_amount;
    user_position.collateral_amount = total_collateral;
    lending_pool.total_borrowed = lending_pool.total_borrowed + borrow_amount;
}

/// Repay borrowed SOL
pub repay(
    lending_pool: LendingPool @mut,
    user_position: UserLendPosition @mut,
    user: account @mut @signer,
    amount: u64
) {
    require(amount > 0);
    require(user_position.user == user.key);

    // Accrue interest
    let clock: u64 = get_clock();
    if user_position.borrowed > 0 {
        let elapsed: u64 = clock - user_position.last_interest_update;
        let interest: u64 = (user_position.borrowed * lending_pool.interest_rate_bps * elapsed) / (10000 * 31536000);
        user_position.interest_owed = user_position.interest_owed + interest;
    }
    user_position.last_interest_update = clock;

    let total_debt: u64 = user_position.borrowed + user_position.interest_owed;
    require(amount <= total_debt);

    // Pay interest first, then principal
    if amount <= user_position.interest_owed {
        user_position.interest_owed = user_position.interest_owed - amount;
    } else {
        let principal_payment: u64 = amount - user_position.interest_owed;
        user_position.interest_owed = 0;
        user_position.borrowed = user_position.borrowed - principal_payment;
        lending_pool.total_borrowed = lending_pool.total_borrowed - principal_payment;
    }
}

/// Withdraw deposited SOL
pub withdraw_sol(
    lending_pool: LendingPool @mut,
    user_position: UserLendPosition @mut,
    user: account @mut @signer,
    amount: u64
) {
    require(amount > 0);
    require(user_position.user == user.key);
    require(user_position.deposited >= amount);

    let available: u64 = lending_pool.total_deposited - lending_pool.total_borrowed;
    require(amount <= available);

    user_position.deposited = user_position.deposited - amount;
    lending_pool.total_deposited = lending_pool.total_deposited - amount;
}

/// Liquidate an undercollateralized position
pub liquidate(
    lending_pool: LendingPool @mut,
    user_position: UserLendPosition @mut,
    liquidator: account @mut @signer,
    token_vault: account @mut,
    liquidator_token_account: account @mut,
    vault_authority: account @signer,
    token_program: account
) {
    // Accrue interest
    let clock: u64 = get_clock();
    if user_position.borrowed > 0 {
        let elapsed: u64 = clock - user_position.last_interest_update;
        let interest: u64 = (user_position.borrowed * lending_pool.interest_rate_bps * elapsed) / (10000 * 31536000);
        user_position.interest_owed = user_position.interest_owed + interest;
    }
    user_position.last_interest_update = clock;

    let total_debt: u64 = user_position.borrowed + user_position.interest_owed;

    // Check if liquidatable: debt > collateral * liquidation_threshold / 10000
    let max_allowed: u64 = (user_position.collateral_amount * lending_pool.liquidation_threshold_bps) / 10000;
    require(total_debt > max_allowed);

    // Transfer collateral to liquidator
    let collateral_seized: u64 = user_position.collateral_amount;
    Token2022.spl_transfer(token_vault, liquidator_token_account, vault_authority, collateral_seized);

    // Clear position
    lending_pool.total_borrowed = lending_pool.total_borrowed - user_position.borrowed;
    user_position.borrowed = 0;
    user_position.interest_owed = 0;
    user_position.collateral_amount = 0;
}

/// View: get pool utilization
pub get_pool_utilization(
    lending_pool: LendingPool
) -> u64 {
    if lending_pool.total_deposited == 0 {
        return 0;
    }
    return (lending_pool.total_borrowed * 10000) / lending_pool.total_deposited;
}
