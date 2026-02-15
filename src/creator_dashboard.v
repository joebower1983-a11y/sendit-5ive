// Send.it Creator Dashboard Module — ported from Anchor to 5IVE DSL

// ---------------------------------------------------------------------------
// Accounts
// ---------------------------------------------------------------------------

account CreatorAnalytics {
    creator: pubkey;
    total_launches: u64;
    total_volume_generated: u64;
    total_fees_earned: u64;
    total_holders_across_tokens: u64;
    best_performing_token: pubkey;
    avg_graduation_time: u64;
    bump: u8;
}

account TokenAnalyticsSnapshot {
    token_mint: pubkey;
    current_slot: u64;
    latest_hourly_volume: u64;
    latest_holder_growth: u64;
    bump: u8;
}

// ---------------------------------------------------------------------------
// Instructions
// ---------------------------------------------------------------------------

/// Permissionless crank to update creator aggregate analytics
pub update_creator_analytics(
    creator_analytics: CreatorAnalytics @mut @init(payer=payer, space=256) @signer,
    payer: account @mut @signer,
    creator: account,
    total_launches: u64,
    total_volume_generated: u64,
    total_fees_earned: u64,
    total_holders_across_tokens: u64,
    best_performing_token: pubkey,
    avg_graduation_time: u64
) {
    creator_analytics.creator = creator.key;
    creator_analytics.total_launches = total_launches;
    creator_analytics.total_volume_generated = total_volume_generated;
    creator_analytics.total_fees_earned = total_fees_earned;
    creator_analytics.total_holders_across_tokens = total_holders_across_tokens;
    creator_analytics.best_performing_token = best_performing_token;
    creator_analytics.avg_graduation_time = avg_graduation_time;
    creator_analytics.bump = 0;
}

/// Update token-level analytics snapshot
pub update_token_snapshot(
    snapshot: TokenAnalyticsSnapshot @mut @init(payer=payer, space=128) @signer,
    payer: account @mut @signer,
    token_mint: account,
    hourly_volume_entry: u64,
    holder_growth_entry: u64
) {
    snapshot.token_mint = token_mint.key;
    snapshot.latest_hourly_volume = hourly_volume_entry;
    snapshot.latest_holder_growth = holder_growth_entry;
    snapshot.current_slot = snapshot.current_slot + 1;
    snapshot.bump = 0;
}

/// Get creator total volume (view function)
pub get_creator_volume(
    creator_analytics: CreatorAnalytics
) -> u64 {
    return creator_analytics.total_volume_generated;
}

/// Get creator total launches (view function)
pub get_creator_launches(
    creator_analytics: CreatorAnalytics
) -> u64 {
    return creator_analytics.total_launches;
}
