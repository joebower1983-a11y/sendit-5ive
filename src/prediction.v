// Send.it Prediction Market Module — ported from Anchor to 5IVE DSL
// SOL-based prediction markets on token graduation outcomes

// ---------------------------------------------------------------------------
// Accounts
// ---------------------------------------------------------------------------

account PredictionMarket {
    token_a: pubkey;
    token_b: pubkey;
    creator: pubkey;
    total_pool_a: u64;
    total_pool_b: u64;
    deadline: u64;
    resolved: u8;
    winner: u8;
    market_index: u64;
}

account UserBet {
    user: pubkey;
    market: pubkey;
    side: u8;
    amount: u64;
    claimed: u8;
}

// ---------------------------------------------------------------------------
// Instructions
// ---------------------------------------------------------------------------

/// Create a new prediction market
pub create_prediction(
    market: PredictionMarket @mut @init(payer=creator, space=256) @signer,
    creator: account @mut @signer,
    token_a: pubkey,
    token_b: pubkey,
    deadline: u64,
    market_index: u64
) {
    // Tokens must differ
    require(token_a != token_b);

    // Deadline must be in the future
    let clock: u64 = get_clock();
    require(deadline > clock);

    market.token_a = token_a;
    market.token_b = token_b;
    market.creator = creator.key;
    market.total_pool_a = 0;
    market.total_pool_b = 0;
    market.deadline = deadline;
    market.resolved = 0;
    market.winner = 0;
    market.market_index = market_index;
}

/// Place a bet on a prediction market
pub place_bet(
    market: PredictionMarket @mut,
    user_bet: UserBet @mut @init(payer=user, space=128) @signer,
    user: account @mut @signer,
    vault: account @mut,
    side: u8,
    amount: u64
) {
    // Market must not be resolved
    require(market.resolved == 0);

    // Must be before deadline
    let clock: u64 = get_clock();
    require(clock < market.deadline);

    // Side must be 1 (token_a) or 2 (token_b)
    require(side >= 1);
    require(side <= 2);

    // Amount must be positive
    require(amount > 0);

    // Update pool totals based on side
    if side == 1 {
        market.total_pool_a = market.total_pool_a + amount;
    }
    if side == 2 {
        market.total_pool_b = market.total_pool_b + amount;
    }

    // Record the user bet
    user_bet.user = user.key;
    user_bet.market = market.token_a;
    user_bet.side = side;
    user_bet.amount = amount;
    user_bet.claimed = 0;
}

/// Resolve a prediction market (permissionless, after deadline)
/// Winner is determined by graduation status passed as argument
/// In production this would check on-chain graduation state via CPI
/// graduation_a: 1 if token_a graduated, 0 otherwise
/// graduation_b: 1 if token_b graduated, 0 otherwise
pub resolve_prediction(
    market: PredictionMarket @mut,
    resolver: account @signer,
    graduation_a: u8,
    graduation_b: u8
) {
    // Must not already be resolved
    require(market.resolved == 0);

    // Must be past deadline
    let clock: u64 = get_clock();
    require(clock >= market.deadline);

    // Determine winner based on graduation status
    // Priority: if token_a graduated, token_a wins; else if token_b graduated, token_b wins
    // If neither graduated, token_a wins by default (same as Anchor impl)
    market.winner = 1;
    if graduation_a == 0 {
        if graduation_b == 1 {
            market.winner = 2;
        }
    }

    market.resolved = 1;
}

/// Claim winnings from a resolved market
pub claim_winnings(
    market: PredictionMarket,
    user_bet: UserBet @mut,
    user: account @mut @signer,
    vault: account @mut
) {
    // Market must be resolved
    require(market.resolved == 1);

    // Must be the bet owner
    require(user_bet.user == user.key);

    // Must not have already claimed
    require(user_bet.claimed == 0);

    // Must have bet on the winning side
    require(user_bet.side == market.winner);

    // Calculate proportional payout
    // payout = (user_bet.amount * total_pool) / winning_pool
    let total_pool: u64 = market.total_pool_a + market.total_pool_b;

    let mut winning_pool: u64 = market.total_pool_a;
    if market.winner == 2 {
        winning_pool = market.total_pool_b;
    }

    require(winning_pool > 0);

    let payout: u64 = (user_bet.amount * total_pool) / winning_pool;

    // Mark as claimed
    user_bet.claimed = 1;

    // Note: actual SOL transfer from vault to user would use system program CPI
    // which is not yet supported in 5IVE DSL — the payout value is computed
    // and the claim is recorded; transfer would happen via SDK/runtime
}

/// Get market odds (view function)
pub get_market_odds(
    market: PredictionMarket
) -> u64 {
    // Returns total_pool_a as a simple view
    // Full odds would return both pools but DSL only supports single return
    return market.total_pool_a;
}

/// Get total pool size (view function)
pub get_total_pool(
    market: PredictionMarket
) -> u64 {
    let total: u64 = market.total_pool_a + market.total_pool_b;
    return total;
}
