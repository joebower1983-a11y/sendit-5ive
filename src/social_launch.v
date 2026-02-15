// Send.it Social Launch Module — ported from Anchor to 5IVE DSL
// Tweet-to-launch: create tokens by posting a tweet URL

// ---------------------------------------------------------------------------
// Accounts
// ---------------------------------------------------------------------------

account SocialLaunchConfig {
    authority: pubkey;
    verifier_authority: pubkey;
    require_verification: u8;
    default_curve_type: u8;
    default_creator_fee_bps: u64;
    verification_grace_period: u64;
    total_social_launches: u64;
    bump: u8;
}

account SocialLaunchRecord {
    creator: pubkey;
    mint: pubkey;
    tweet_id_hash: pubkey;
    author_handle_hash: pubkey;
    verified: u8;
    created_at: u64;
    verified_at: u64;
    trading_starts_at: u64;
    creator_fee_bps: u64;
    curve_type: u8;
    bump: u8;
}

account TweetVerification {
    tweet_id_hash: pubkey;
    author_handle_hash: pubkey;
    verified: u8;
    verified_by: pubkey;
    verified_at: u64;
    associated_mint: pubkey;
    bump: u8;
}

// ---------------------------------------------------------------------------
// Instructions
// ---------------------------------------------------------------------------

/// Initialize the social launch module config
pub initialize_social_config(
    social_config: SocialLaunchConfig @mut @init(payer=authority, space=256) @signer,
    authority: account @mut @signer,
    verifier_authority: pubkey,
    require_verification: u8,
    default_curve_type: u8,
    default_creator_fee_bps: u64,
    verification_grace_period: u64
) {
    social_config.authority = authority.key;
    social_config.verifier_authority = verifier_authority;
    social_config.require_verification = require_verification;
    social_config.default_curve_type = default_curve_type;
    social_config.default_creator_fee_bps = default_creator_fee_bps;
    social_config.verification_grace_period = verification_grace_period;
    social_config.total_social_launches = 0;
    social_config.bump = 0;
}

/// Update social launch config
pub update_social_config(
    social_config: SocialLaunchConfig @mut,
    authority: account @signer,
    new_verifier: pubkey,
    new_require_verification: u8,
    new_default_fee_bps: u64
) {
    require(authority.key == social_config.authority);
    require(new_default_fee_bps <= 500);

    social_config.verifier_authority = new_verifier;
    social_config.require_verification = new_require_verification;
    social_config.default_creator_fee_bps = new_default_fee_bps;
}

/// Launch a token from a tweet
pub launch_from_tweet(
    social_launch_record: SocialLaunchRecord @mut @init(payer=creator, space=512) @signer,
    social_config: SocialLaunchConfig @mut,
    creator: account @mut @signer,
    mint: pubkey,
    tweet_id_hash: pubkey,
    author_handle_hash: pubkey,
    creator_fee_bps: u64,
    curve_type: u8
) {
    require(creator_fee_bps <= 500);

    let clock: u64 = get_clock();

    let mut trading_starts: u64 = clock;
    if social_config.require_verification == 1 {
        trading_starts = clock + social_config.verification_grace_period;
    }

    social_launch_record.creator = creator.key;
    social_launch_record.mint = mint;
    social_launch_record.tweet_id_hash = tweet_id_hash;
    social_launch_record.author_handle_hash = author_handle_hash;
    social_launch_record.verified = 0;
    social_launch_record.created_at = clock;
    social_launch_record.verified_at = 0;
    social_launch_record.trading_starts_at = trading_starts;
    social_launch_record.creator_fee_bps = creator_fee_bps;
    social_launch_record.curve_type = curve_type;
    social_launch_record.bump = 0;

    social_config.total_social_launches = social_config.total_social_launches + 1;
}

/// Verify a tweet (oracle/verifier only)
pub verify_tweet(
    tweet_verification: TweetVerification @mut @init(payer=verifier, space=256) @signer,
    social_launch_record: SocialLaunchRecord @mut,
    social_config: SocialLaunchConfig,
    verifier: account @mut @signer,
    tweet_id_hash: pubkey,
    author_handle_hash: pubkey,
    verified: u8
) {
    require(verifier.key == social_config.verifier_authority);

    let clock: u64 = get_clock();

    tweet_verification.tweet_id_hash = tweet_id_hash;
    tweet_verification.author_handle_hash = author_handle_hash;
    tweet_verification.verified = verified;
    tweet_verification.verified_by = verifier.key;
    tweet_verification.verified_at = clock;
    tweet_verification.associated_mint = social_launch_record.mint;
    tweet_verification.bump = 0;

    social_launch_record.verified = verified;
    social_launch_record.verified_at = clock;
}

/// Revoke verification (admin only)
pub revoke_verification(
    tweet_verification: TweetVerification @mut,
    social_launch_record: SocialLaunchRecord @mut,
    social_config: SocialLaunchConfig,
    authority: account @signer
) {
    require(authority.key == social_config.authority);

    tweet_verification.verified = 0;
    social_launch_record.verified = 0;
}

/// View: get total social launches
pub get_total_social_launches(
    social_config: SocialLaunchConfig
) -> u64 {
    return social_config.total_social_launches;
}
