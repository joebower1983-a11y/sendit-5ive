// Send.it Airdrops Module — ported from Anchor to 5IVE DSL
// Token airdrop campaigns with claim tracking

// ---------------------------------------------------------------------------
// SPL Token CPI Interface
// ---------------------------------------------------------------------------

interface TokenProgram @program("TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA") {
    @discriminator(3)
    spl_transfer(from: account @mut, to: account @mut, authority: account @signer, amount: u64);
}

// ---------------------------------------------------------------------------
// Accounts
// ---------------------------------------------------------------------------

account AirdropCampaign {
    campaign_id: u64;
    token_mint: pubkey;
    creator: pubkey;
    vault: pubkey;
    total_amount: u64;
    claimed_count: u64;
    max_recipients: u64;
    snapshot_slot: u64;
    deadline: u64;
    is_active: u8;
    bump: u8;
    vault_bump: u8;
}

account AirdropClaim {
    campaign: pubkey;
    claimant: pubkey;
    amount: u64;
    claimed_at: u64;
    bump: u8;
}

// ---------------------------------------------------------------------------
// Instructions
// ---------------------------------------------------------------------------

/// Create a new airdrop campaign
pub create_airdrop(
    campaign: AirdropCampaign @mut @init(payer=creator, space=512) @signer,
    creator: account @mut @signer,
    token_mint: account,
    vault: account @mut,
    creator_token_account: account @mut,
    token_program: account,
    campaign_id: u64,
    total_amount: u64,
    max_recipients: u64,
    snapshot_slot: u64,
    deadline: u64
) {
    let clock: u64 = get_clock();
    require(deadline > clock);
    require(total_amount > 0);
    require(max_recipients > 0);

    // Transfer tokens from creator to vault
    TokenProgram.spl_transfer(creator_token_account, vault, creator, total_amount);

    campaign.campaign_id = campaign_id;
    campaign.token_mint = token_mint.key;
    campaign.creator = creator.key;
    campaign.vault = vault.key;
    campaign.total_amount = total_amount;
    campaign.claimed_count = 0;
    campaign.max_recipients = max_recipients;
    campaign.snapshot_slot = snapshot_slot;
    campaign.deadline = deadline;
    campaign.is_active = 1;
    campaign.bump = 0;
    campaign.vault_bump = 0;
}

/// Claim an airdrop (simplified — no merkle proof in DSL)
pub claim_airdrop(
    campaign: AirdropCampaign @mut,
    claim_receipt: AirdropClaim @mut @init(payer=claimant, space=256) @signer,
    claimant: account @mut @signer,
    vault: account @mut,
    claimant_token_account: account @mut,
    vault_authority: account @signer,
    token_program: account,
    amount: u64
) {
    require(campaign.is_active == 1);
    require(campaign.claimed_count < campaign.max_recipients);
    require(amount > 0);

    // Transfer from vault to claimant
    TokenProgram.spl_transfer(vault, claimant_token_account, vault_authority, amount);

    campaign.claimed_count = campaign.claimed_count + 1;

    let clock: u64 = get_clock();
    claim_receipt.campaign = campaign.token_mint;
    claim_receipt.claimant = claimant.key;
    claim_receipt.amount = amount;
    claim_receipt.claimed_at = clock;
    claim_receipt.bump = 0;
}

/// Cancel an airdrop after deadline (creator only)
pub cancel_airdrop(
    campaign: AirdropCampaign @mut,
    creator: account @mut @signer,
    vault: account @mut,
    creator_token_account: account @mut,
    vault_authority: account @signer,
    token_program: account,
    remaining_amount: u64
) {
    require(campaign.is_active == 1);
    require(creator.key == campaign.creator);

    let clock: u64 = get_clock();
    require(clock >= campaign.deadline);

    // Transfer remaining tokens back to creator
    TokenProgram.spl_transfer(vault, creator_token_account, vault_authority, remaining_amount);

    campaign.is_active = 0;
}

/// Get claimed count (view)
pub get_claimed_count(
    campaign: AirdropCampaign
) -> u64 {
    return campaign.claimed_count;
}

/// Check if campaign is active (view)
pub is_campaign_active(
    campaign: AirdropCampaign
) -> u8 {
    return campaign.is_active;
}
