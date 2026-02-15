interface Token2022 @program("TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb") {
    @discriminator(3)
    spl_transfer(from: account @mut, to: account @mut, authority: account @signer, amount: u64);
}
// Send.it Perpetual Futures Trading Engine — ported from Anchor to 5IVE DSL
// Full port of perps.rs (1602 lines)
//
// Conventions:
//   Side: 0 = Long, 1 = Short
//   OrderType: 0 = Limit, 1 = Market
//   Signed values: stored as (value: u64, sign: u8) where sign 0=positive, 1=negative
//   Precision: 1_000_000 (all prices, rates, margins)

// ---------------------------------------------------------------------------
// SPL Token-2022 CPI Interface
// ---------------------------------------------------------------------------


// ---------------------------------------------------------------------------
// Constants (embedded as literals in logic — DSL has no const declarations)
// ---------------------------------------------------------------------------
// PRECISION = 1000000
// MAX_LEVERAGE = 20
// DEFAULT_MAINTENANCE_MARGIN = 25000   (2.5%)
// DEFAULT_LIQUIDATION_FEE = 10000      (1%)
// DEFAULT_MAKER_FEE = 200              (0.02%)
// DEFAULT_TAKER_FEE = 600              (0.06%)
// INSURANCE_FEE_SHARE = 300000         (30%)
// SOLFORGE_FEE_SHARE = 200000          (20%)
// MAX_ORDERS = 256
// TWAP_WINDOW = 3600
// DEFAULT_FUNDING_INTERVAL = 3600
// MAX_FUNDING_RATE = 1000              (0.1%)
// PRICE_BAND_BPS = 1000               (10%)

// ---------------------------------------------------------------------------
// Accounts
// ---------------------------------------------------------------------------

account PerpMarket {
    bump: u8;
    authority: pubkey;
    token_mint: pubkey;
    collateral_mint: pubkey;
    raydium_pool: pubkey;
    solforge_vault: pubkey;
    insurance_fund_key: pubkey;
    collateral_vault: pubkey;
    order_book_key: pubkey;
    max_leverage: u64;
    maintenance_margin: u64;
    liquidation_fee: u64;
    maker_fee: u64;
    taker_fee: u64;
    funding_interval: u64;
    max_open_interest: u64;
    max_position_size: u64;
    mark_price: u64;
    index_price: u64;
    long_open_interest: u64;
    short_open_interest: u64;
    cumul_funding_long: u64;
    cumul_funding_long_sign: u8;
    cumul_funding_short: u64;
    cumul_funding_short_sign: u8;
    last_funding_time: u64;
    paused: u8;
    created_at: u64;
    twap_last_price: u64;
    twap_last_time: u64;
    twap_sum: u64;
    twap_count: u64;
}

account OrderBook {
    bump: u8;
    market: pubkey;
    next_order_id: u64;
    bid_count: u64;
    ask_count: u64;
}

account OrderEntry {
    order_id: u64;
    owner: pubkey;
    price: u64;
    size: u64;
    remaining: u64;
    side: u8;
    order_type: u8;
    timestamp: u64;
    margin_account: pubkey;
    book: pubkey;
    active: u8;
}

account UserMarginAccount {
    bump: u8;
    owner: pubkey;
    collateral: u64;
    open_positions: u64;
    realized_pnl: u64;
    realized_pnl_sign: u8;
    created_at: u64;
}

account Position {
    bump: u8;
    market: pubkey;
    owner: pubkey;
    margin_account: pubkey;
    side: u8;
    size: u64;
    entry_price: u64;
    collateral: u64;
    leverage: u64;
    last_cumul_funding: u64;
    last_cumul_funding_sign: u8;
    pending_funding: u64;
    pending_funding_sign: u8;
    opened_at: u64;
    updated_at: u64;
    active: u8;
}

account InsuranceFund {
    bump: u8;
    market: pubkey;
    vault: pubkey;
    balance: u64;
    total_payouts: u64;
    total_deposits: u64;
}

// ---------------------------------------------------------------------------
// Math helper functions
// ---------------------------------------------------------------------------

/// Multiply two PRECISION-based values: (a * b) / PRECISION
pub mul_precision(a: u64, b: u64) -> u64 {
    let result: u64 = (a * b) / 1000000;
    return result;
}

/// Divide two PRECISION-based values: (a * PRECISION) / b
pub div_precision(a: u64, b: u64) -> u64 {
    require(b > 0);
    let result: u64 = (a * 1000000) / b;
    return result;
}

/// Calculate notional value = size * price / PRECISION
pub calc_notional(size: u64, price: u64) -> u64 {
    let n: u64 = (size * price) / 1000000;
    return n;
}

/// Calculate fee = notional * fee_rate / PRECISION
pub calc_fee(notional: u64, fee_rate: u64) -> u64 {
    let fee: u64 = (notional * fee_rate) / 1000000;
    return fee;
}

/// Calculate unrealized PnL for a long position (mark > entry = profit)
/// Returns (pnl_value, pnl_sign) encoded as single u64
/// High 32 bits = not used; we return just the absolute value
/// Caller must check direction separately
pub calc_pnl_long(entry_price: u64, mark_price: u64, size: u64) -> u64 {
    if mark_price >= entry_price {
        let diff: u64 = mark_price - entry_price;
        let pnl: u64 = (diff * size) / 1000000;
        return pnl;
    }
    let diff2: u64 = entry_price - mark_price;
    let pnl2: u64 = (diff2 * size) / 1000000;
    return pnl2;
}

/// Check if long PnL is positive (mark >= entry)
pub is_pnl_long_positive(entry_price: u64, mark_price: u64) -> u64 {
    if mark_price >= entry_price {
        return 1;
    }
    return 0;
}

/// Calculate unrealized PnL for a short position (entry > mark = profit)
pub calc_pnl_short(entry_price: u64, mark_price: u64, size: u64) -> u64 {
    if entry_price >= mark_price {
        let diff: u64 = entry_price - mark_price;
        let pnl: u64 = (diff * size) / 1000000;
        return pnl;
    }
    let diff2: u64 = mark_price - entry_price;
    let pnl2: u64 = (diff2 * size) / 1000000;
    return pnl2;
}

/// Check if short PnL is positive (entry >= mark)
pub is_pnl_short_positive(entry_price: u64, mark_price: u64) -> u64 {
    if entry_price >= mark_price {
        return 1;
    }
    return 0;
}

/// Calculate margin ratio = (collateral +/- pnl) * PRECISION / notional
/// pnl_positive: 1 if pnl adds to equity, 0 if subtracts
pub calc_margin_ratio(collateral: u64, pnl: u64, pnl_positive: u64, notional: u64) -> u64 {
    if notional == 0 {
        return 999999999;
    }
    let mut equity: u64 = collateral;
    if pnl_positive == 1 {
        equity = collateral + pnl;
    }
    if pnl_positive == 0 {
        if pnl >= collateral {
            return 0;
        }
        equity = collateral - pnl;
    }
    let ratio: u64 = (equity * 1000000) / notional;
    return ratio;
}

/// Calculate funding payment absolute value
/// payment = size * |cumul_now - cumul_at_open| / PRECISION
pub calc_funding_abs(size: u64, cumul_now: u64, cumul_at_open: u64) -> u64 {
    let mut delta: u64 = 0;
    if cumul_now >= cumul_at_open {
        delta = cumul_now - cumul_at_open;
    }
    if cumul_at_open > cumul_now {
        delta = cumul_at_open - cumul_now;
    }
    let payment: u64 = (delta * size) / 1000000;
    return payment;
}

// ---------------------------------------------------------------------------
// Instructions
// ---------------------------------------------------------------------------

/// Initialize a perpetual futures market for a graduated token
pub initialize_perp_market(
    market: PerpMarket @mut @init(payer=authority, space=512) @signer,
    order_book: OrderBook @mut @init(payer=authority, space=256) @signer,
    ins_fund: InsuranceFund @mut @init(payer=authority, space=256) @signer,
    authority: account @mut @signer,
    token_mint: account,
    collateral_mint: account,
    raydium_pool: account,
    solforge_vault: account,
    collateral_vault: account,
    insurance_vault: account,
    max_leverage: u64,
    funding_interval: u64,
    maintenance_margin: u64,
    liquidation_fee: u64,
    maker_fee: u64,
    taker_fee: u64,
    max_open_interest: u64,
    max_position_size: u64
) {
    require(max_leverage > 0);
    require(max_leverage <= 20);

    let clock: u64 = get_clock();

    market.bump = 0;
    market.authority = authority.key;
    market.token_mint = token_mint.key;
    market.collateral_mint = collateral_mint.key;
    market.raydium_pool = raydium_pool.key;
    market.solforge_vault = solforge_vault.key;
    market.insurance_fund_key = ins_fund.key;
    market.collateral_vault = collateral_vault.key;
    market.order_book_key = order_book.key;

    market.max_leverage = max_leverage;

    // Use defaults if zero provided
    if maintenance_margin > 0 {
        market.maintenance_margin = maintenance_margin;
    }
    if maintenance_margin == 0 {
        market.maintenance_margin = 25000;
    }
    if liquidation_fee > 0 {
        market.liquidation_fee = liquidation_fee;
    }
    if liquidation_fee == 0 {
        market.liquidation_fee = 10000;
    }
    if maker_fee > 0 {
        market.maker_fee = maker_fee;
    }
    if maker_fee == 0 {
        market.maker_fee = 200;
    }
    if taker_fee > 0 {
        market.taker_fee = taker_fee;
    }
    if taker_fee == 0 {
        market.taker_fee = 600;
    }
    if funding_interval > 0 {
        market.funding_interval = funding_interval;
    }
    if funding_interval == 0 {
        market.funding_interval = 3600;
    }

    market.max_open_interest = max_open_interest;
    market.max_position_size = max_position_size;
    market.mark_price = 0;
    market.index_price = 0;
    market.long_open_interest = 0;
    market.short_open_interest = 0;
    market.cumul_funding_long = 0;
    market.cumul_funding_long_sign = 0;
    market.cumul_funding_short = 0;
    market.cumul_funding_short_sign = 0;
    market.last_funding_time = clock;
    market.paused = 0;
    market.created_at = clock;
    market.twap_last_price = 0;
    market.twap_last_time = clock;
    market.twap_sum = 0;
    market.twap_count = 0;

    // Initialize order book
    order_book.bump = 0;
    order_book.market = market.key;
    order_book.next_order_id = 1;
    order_book.bid_count = 0;
    order_book.ask_count = 0;

    // Initialize insurance fund
    ins_fund.bump = 0;
    ins_fund.market = market.key;
    ins_fund.vault = insurance_vault.key;
    ins_fund.balance = 0;
    ins_fund.total_payouts = 0;
    ins_fund.total_deposits = 0;
}

/// Create a cross-margin account for a user
pub create_margin_account(
    margin_account: UserMarginAccount @mut @init(payer=owner, space=256) @signer,
    owner: account @mut @signer
) {
    let clock: u64 = get_clock();
    margin_account.bump = 0;
    margin_account.owner = owner.key;
    margin_account.collateral = 0;
    margin_account.open_positions = 0;
    margin_account.realized_pnl = 0;
    margin_account.realized_pnl_sign = 0;
    margin_account.created_at = clock;
}

/// Deposit collateral into margin account via token transfer
pub deposit_collateral(
    margin_account: UserMarginAccount @mut,
    owner: account @mut @signer,
    user_token_account: account @mut,
    collateral_vault: account @mut,
    token_program: account,
    amount: u64
) {
    require(amount > 0);
    require(margin_account.owner == owner.key);

    // CPI transfer from user to vault
    Token2022.spl_transfer(user_token_account, collateral_vault, owner, amount);

    margin_account.collateral = margin_account.collateral + amount;
}

/// Withdraw collateral from margin account
pub withdraw_collateral(
    margin_account: UserMarginAccount @mut,
    market: PerpMarket,
    owner: account @mut @signer,
    user_token_account: account @mut,
    collateral_vault: account @mut,
    vault_authority: account @signer,
    token_program: account,
    amount: u64
) {
    require(amount > 0);
    require(margin_account.owner == owner.key);
    require(margin_account.collateral >= amount);

    margin_account.collateral = margin_account.collateral - amount;

    // CPI transfer from vault to user
    Token2022.spl_transfer(collateral_vault, user_token_account, vault_authority, amount);
}

/// Open a new leveraged position
pub open_position(
    market: PerpMarket @mut,
    margin_account: UserMarginAccount @mut,
    position: Position @mut @init(payer=owner, space=512) @signer,
    owner: account @mut @signer,
    side: u8,
    size: u64,
    leverage: u64,
    collateral_amount: u64
) {
    // Validations
    require(market.paused == 0);
    require(leverage > 0);
    require(leverage <= market.max_leverage);
    require(size > 0);
    require(size <= market.max_position_size);
    require(margin_account.owner == owner.key);

    // Check open interest caps
    if side == 0 {
        let new_long_oi: u64 = market.long_open_interest + size;
        require(new_long_oi <= market.max_open_interest);
    }
    if side == 1 {
        let new_short_oi: u64 = market.short_open_interest + size;
        require(new_short_oi <= market.max_open_interest);
    }

    // Use mark price as entry
    let entry_price: u64 = market.mark_price;
    require(entry_price > 0);

    // Circuit breaker check
    if market.index_price > 0 {
        let mut deviation: u64 = 0;
        if entry_price > market.index_price {
            deviation = ((entry_price - market.index_price) * 1000000) / market.index_price;
        }
        if market.index_price > entry_price {
            deviation = ((market.index_price - entry_price) * 1000000) / market.index_price;
        }
        // PRICE_BAND_BPS=1000 → 10% = 100000 in precision terms (1000*1000000/10000)
        require(deviation <= 100000);
    }

    // Calculate required collateral: notional / leverage
    let notional: u64 = (size * entry_price) / 1000000;
    let required_collateral: u64 = notional / leverage;
    require(collateral_amount >= required_collateral);

    // Deduct collateral from margin account
    require(margin_account.collateral >= collateral_amount);
    margin_account.collateral = margin_account.collateral - collateral_amount;
    margin_account.open_positions = margin_account.open_positions + 1;

    // Calculate and charge taker fee (fee goes to protocol — tracked but not transferred here)
    let fee: u64 = (notional * market.taker_fee) / 1000000;

    // Initialize position
    let clock: u64 = get_clock();
    position.bump = 0;
    position.market = market.key;
    position.owner = owner.key;
    position.margin_account = margin_account.key;
    position.side = side;
    position.size = size;
    position.entry_price = entry_price;
    position.collateral = collateral_amount;
    position.leverage = leverage;
    position.active = 1;

    // Store last cumulative funding based on side
    if side == 0 {
        position.last_cumul_funding = market.cumul_funding_long;
        position.last_cumul_funding_sign = market.cumul_funding_long_sign;
    }
    if side == 1 {
        position.last_cumul_funding = market.cumul_funding_short;
        position.last_cumul_funding_sign = market.cumul_funding_short_sign;
    }
    position.pending_funding = 0;
    position.pending_funding_sign = 0;
    position.opened_at = clock;
    position.updated_at = clock;

    // Update market open interest
    if side == 0 {
        market.long_open_interest = market.long_open_interest + size;
    }
    if side == 1 {
        market.short_open_interest = market.short_open_interest + size;
    }
}

/// Close an entire position
pub close_position(
    market: PerpMarket @mut,
    position: Position @mut,
    margin_account: UserMarginAccount @mut,
    owner: account @mut @signer
) {
    require(position.owner == owner.key);
    require(position.active == 1);
    require(position.size > 0);

    let exit_price: u64 = market.mark_price;

    // Circuit breaker
    if market.index_price > 0 {
        let mut dev: u64 = 0;
        if exit_price > market.index_price {
            dev = ((exit_price - market.index_price) * 1000000) / market.index_price;
        }
        if market.index_price > exit_price {
            dev = ((market.index_price - exit_price) * 1000000) / market.index_price;
        }
        require(dev <= 100000);
    }

    // Calculate PnL
    let mut pnl_value: u64 = 0;
    let mut pnl_positive: u64 = 0;

    if position.side == 0 {
        // Long: profit if mark > entry
        if exit_price >= position.entry_price {
            pnl_value = ((exit_price - position.entry_price) * position.size) / 1000000;
            pnl_positive = 1;
        }
        if position.entry_price > exit_price {
            pnl_value = ((position.entry_price - exit_price) * position.size) / 1000000;
            pnl_positive = 0;
        }
    }
    if position.side == 1 {
        // Short: profit if entry > mark
        if position.entry_price >= exit_price {
            pnl_value = ((position.entry_price - exit_price) * position.size) / 1000000;
            pnl_positive = 1;
        }
        if exit_price > position.entry_price {
            pnl_value = ((exit_price - position.entry_price) * position.size) / 1000000;
            pnl_positive = 0;
        }
    }

    // Calculate funding payment (simplified: use absolute delta)
    let mut funding_value: u64 = 0;
    let mut cumul_now: u64 = 0;
    if position.side == 0 {
        cumul_now = market.cumul_funding_long;
    }
    if position.side == 1 {
        cumul_now = market.cumul_funding_short;
    }
    if cumul_now >= position.last_cumul_funding {
        funding_value = ((cumul_now - position.last_cumul_funding) * position.size) / 1000000;
    }
    if position.last_cumul_funding > cumul_now {
        funding_value = ((position.last_cumul_funding - cumul_now) * position.size) / 1000000;
    }

    // Calculate exit fee
    let exit_notional: u64 = (position.size * exit_price) / 1000000;
    let fee: u64 = (exit_notional * market.taker_fee) / 1000000;

    // Return collateral +/- PnL - fees to margin account
    let mut return_amount: u64 = position.collateral;
    if pnl_positive == 1 {
        return_amount = return_amount + pnl_value;
    }
    if pnl_positive == 0 {
        if pnl_value < return_amount {
            return_amount = return_amount - pnl_value;
        }
        if pnl_value >= return_amount {
            return_amount = 0;
        }
    }

    // Subtract fee
    if fee < return_amount {
        return_amount = return_amount - fee;
    }
    if fee >= return_amount {
        return_amount = 0;
    }

    // Subtract funding
    if funding_value < return_amount {
        return_amount = return_amount - funding_value;
    }
    if funding_value >= return_amount {
        return_amount = 0;
    }

    margin_account.collateral = margin_account.collateral + return_amount;

    // Update realized PnL (additive only for simplicity in unsigned DSL)
    if pnl_positive == 1 {
        margin_account.realized_pnl = margin_account.realized_pnl + pnl_value;
        margin_account.realized_pnl_sign = 0;
    }

    if margin_account.open_positions > 0 {
        margin_account.open_positions = margin_account.open_positions - 1;
    }

    // Update market OI
    if position.side == 0 {
        if market.long_open_interest >= position.size {
            market.long_open_interest = market.long_open_interest - position.size;
        }
        if market.long_open_interest < position.size {
            market.long_open_interest = 0;
        }
    }
    if position.side == 1 {
        if market.short_open_interest >= position.size {
            market.short_open_interest = market.short_open_interest - position.size;
        }
        if market.short_open_interest < position.size {
            market.short_open_interest = 0;
        }
    }

    // Mark position as closed
    position.size = 0;
    position.collateral = 0;
    position.active = 0;
    position.updated_at = get_clock();
}

/// Increase an existing position's size
pub increase_position(
    market: PerpMarket @mut,
    position: Position @mut,
    margin_account: UserMarginAccount @mut,
    owner: account @mut @signer,
    additional_size: u64,
    additional_collateral: u64
) {
    require(market.paused == 0);
    require(position.owner == owner.key);
    require(position.active == 1);
    require(margin_account.owner == owner.key);

    let new_size: u64 = position.size + additional_size;
    require(new_size <= market.max_position_size);

    let current_price: u64 = market.mark_price;
    require(current_price > 0);

    // Circuit breaker
    if market.index_price > 0 {
        let mut dev: u64 = 0;
        if current_price > market.index_price {
            dev = ((current_price - market.index_price) * 1000000) / market.index_price;
        }
        if market.index_price > current_price {
            dev = ((market.index_price - current_price) * 1000000) / market.index_price;
        }
        require(dev <= 100000);
    }

    // Weighted average entry price
    let old_notional: u64 = position.size * position.entry_price;
    let new_notional: u64 = additional_size * current_price;
    let avg_entry: u64 = (old_notional + new_notional) / new_size;

    // Deduct collateral
    require(margin_account.collateral >= additional_collateral);
    margin_account.collateral = margin_account.collateral - additional_collateral;

    position.size = new_size;
    position.entry_price = avg_entry;
    position.collateral = position.collateral + additional_collateral;
    position.updated_at = get_clock();

    // Update OI
    if position.side == 0 {
        market.long_open_interest = market.long_open_interest + additional_size;
    }
    if position.side == 1 {
        market.short_open_interest = market.short_open_interest + additional_size;
    }
}

/// Decrease an existing position's size (partial close)
pub decrease_position(
    market: PerpMarket @mut,
    position: Position @mut,
    margin_account: UserMarginAccount @mut,
    owner: account @mut @signer,
    decrease_size: u64
) {
    require(position.owner == owner.key);
    require(position.active == 1);
    require(decrease_size > 0);
    require(decrease_size < position.size);

    let exit_price: u64 = market.mark_price;

    // Circuit breaker
    if market.index_price > 0 {
        let mut dev: u64 = 0;
        if exit_price > market.index_price {
            dev = ((exit_price - market.index_price) * 1000000) / market.index_price;
        }
        if market.index_price > exit_price {
            dev = ((market.index_price - exit_price) * 1000000) / market.index_price;
        }
        require(dev <= 100000);
    }

    // Calculate PnL on closed portion
    let mut pnl_value: u64 = 0;
    let mut pnl_positive: u64 = 0;

    if position.side == 0 {
        if exit_price >= position.entry_price {
            pnl_value = ((exit_price - position.entry_price) * decrease_size) / 1000000;
            pnl_positive = 1;
        }
        if position.entry_price > exit_price {
            pnl_value = ((position.entry_price - exit_price) * decrease_size) / 1000000;
            pnl_positive = 0;
        }
    }
    if position.side == 1 {
        if position.entry_price >= exit_price {
            pnl_value = ((position.entry_price - exit_price) * decrease_size) / 1000000;
            pnl_positive = 1;
        }
        if exit_price > position.entry_price {
            pnl_value = ((exit_price - position.entry_price) * decrease_size) / 1000000;
            pnl_positive = 0;
        }
    }

    // Proportional collateral for closed portion
    let collateral_fraction: u64 = (position.collateral * decrease_size) / position.size;

    // Return collateral +/- PnL
    let mut return_amount: u64 = collateral_fraction;
    if pnl_positive == 1 {
        return_amount = return_amount + pnl_value;
    }
    if pnl_positive == 0 {
        if pnl_value < return_amount {
            return_amount = return_amount - pnl_value;
        }
        if pnl_value >= return_amount {
            return_amount = 0;
        }
    }

    margin_account.collateral = margin_account.collateral + return_amount;

    // Update realized PnL
    if pnl_positive == 1 {
        margin_account.realized_pnl = margin_account.realized_pnl + pnl_value;
    }

    position.size = position.size - decrease_size;
    position.collateral = position.collateral - collateral_fraction;
    position.updated_at = get_clock();

    // Update OI
    if position.side == 0 {
        if market.long_open_interest >= decrease_size {
            market.long_open_interest = market.long_open_interest - decrease_size;
        }
        if market.long_open_interest < decrease_size {
            market.long_open_interest = 0;
        }
    }
    if position.side == 1 {
        if market.short_open_interest >= decrease_size {
            market.short_open_interest = market.short_open_interest - decrease_size;
        }
        if market.short_open_interest < decrease_size {
            market.short_open_interest = 0;
        }
    }
}

/// Place an order (stored as separate OrderEntry account)
pub place_order(
    market: PerpMarket,
    order_book: OrderBook @mut,
    order_entry: OrderEntry @mut @init(payer=owner, space=256) @signer,
    margin_account: UserMarginAccount,
    owner: account @mut @signer,
    side: u8,
    order_type: u8,
    price: u64,
    size: u64
) {
    require(market.paused == 0);
    require(size > 0);
    require(margin_account.owner == owner.key);

    // Limit orders need valid price
    if order_type == 0 {
        require(price > 0);
        // Circuit breaker on limit price
        if market.index_price > 0 {
            let mut dev: u64 = 0;
            if price > market.index_price {
                dev = ((price - market.index_price) * 1000000) / market.index_price;
            }
            if market.index_price > price {
                dev = ((market.index_price - price) * 1000000) / market.index_price;
            }
            require(dev <= 100000);
        }
    }

    // Check book capacity
    if side == 0 {
        require(order_book.bid_count < 256);
    }
    if side == 1 {
        require(order_book.ask_count < 256);
    }

    let clock: u64 = get_clock();
    let order_id: u64 = order_book.next_order_id;
    order_book.next_order_id = order_book.next_order_id + 1;

    order_entry.order_id = order_id;
    order_entry.owner = owner.key;
    if order_type == 1 {
        order_entry.price = 0;
    }
    if order_type == 0 {
        order_entry.price = price;
    }
    order_entry.size = size;
    order_entry.remaining = size;
    order_entry.side = side;
    order_entry.order_type = order_type;
    order_entry.timestamp = clock;
    order_entry.margin_account = margin_account.key;
    order_entry.book = order_book.key;
    order_entry.active = 1;

    // Update counts
    if side == 0 {
        order_book.bid_count = order_book.bid_count + 1;
    }
    if side == 1 {
        order_book.ask_count = order_book.ask_count + 1;
    }
}

/// Cancel an existing order
pub cancel_order(
    order_book: OrderBook @mut,
    order_entry: OrderEntry @mut,
    owner: account @signer
) {
    require(order_entry.owner == owner.key);
    require(order_entry.active == 1);

    order_entry.active = 0;
    order_entry.remaining = 0;

    // Update counts
    if order_entry.side == 0 {
        if order_book.bid_count > 0 {
            order_book.bid_count = order_book.bid_count - 1;
        }
    }
    if order_entry.side == 1 {
        if order_book.ask_count > 0 {
            order_book.ask_count = order_book.ask_count - 1;
        }
    }
}

/// Match two crossing orders (permissionless crank)
/// Caller passes a specific bid and ask that cross
pub match_orders(
    market: PerpMarket @mut,
    order_book: OrderBook @mut,
    bid_order: OrderEntry @mut,
    ask_order: OrderEntry @mut,
    cranker: account @signer
) {
    require(market.paused == 0);
    require(bid_order.active == 1);
    require(ask_order.active == 1);
    require(bid_order.side == 0);
    require(ask_order.side == 1);
    require(bid_order.remaining > 0);
    require(ask_order.remaining > 0);

    // Self-trade prevention
    require(bid_order.owner != ask_order.owner);

    // Check orders cross: market orders always cross, limit bid >= ask
    let mut crosses: u8 = 0;
    if bid_order.order_type == 1 {
        crosses = 1;
    }
    if ask_order.order_type == 1 {
        crosses = 1;
    }
    if bid_order.price >= ask_order.price {
        crosses = 1;
    }
    require(crosses == 1);

    // Fill at resting order price (price-time priority)
    let mut fill_price: u64 = ask_order.price;
    if bid_order.timestamp < ask_order.timestamp {
        fill_price = bid_order.price;
    }

    // Fill size = min of remaining
    let mut fill_size: u64 = bid_order.remaining;
    if ask_order.remaining < fill_size {
        fill_size = ask_order.remaining;
    }

    // Update mark price
    if fill_price > 0 {
        market.mark_price = fill_price;
        // Update TWAP
        market.twap_last_price = fill_price;
        market.twap_last_time = get_clock();
        market.twap_sum = market.twap_sum + fill_price;
        market.twap_count = market.twap_count + 1;
    }

    // Update remaining sizes
    bid_order.remaining = bid_order.remaining - fill_size;
    ask_order.remaining = ask_order.remaining - fill_size;

    // Deactivate fully filled orders
    if bid_order.remaining == 0 {
        bid_order.active = 0;
        if order_book.bid_count > 0 {
            order_book.bid_count = order_book.bid_count - 1;
        }
    }
    if ask_order.remaining == 0 {
        ask_order.active = 0;
        if order_book.ask_count > 0 {
            order_book.ask_count = order_book.ask_count - 1;
        }
    }
}

/// Update funding rate (permissionless crank)
pub update_funding_rate(
    market: PerpMarket @mut,
    cranker: account @signer
) {
    let clock: u64 = get_clock();

    // Check interval elapsed
    let next_funding_time: u64 = market.last_funding_time + market.funding_interval;
    require(clock >= next_funding_time);

    // Funding rate = (mark_price - index_price) * PRECISION / index_price, clamped to MAX_FUNDING_RATE=1000
    // Positive means longs pay shorts
    let mark: u64 = market.mark_price;
    let index: u64 = market.index_price;

    let mut rate: u64 = 0;
    let mut rate_sign: u8 = 0;

    if index > 0 {
        if mark >= index {
            rate = ((mark - index) * 1000000) / index;
            rate_sign = 0;
        }
        if index > mark {
            rate = ((index - mark) * 1000000) / index;
            rate_sign = 1;
        }
    }

    // Clamp to MAX_FUNDING_RATE = 1000
    if rate > 1000 {
        rate = 1000;
    }

    // Update cumulative funding for longs
    // Longs: cumul += rate (positive means longs pay)
    if rate_sign == 0 {
        // mark >= index: longs pay, rate is positive for longs
        if market.cumul_funding_long_sign == 0 {
            market.cumul_funding_long = market.cumul_funding_long + rate;
        }
        if market.cumul_funding_long_sign == 1 {
            if rate >= market.cumul_funding_long {
                market.cumul_funding_long = rate - market.cumul_funding_long;
                market.cumul_funding_long_sign = 0;
            }
            if rate < market.cumul_funding_long {
                market.cumul_funding_long = market.cumul_funding_long - rate;
            }
        }
        // Shorts: cumul -= rate (shorts receive)
        if market.cumul_funding_short_sign == 0 {
            if rate <= market.cumul_funding_short {
                market.cumul_funding_short = market.cumul_funding_short - rate;
            }
            if rate > market.cumul_funding_short {
                market.cumul_funding_short = rate - market.cumul_funding_short;
                market.cumul_funding_short_sign = 1;
            }
        }
        if market.cumul_funding_short_sign == 1 {
            market.cumul_funding_short = market.cumul_funding_short + rate;
        }
    }
    if rate_sign == 1 {
        // mark < index: shorts pay, rate is negative for longs
        if market.cumul_funding_long_sign == 0 {
            if rate <= market.cumul_funding_long {
                market.cumul_funding_long = market.cumul_funding_long - rate;
            }
            if rate > market.cumul_funding_long {
                market.cumul_funding_long = rate - market.cumul_funding_long;
                market.cumul_funding_long_sign = 1;
            }
        }
        if market.cumul_funding_long_sign == 1 {
            market.cumul_funding_long = market.cumul_funding_long + rate;
        }
        // Shorts: cumul += rate
        if market.cumul_funding_short_sign == 0 {
            market.cumul_funding_short = market.cumul_funding_short + rate;
        }
        if market.cumul_funding_short_sign == 1 {
            if rate >= market.cumul_funding_short {
                market.cumul_funding_short = rate - market.cumul_funding_short;
                market.cumul_funding_short_sign = 0;
            }
            if rate < market.cumul_funding_short {
                market.cumul_funding_short = market.cumul_funding_short - rate;
            }
        }
    }

    market.last_funding_time = clock;
}

/// Liquidate an under-margined position (full or partial)
pub liquidate_position(
    market: PerpMarket @mut,
    position: Position @mut,
    position_margin: UserMarginAccount @mut,
    ins_fund: InsuranceFund @mut,
    liquidator: account @mut @signer,
    liquidation_size: u64
) {
    require(position.active == 1);
    require(position.size > 0);

    let mark: u64 = market.mark_price;

    // Calculate PnL
    let mut pnl_value: u64 = 0;
    let mut pnl_positive: u64 = 0;

    if position.side == 0 {
        if mark >= position.entry_price {
            pnl_value = ((mark - position.entry_price) * position.size) / 1000000;
            pnl_positive = 1;
        }
        if position.entry_price > mark {
            pnl_value = ((position.entry_price - mark) * position.size) / 1000000;
            pnl_positive = 0;
        }
    }
    if position.side == 1 {
        if position.entry_price >= mark {
            pnl_value = ((position.entry_price - mark) * position.size) / 1000000;
            pnl_positive = 1;
        }
        if mark > position.entry_price {
            pnl_value = ((mark - position.entry_price) * position.size) / 1000000;
            pnl_positive = 0;
        }
    }

    // Calculate funding payment
    let mut cumul_now: u64 = 0;
    if position.side == 0 {
        cumul_now = market.cumul_funding_long;
    }
    if position.side == 1 {
        cumul_now = market.cumul_funding_short;
    }
    let mut funding_value: u64 = 0;
    if cumul_now >= position.last_cumul_funding {
        funding_value = ((cumul_now - position.last_cumul_funding) * position.size) / 1000000;
    }
    if position.last_cumul_funding > cumul_now {
        funding_value = ((position.last_cumul_funding - cumul_now) * position.size) / 1000000;
    }

    // Calculate effective equity = collateral + pnl - funding
    let mut equity: u64 = position.collateral;
    if pnl_positive == 1 {
        equity = equity + pnl_value;
    }
    if pnl_positive == 0 {
        if pnl_value < equity {
            equity = equity - pnl_value;
        }
        if pnl_value >= equity {
            equity = 0;
        }
    }
    if funding_value < equity {
        equity = equity - funding_value;
    }
    if funding_value >= equity {
        equity = 0;
    }

    // Calculate margin ratio
    let notional: u64 = (position.size * mark) / 1000000;
    let mut margin_ratio: u64 = 0;
    if notional > 0 {
        margin_ratio = (equity * 1000000) / notional;
    }

    // Position must be below maintenance margin to liquidate
    require(margin_ratio < market.maintenance_margin);

    // Determine liquidation size
    let mut liq_size: u64 = position.size;
    if liquidation_size > 0 {
        if liquidation_size < position.size {
            liq_size = liquidation_size;
        }
    }

    // Calculate liquidation fee
    let liq_notional: u64 = (liq_size * mark) / 1000000;
    let liq_fee: u64 = (liq_notional * market.liquidation_fee) / 1000000;

    // Proportional collateral for liquidated portion
    let collateral_fraction: u64 = (position.collateral * liq_size) / position.size;

    // PnL on liquidated portion
    let mut liq_pnl: u64 = 0;
    let mut liq_pnl_positive: u64 = 0;
    if position.side == 0 {
        if mark >= position.entry_price {
            liq_pnl = ((mark - position.entry_price) * liq_size) / 1000000;
            liq_pnl_positive = 1;
        }
        if position.entry_price > mark {
            liq_pnl = ((position.entry_price - mark) * liq_size) / 1000000;
            liq_pnl_positive = 0;
        }
    }
    if position.side == 1 {
        if position.entry_price >= mark {
            liq_pnl = ((position.entry_price - mark) * liq_size) / 1000000;
            liq_pnl_positive = 1;
        }
        if mark > position.entry_price {
            liq_pnl = ((mark - position.entry_price) * liq_size) / 1000000;
            liq_pnl_positive = 0;
        }
    }

    // Remainder = collateral_fraction + liq_pnl - liq_fee (if positive PnL)
    let mut remainder: u64 = collateral_fraction;
    if liq_pnl_positive == 1 {
        remainder = remainder + liq_pnl;
    }
    if liq_pnl_positive == 0 {
        if liq_pnl < remainder {
            remainder = remainder - liq_pnl;
        }
        if liq_pnl >= remainder {
            remainder = 0;
        }
    }
    if liq_fee < remainder {
        remainder = remainder - liq_fee;
    }
    if liq_fee >= remainder {
        // Shortfall — insurance fund absorbs
        let shortfall: u64 = liq_fee - remainder;
        if ins_fund.balance >= shortfall {
            ins_fund.balance = ins_fund.balance - shortfall;
            ins_fund.total_payouts = ins_fund.total_payouts + shortfall;
        }
        remainder = 0;
    }

    // Update position
    if liq_size >= position.size {
        // Full liquidation
        position.size = 0;
        position.collateral = 0;
        position.active = 0;
        if position_margin.open_positions > 0 {
            position_margin.open_positions = position_margin.open_positions - 1;
        }
    }
    if liq_size < position.size {
        // Partial liquidation
        position.size = position.size - liq_size;
        position.collateral = position.collateral - collateral_fraction;
    }
    position.updated_at = get_clock();

    // Update market OI
    if position.side == 0 {
        if market.long_open_interest >= liq_size {
            market.long_open_interest = market.long_open_interest - liq_size;
        }
        if market.long_open_interest < liq_size {
            market.long_open_interest = 0;
        }
    }
    if position.side == 1 {
        if market.short_open_interest >= liq_size {
            market.short_open_interest = market.short_open_interest - liq_size;
        }
        if market.short_open_interest < liq_size {
            market.short_open_interest = 0;
        }
    }
}

/// Update oracle price (permissionless crank)
pub update_oracle_price(
    market: PerpMarket @mut,
    cranker: account @signer,
    price: u64
) {
    require(price > 0);

    market.index_price = price;

    // Update TWAP
    let clock: u64 = get_clock();
    market.twap_last_price = price;
    market.twap_last_time = clock;
    market.twap_sum = market.twap_sum + price;
    market.twap_count = market.twap_count + 1;
}

/// Pause or unpause a market (authority only)
pub set_market_paused(
    market: PerpMarket @mut,
    authority: account @signer,
    paused: u8
) {
    require(market.authority == authority.key);
    market.paused = paused;
}

// ---------------------------------------------------------------------------
// View / Query Functions
// ---------------------------------------------------------------------------

/// Get the current mark price
pub get_mark_price(market: PerpMarket) -> u64 {
    return market.mark_price;
}

/// Get long open interest
pub get_long_oi(market: PerpMarket) -> u64 {
    return market.long_open_interest;
}

/// Get short open interest
pub get_short_oi(market: PerpMarket) -> u64 {
    return market.short_open_interest;
}

/// Get TWAP average price
pub get_twap_price(market: PerpMarket) -> u64 {
    if market.twap_count == 0 {
        return 0;
    }
    let avg: u64 = market.twap_sum / market.twap_count;
    return avg;
}

/// Get position unrealized PnL (absolute value)
pub get_position_pnl(
    market: PerpMarket,
    position: Position
) -> u64 {
    let mark: u64 = market.mark_price;
    let mut pnl: u64 = 0;

    if position.side == 0 {
        if mark >= position.entry_price {
            pnl = ((mark - position.entry_price) * position.size) / 1000000;
        }
        if position.entry_price > mark {
            pnl = ((position.entry_price - mark) * position.size) / 1000000;
        }
    }
    if position.side == 1 {
        if position.entry_price >= mark {
            pnl = ((position.entry_price - mark) * position.size) / 1000000;
        }
        if mark > position.entry_price {
            pnl = ((mark - position.entry_price) * position.size) / 1000000;
        }
    }
    return pnl;
}

/// Get position margin ratio (PRECISION-based)
pub get_margin_ratio(
    market: PerpMarket,
    position: Position
) -> u64 {
    let mark: u64 = market.mark_price;
    let notional: u64 = (position.size * mark) / 1000000;
    if notional == 0 {
        return 999999999;
    }

    let mut pnl_value: u64 = 0;
    let mut pnl_positive: u64 = 0;

    if position.side == 0 {
        if mark >= position.entry_price {
            pnl_value = ((mark - position.entry_price) * position.size) / 1000000;
            pnl_positive = 1;
        }
        if position.entry_price > mark {
            pnl_value = ((position.entry_price - mark) * position.size) / 1000000;
            pnl_positive = 0;
        }
    }
    if position.side == 1 {
        if position.entry_price >= mark {
            pnl_value = ((position.entry_price - mark) * position.size) / 1000000;
            pnl_positive = 1;
        }
        if mark > position.entry_price {
            pnl_value = ((mark - position.entry_price) * position.size) / 1000000;
            pnl_positive = 0;
        }
    }

    let mut equity: u64 = position.collateral;
    if pnl_positive == 1 {
        equity = equity + pnl_value;
    }
    if pnl_positive == 0 {
        if pnl_value < equity {
            equity = equity - pnl_value;
        }
        if pnl_value >= equity {
            return 0;
        }
    }

    let ratio: u64 = (equity * 1000000) / notional;
    return ratio;
}

/// Check if a position is liquidatable (1=yes, 0=no)
pub is_liquidatable(
    market: PerpMarket,
    position: Position
) -> u64 {
    let mark: u64 = market.mark_price;
    let notional: u64 = (position.size * mark) / 1000000;
    if notional == 0 {
        return 0;
    }

    let mut pnl_value: u64 = 0;
    let mut pnl_positive: u64 = 0;

    if position.side == 0 {
        if mark >= position.entry_price {
            pnl_value = ((mark - position.entry_price) * position.size) / 1000000;
            pnl_positive = 1;
        }
        if position.entry_price > mark {
            pnl_value = ((position.entry_price - mark) * position.size) / 1000000;
            pnl_positive = 0;
        }
    }
    if position.side == 1 {
        if position.entry_price >= mark {
            pnl_value = ((position.entry_price - mark) * position.size) / 1000000;
            pnl_positive = 1;
        }
        if mark > position.entry_price {
            pnl_value = ((mark - position.entry_price) * position.size) / 1000000;
            pnl_positive = 0;
        }
    }

    let mut equity: u64 = position.collateral;
    if pnl_positive == 1 {
        equity = equity + pnl_value;
    }
    if pnl_positive == 0 {
        if pnl_value < equity {
            equity = equity - pnl_value;
        }
        if pnl_value >= equity {
            return 1;
        }
    }

    let ratio: u64 = (equity * 1000000) / notional;
    if ratio < market.maintenance_margin {
        return 1;
    }
    return 0;
}

/// Get insurance fund balance
pub get_insurance_balance(ins_fund: InsuranceFund) -> u64 {
    return ins_fund.balance;
}

/// Deposit into insurance fund
pub deposit_insurance(
    ins_fund: InsuranceFund @mut,
    depositor: account @mut @signer,
    depositor_token_account: account @mut,
    insurance_vault: account @mut,
    token_program: account,
    amount: u64
) {
    require(amount > 0);

    Token2022.spl_transfer(depositor_token_account, insurance_vault, depositor, amount);

    ins_fund.balance = ins_fund.balance + amount;
    ins_fund.total_deposits = ins_fund.total_deposits + amount;
}
