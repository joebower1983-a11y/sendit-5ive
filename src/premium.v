// Send.it Premium Listing Module — ported from Anchor to 5IVE DSL

// ---------------------------------------------------------------------------
// Accounts
// ---------------------------------------------------------------------------

account PremiumConfig {
    authority: pubkey;
    treasury: pubkey;
    promoted_price_per_hour: u64;
    featured_price_per_hour: u64;
    spotlight_price_per_hour: u64;
    bump: u8;
}

account PremiumListing {
    token_mint: pubkey;
    purchaser: pubkey;
    tier: u8;
    start_time: u64;
    duration: u64;
    amount_paid: u64;
    active: u8;
    bump: u8;
}

// ---------------------------------------------------------------------------
// Instructions
// ---------------------------------------------------------------------------

/// Initialize the premium config
pub initialize_premium_config(
    config: PremiumConfig @mut @init(payer=authority, space=256) @signer,
    authority: account @mut @signer,
    treasury: account,
    promoted_price_per_hour: u64,
    featured_price_per_hour: u64,
    spotlight_price_per_hour: u64
) {
    config.authority = authority.key;
    config.treasury = treasury.key;
    config.promoted_price_per_hour = promoted_price_per_hour;
    config.featured_price_per_hour = featured_price_per_hour;
    config.spotlight_price_per_hour = spotlight_price_per_hour;
    config.bump = 0;
}

/// Purchase a premium listing
/// tier: 0=Promoted, 1=Featured, 2=Spotlight
pub purchase_premium(
    listing: PremiumListing @mut @init(payer=purchaser, space=256) @signer,
    config: PremiumConfig,
    purchaser: account @mut @signer,
    token_mint: account,
    duration_hours: u64,
    tier: u8
) {
    require(duration_hours > 0);
    require(duration_hours <= 720);
    require(tier <= 2);

    let clock: u64 = get_clock();

    // Calculate price per hour based on tier
    let mut price_per_hour: u64 = config.promoted_price_per_hour;
    if tier == 1 {
        price_per_hour = config.featured_price_per_hour;
    }
    if tier == 2 {
        price_per_hour = config.spotlight_price_per_hour;
    }

    let total_cost: u64 = price_per_hour * duration_hours;
    let duration_seconds: u64 = duration_hours * 3600;

    listing.token_mint = token_mint.key;
    listing.purchaser = purchaser.key;
    listing.tier = tier;
    listing.start_time = clock;
    listing.duration = duration_seconds;
    listing.amount_paid = total_cost;
    listing.active = 1;
    listing.bump = 0;
}

/// Check if a premium listing is still active; deactivate if expired
pub check_premium_status(
    listing: PremiumListing @mut
) -> u8 {
    if listing.active == 0 {
        return 0;
    }

    let clock: u64 = get_clock();
    let expires_at: u64 = listing.start_time + listing.duration;

    if clock >= expires_at {
        listing.active = 0;
        return 0;
    }

    return 1;
}

/// Get time remaining on a listing
pub get_time_remaining(
    listing: PremiumListing
) -> u64 {
    if listing.active == 0 {
        return 0;
    }

    let clock: u64 = get_clock();
    let expires_at: u64 = listing.start_time + listing.duration;

    if clock >= expires_at {
        return 0;
    }

    return expires_at - clock;
}
