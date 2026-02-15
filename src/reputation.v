// Send.it Reputation Module — ported from Anchor to 5IVE DSL
// tier: 0=Unscored, 1=Bronze, 2=Silver, 3=Gold, 4=Platinum

// ---------------------------------------------------------------------------
// Accounts
// ---------------------------------------------------------------------------

account ReputationConfig {
    authority: pubkey;
    oracle_authority: pubkey;
    min_score_to_launch: u8;
    min_score_premium_launch: u8;
    strict_vesting_threshold: u8;
    fee_discount_bronze_bps: u64;
    fee_discount_silver_bps: u64;
    fee_discount_gold_bps: u64;
    fee_discount_platinum_bps: u64;
    bump: u8;
}

account ReputationAttestation {
    wallet: pubkey;
    fairscore: u8;
    tier: u8;
    last_updated: u64;
    attested_by: pubkey;
    bump: u8;
}

// ---------------------------------------------------------------------------
// Instructions
// ---------------------------------------------------------------------------

/// Initialize the reputation config
pub initialize_reputation_config(
    config: ReputationConfig @mut @init(payer=authority, space=256) @signer,
    authority: account @mut @signer,
    oracle_authority: pubkey
) {
    config.authority = authority.key;
    config.oracle_authority = oracle_authority;
    config.min_score_to_launch = 30;
    config.min_score_premium_launch = 60;
    config.strict_vesting_threshold = 40;
    config.fee_discount_bronze_bps = 0;
    config.fee_discount_silver_bps = 500;
    config.fee_discount_gold_bps = 1000;
    config.fee_discount_platinum_bps = 2000;
    config.bump = 0;
}

/// Update reputation config (authority only)
pub update_reputation_config(
    config: ReputationConfig @mut,
    authority: account @signer,
    min_score_to_launch: u8,
    min_score_premium_launch: u8,
    strict_vesting_threshold: u8,
    fee_discount_bronze_bps: u64,
    fee_discount_silver_bps: u64,
    fee_discount_gold_bps: u64,
    fee_discount_platinum_bps: u64
) {
    require(config.authority == authority.key);

    config.min_score_to_launch = min_score_to_launch;
    config.min_score_premium_launch = min_score_premium_launch;
    config.strict_vesting_threshold = strict_vesting_threshold;
    config.fee_discount_bronze_bps = fee_discount_bronze_bps;
    config.fee_discount_silver_bps = fee_discount_silver_bps;
    config.fee_discount_gold_bps = fee_discount_gold_bps;
    config.fee_discount_platinum_bps = fee_discount_platinum_bps;
}

/// Oracle updates a wallet's reputation attestation
pub update_reputation(
    attestation: ReputationAttestation @mut @init(payer=oracle_authority, space=128) @signer,
    config: ReputationConfig,
    oracle_authority: account @mut @signer,
    wallet: pubkey,
    fairscore: u8,
    tier: u8
) {
    require(config.oracle_authority == oracle_authority.key);
    require(fairscore <= 100);
    require(tier <= 4);

    let clock: u64 = get_clock();

    attestation.wallet = wallet;
    attestation.fairscore = fairscore;
    attestation.tier = tier;
    attestation.last_updated = clock;
    attestation.attested_by = oracle_authority.key;
    attestation.bump = 0;
}

/// Check if wallet is eligible to launch (view-like)
/// premium: 1 = premium launch, 0 = standard launch
/// Returns 1 if eligible, 0 if not
pub check_launch_eligibility(
    attestation: ReputationAttestation,
    config: ReputationConfig,
    premium: u8
) -> u8 {
    if premium == 1 {
        if attestation.fairscore >= config.min_score_premium_launch {
            return 1;
        }
        return 0;
    }
    if attestation.fairscore >= config.min_score_to_launch {
        return 1;
    }
    return 0;
}

/// Get fee discount in basis points based on tier
pub get_fee_discount(
    attestation: ReputationAttestation,
    config: ReputationConfig
) -> u64 {
    if attestation.tier == 4 {
        return config.fee_discount_platinum_bps;
    }
    if attestation.tier == 3 {
        return config.fee_discount_gold_bps;
    }
    if attestation.tier == 2 {
        return config.fee_discount_silver_bps;
    }
    if attestation.tier == 1 {
        return config.fee_discount_bronze_bps;
    }
    return 0;
}

/// Get vesting multiplier: 2 for low rep, 1 for normal
pub get_vesting_multiplier(
    attestation: ReputationAttestation,
    config: ReputationConfig
) -> u8 {
    if attestation.fairscore < config.strict_vesting_threshold {
        return 2;
    }
    return 1;
}
