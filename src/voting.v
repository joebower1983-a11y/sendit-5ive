// Send.it Voting Module — ported from Anchor to 5IVE DSL

// ---------------------------------------------------------------------------
// Accounts
// ---------------------------------------------------------------------------

account Proposal {
    proposal_id: u64;
    token_mint: pubkey;
    creator: pubkey;
    option_count: u8;
    option0_votes: u64;
    option1_votes: u64;
    option2_votes: u64;
    option3_votes: u64;
    start_time: u64;
    end_time: u64;
    quorum: u64;
    total_votes: u64;
    status: u8;
    bump: u8;
}

account UserVote {
    proposal: pubkey;
    voter: pubkey;
    option_index: u8;
    weight: u64;
    timestamp: u64;
    bump: u8;
}

// ---------------------------------------------------------------------------
// Instructions
// ---------------------------------------------------------------------------

pub create_proposal(
    proposal: Proposal @mut @init(payer=creator, space=512) @signer,
    creator: account @mut @signer,
    token_mint: pubkey,
    option_count: u8,
    start_time: u64,
    end_time: u64,
    quorum: u64,
    proposal_id: u64
) {
    require(option_count >= 2);
    require(option_count <= 4);
    require(end_time > start_time);

    proposal.proposal_id = proposal_id;
    proposal.token_mint = token_mint;
    proposal.creator = creator.key;
    proposal.option_count = option_count;
    proposal.option0_votes = 0;
    proposal.option1_votes = 0;
    proposal.option2_votes = 0;
    proposal.option3_votes = 0;
    proposal.start_time = start_time;
    proposal.end_time = end_time;
    proposal.quorum = quorum;
    proposal.total_votes = 0;
    proposal.status = 1;
    proposal.bump = 0;
}

pub cast_vote(
    proposal: Proposal @mut,
    user_vote: UserVote @mut @init(payer=voter, space=256) @signer,
    voter: account @mut @signer,
    option_index: u8,
    weight: u64
) {
    require(proposal.status == 1);
    let clock: u64 = get_clock();
    require(clock >= proposal.start_time);
    require(clock <= proposal.end_time);
    require(option_index < proposal.option_count);
    require(weight > 0);

    if option_index == 0 {
        proposal.option0_votes = proposal.option0_votes + weight;
    }
    if option_index == 1 {
        proposal.option1_votes = proposal.option1_votes + weight;
    }
    if option_index == 2 {
        proposal.option2_votes = proposal.option2_votes + weight;
    }
    if option_index == 3 {
        proposal.option3_votes = proposal.option3_votes + weight;
    }

    proposal.total_votes = proposal.total_votes + weight;

    user_vote.proposal = proposal.token_mint;
    user_vote.voter = voter.key;
    user_vote.option_index = option_index;
    user_vote.weight = weight;
    user_vote.timestamp = clock;
    user_vote.bump = 0;
}

pub finalize_proposal(
    proposal: Proposal @mut,
    finalizer: account @signer
) {
    require(proposal.status == 1);
    let clock: u64 = get_clock();
    require(clock > proposal.end_time);

    if proposal.total_votes >= proposal.quorum {
        proposal.status = 2;
    }
    if proposal.total_votes < proposal.quorum {
        proposal.status = 3;
    }
}

pub get_total_votes(
    proposal: Proposal
) -> u64 {
    return proposal.total_votes;
}
