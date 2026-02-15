// Send.it Content Claims Module — ported from Anchor to 5IVE DSL
// Simplified: no Option, no String, no events

account ContentClaim {
    token_mint: pubkey;
    original_creator: pubkey;
    claimed_by: pubkey;
    claim_status: u8;
    claimed_at: u64;
    fee_redirect_bps: u64;
    bump: u8;
}

account ClaimVerification {
    token_mint: pubkey;
    claimant: pubkey;
    submitted_at: u64;
    resolved: u8;
    bump: u8;
}

pub register_content(
    claim: ContentClaim @mut @init(payer=creator, space=256) @signer,
    creator: account @mut @signer,
    token_mint: pubkey,
    fee_redirect_bps: u64
) {
    require(fee_redirect_bps <= 10000);

    claim.token_mint = token_mint;
    claim.original_creator = creator.key;
    claim.claimed_by = 0;
    claim.claim_status = 0;
    claim.claimed_at = 0;

    if fee_redirect_bps == 0 {
        claim.fee_redirect_bps = 5000;
    }
    if fee_redirect_bps > 0 {
        claim.fee_redirect_bps = fee_redirect_bps;
    }

    claim.bump = 0;
}

pub submit_claim(
    claim: ContentClaim @mut,
    verification: ClaimVerification @mut @init(payer=claimant, space=128) @signer,
    claimant: account @mut @signer,
    token_mint: pubkey
) {
    require(claim.claim_status == 0);

    claim.claim_status = 1;
    claim.claimed_by = claimant.key;

    let clock: u64 = get_clock();

    verification.token_mint = token_mint;
    verification.claimant = claimant.key;
    verification.submitted_at = clock;
    verification.resolved = 0;
    verification.bump = 0;
}

pub verify_claim(
    claim: ContentClaim @mut,
    verification: ClaimVerification @mut,
    authority: account @signer
) {
    require(claim.claim_status == 1);

    let clock: u64 = get_clock();
    claim.claim_status = 2;
    claim.claimed_at = clock;
    verification.resolved = 1;
}

pub reject_claim(
    claim: ContentClaim @mut,
    verification: ClaimVerification @mut,
    authority: account @signer
) {
    require(claim.claim_status == 1);

    claim.claim_status = 3;
    claim.claimed_by = 0;
    verification.resolved = 1;
}

pub redirect_fees(
    claim: ContentClaim,
    payer: account @signer,
    amount: u64
) -> u64 {
    require(claim.claim_status == 2);

    let redirect_amount: u64 = (amount * claim.fee_redirect_bps) / 10000;
    return redirect_amount;
}
