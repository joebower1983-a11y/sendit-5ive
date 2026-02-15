// Send.it Custom Pages Module — ported from Anchor to 5IVE DSL
// Note: string fields not supported in accounts; content stored off-chain
// On-chain stores hashes/references and tier info

// ---------------------------------------------------------------------------
// Accounts
// ---------------------------------------------------------------------------

account CustomPage {
    token_launch: pubkey;
    mint: pubkey;
    creator: pubkey;
    tier: u8;
    content_hash: pubkey;
    last_updated: u64;
    fee_paid: u64;
    bump: u8;
}

// ---------------------------------------------------------------------------
// Instructions
// ---------------------------------------------------------------------------

/// Create or update a custom page
/// tier: 0=Basic (free), 1=Pro, 2=Ultra
pub update_custom_page(
    page: CustomPage @mut @init(payer=creator, space=256) @signer,
    creator: account @mut @signer,
    token_launch: account,
    mint: account,
    tier: u8,
    content_hash: pubkey
) {
    require(tier <= 2);

    let clock: u64 = get_clock();

    // First-time init
    if page.bump == 0 {
        page.token_launch = token_launch.key;
        page.mint = mint.key;
        page.creator = creator.key;
        page.bump = 1;
    }

    require(page.creator == creator.key);

    // Calculate tier fee: 0=free, 1=100000000 (0.1 SOL), 2=500000000 (0.5 SOL)
    let mut new_fee: u64 = 0;
    if tier == 1 {
        new_fee = 100000000;
    }
    if tier == 2 {
        new_fee = 500000000;
    }

    page.tier = tier;
    page.content_hash = content_hash;
    page.last_updated = clock;
    page.fee_paid = page.fee_paid + new_fee;
}

/// Reset page to defaults (Basic tier)
pub reset_page(
    page: CustomPage @mut,
    creator: account @signer
) {
    require(page.creator == creator.key);

    let clock: u64 = get_clock();
    page.tier = 0;
    page.content_hash = 0;
    page.last_updated = clock;
}

/// Get page tier (view)
pub get_page_tier(
    page: CustomPage
) -> u8 {
    return page.tier;
}
