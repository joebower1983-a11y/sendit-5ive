// Send.it Analytics Module — ported from Anchor to 5IVE DSL
// Simplified: no arrays/ring buffers, no structs, no bool

account TokenAnalytics {
    token_mint: pubkey;
    total_volume: u64;
    total_trades: u64;
    holder_count: u64;
    last_update_slot: u64;
    last_snapshot_ts: u64;
    hourly_volume_current: u64;
    whale_tx_count: u64;
    last_whale_trader: pubkey;
    last_whale_amount: u64;
    last_whale_is_buy: u8;
    last_whale_ts: u64;
    bump: u8;
}

account WhaleTracker {
    token_mint: pubkey;
    holder_count: u8;
    top1_wallet: pubkey;
    top1_balance: u64;
    top2_wallet: pubkey;
    top2_balance: u64;
    top3_wallet: pubkey;
    top3_balance: u64;
    top4_wallet: pubkey;
    top4_balance: u64;
    top5_wallet: pubkey;
    top5_balance: u64;
    bump: u8;
}

pub initialize_analytics(
    analytics: TokenAnalytics @mut @init(payer=payer, space=256) @signer,
    tracker: WhaleTracker @mut @init(payer=payer, space=512) @signer,
    payer: account @mut @signer,
    token_mint: pubkey
) {
    let clock: u64 = get_clock();
    analytics.token_mint = token_mint;
    analytics.total_volume = 0;
    analytics.total_trades = 0;
    analytics.holder_count = 0;
    analytics.last_update_slot = 0;
    analytics.last_snapshot_ts = clock;
    analytics.hourly_volume_current = 0;
    analytics.whale_tx_count = 0;
    analytics.last_whale_trader = 0;
    analytics.last_whale_amount = 0;
    analytics.last_whale_is_buy = 0;
    analytics.last_whale_ts = 0;
    analytics.bump = 0;

    tracker.token_mint = token_mint;
    tracker.holder_count = 0;
    tracker.top1_wallet = 0;
    tracker.top1_balance = 0;
    tracker.top2_wallet = 0;
    tracker.top2_balance = 0;
    tracker.top3_wallet = 0;
    tracker.top3_balance = 0;
    tracker.top4_wallet = 0;
    tracker.top4_balance = 0;
    tracker.top5_wallet = 0;
    tracker.top5_balance = 0;
    tracker.bump = 0;
}

pub update_analytics(
    analytics: TokenAnalytics @mut,
    crank: account @signer,
    trade_volume: u64,
    is_buy: u8,
    trader: pubkey,
    current_holder_count: u64
) {
    analytics.total_volume = analytics.total_volume + trade_volume;
    analytics.total_trades = analytics.total_trades + 1;
    analytics.holder_count = current_holder_count;

    let clock: u64 = get_clock();
    analytics.last_update_slot = clock;

    // Track whale transactions (threshold: 1_000_000_000 lamports = 1 SOL)
    if trade_volume >= 1000000000 {
        analytics.whale_tx_count = analytics.whale_tx_count + 1;
        analytics.last_whale_trader = trader;
        analytics.last_whale_amount = trade_volume;
        analytics.last_whale_is_buy = is_buy;
        analytics.last_whale_ts = clock;
    }

    // Accumulate hourly volume
    analytics.hourly_volume_current = analytics.hourly_volume_current + trade_volume;

    // Reset hourly bucket every 3600 seconds
    let elapsed: u64 = clock - analytics.last_snapshot_ts;
    if elapsed >= 3600 {
        analytics.hourly_volume_current = trade_volume;
        analytics.last_snapshot_ts = clock;
    }
}

pub get_total_volume(
    analytics: TokenAnalytics
) -> u64 {
    return analytics.total_volume;
}

pub get_total_trades(
    analytics: TokenAnalytics
) -> u64 {
    return analytics.total_trades;
}
