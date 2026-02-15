// Send.it Referral Module — ported from Anchor to 5IVE DSL

// ---------------------------------------------------------------------------
// Accounts
// ---------------------------------------------------------------------------

account ReferralConfig {
    authority: pubkey;
    referral_fee_bps: u64;
    treasury: pubkey;
    bump: u8;
}

account ReferralAccount {
    user: pubkey;
    referrer: pubkey;
    total_referred: u64;
    total_earned: u64;
    claimable: u64;
    registered_at: u64;
    bump: u8;
}

// ---------------------------------------------------------------------------
// Instructions
// ---------------------------------------------------------------------------

/// Initialize referral config
pub initialize_referral_config(
    config: ReferralConfig @mut @init(payer=authority, space=256) @signer,
    authority: account @mut @signer,
    treasury: account,
    referral_fee_bps: u64
) {
    require(referral_fee_bps <= 10000);

    config.authority = authority.key;
    config.referral_fee_bps = referral_fee_bps;
    config.treasury = treasury.key;
    config.bump = 0;
}

/// Register a referral account with an optional referrer
pub register_referral(
    referral_account: ReferralAccount @mut @init(payer=user, space=256) @signer,
    user: account @mut @signer,
    referrer_key: pubkey
) {
    let clock: u64 = get_clock();

    referral_account.user = user.key;
    referral_account.referrer = referrer_key;
    referral_account.total_referred = 0;
    referral_account.total_earned = 0;
    referral_account.claimable = 0;
    referral_account.registered_at = clock;
    referral_account.bump = 0;

    // Can't refer yourself
    require(referrer_key != user.key);
}

/// Credit referral reward to a referrer during a trade
pub credit_referral_reward(
    referrer_account: ReferralAccount @mut,
    config: ReferralConfig,
    fee_payer: account @mut @signer,
    platform_fee_lamports: u64
) {
    let referral_reward: u64 = (platform_fee_lamports * config.referral_fee_bps) / 10000;

    if referral_reward > 0 {
        referrer_account.total_earned = referrer_account.total_earned + referral_reward;
        referrer_account.claimable = referrer_account.claimable + referral_reward;
    }
}

/// Claim accumulated referral rewards
pub claim_referral_rewards(
    referral_account: ReferralAccount @mut,
    user: account @mut @signer
) {
    require(referral_account.user == user.key);
    require(referral_account.claimable > 0);

    let amount: u64 = referral_account.claimable;
    referral_account.claimable = 0;

    // Note: actual SOL transfer would use system program CPI
    // Amount is recorded; transfer handled via SDK/runtime
}

/// Get claimable amount (view)
pub get_claimable(
    referral_account: ReferralAccount
) -> u64 {
    return referral_account.claimable;
}

/// Get total referred count (view)
pub get_total_referred(
    referral_account: ReferralAccount
) -> u64 {
    return referral_account.total_referred;
}
