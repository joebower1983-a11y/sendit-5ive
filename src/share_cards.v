// Send.it Share Cards Module — ported from Anchor to 5IVE DSL

// ---------------------------------------------------------------------------
// Accounts
// ---------------------------------------------------------------------------

account ShareCard {
    current_price: u64;
    market_cap: u64;
    volume_24h: u64;
    holder_count: u64;
    creator: pubkey;
    migration_progress_bps: u64;
    last_updated: u64;
    token_mint: pubkey;
    bump: u8;
}

// ---------------------------------------------------------------------------
// Instructions
// ---------------------------------------------------------------------------

/// Permissionless crank to refresh share card with latest on-chain data
pub update_share_card(
    share_card: ShareCard @mut @init(payer=payer, space=256) @signer,
    payer: account @mut @signer,
    token_mint: account,
    current_price: u64,
    market_cap: u64,
    volume_24h: u64,
    holder_count: u64,
    creator: pubkey,
    migration_progress_bps: u64
) {
    require(migration_progress_bps <= 10000);

    let clock: u64 = get_clock();

    share_card.current_price = current_price;
    share_card.market_cap = market_cap;
    share_card.volume_24h = volume_24h;
    share_card.holder_count = holder_count;
    share_card.creator = creator;
    share_card.migration_progress_bps = migration_progress_bps;
    share_card.last_updated = clock;
    share_card.token_mint = token_mint.key;
    share_card.bump = 0;
}

/// Get share card price (view function)
pub get_share_card_price(
    share_card: ShareCard
) -> u64 {
    return share_card.current_price;
}

/// Get share card market cap (view function)
pub get_share_card_market_cap(
    share_card: ShareCard
) -> u64 {
    return share_card.market_cap;
}
