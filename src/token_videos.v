// Send.it Token Videos Module — ported from Anchor to 5IVE DSL
// is_upvote: 1 = upvote, 0 = downvote

// ---------------------------------------------------------------------------
// Accounts
// ---------------------------------------------------------------------------

account TokenVideo {
    creator: pubkey;
    video_url_hash: pubkey;
    thumbnail_url_hash: pubkey;
    description_hash: pubkey;
    upvotes: u64;
    downvotes: u64;
    posted_at: u64;
    token_mint: pubkey;
    bump: u8;
}

account UserVideoVote {
    user: pubkey;
    token_mint: pubkey;
    is_upvote: u8;
    bump: u8;
}

// ---------------------------------------------------------------------------
// Instructions
// ---------------------------------------------------------------------------

/// Creator sets or updates the video pitch for their token
pub set_token_video(
    token_video: TokenVideo @mut @init(payer=creator, space=1024) @signer,
    creator: account @mut @signer,
    token_mint: account
) {
    let clock: u64 = get_clock();

    token_video.creator = creator.key;
    token_video.posted_at = clock;
    token_video.token_mint = token_mint.key;
    token_video.upvotes = 0;
    token_video.downvotes = 0;
    token_video.bump = 0;
}

/// Upvote a token video (one vote per user via separate vote account)
pub upvote_video(
    token_video: TokenVideo @mut,
    user_vote: UserVideoVote @mut @init(payer=voter, space=128) @signer,
    voter: account @mut @signer,
    token_mint: account
) {
    user_vote.user = voter.key;
    user_vote.token_mint = token_mint.key;
    user_vote.is_upvote = 1;
    user_vote.bump = 0;

    token_video.upvotes = token_video.upvotes + 1;
}

/// Downvote a token video (one vote per user via separate vote account)
pub downvote_video(
    token_video: TokenVideo @mut,
    user_vote: UserVideoVote @mut @init(payer=voter, space=128) @signer,
    voter: account @mut @signer,
    token_mint: account
) {
    user_vote.user = voter.key;
    user_vote.token_mint = token_mint.key;
    user_vote.is_upvote = 0;
    user_vote.bump = 0;

    token_video.downvotes = token_video.downvotes + 1;
}

/// Remove a token video (creator only)
pub remove_video(
    token_video: TokenVideo @mut,
    authority: account @signer
) {
    require(token_video.creator == authority.key);

    // Soft removal: zero out fields
    token_video.upvotes = 0;
    token_video.downvotes = 0;
    token_video.posted_at = 0;
}

/// Get total votes (view)
pub get_total_video_votes(
    token_video: TokenVideo
) -> u64 {
    let total: u64 = token_video.upvotes + token_video.downvotes;
    return total;
}
