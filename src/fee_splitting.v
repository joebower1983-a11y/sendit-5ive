// Send.it Fee Splitting Module — ported from Anchor to 5IVE DSL
// Simplified: no Vec, no String, max 5 splits flattened

account FeeConfig {
    token_mint: pubkey;
    creator: pubkey;
    split_count: u8;
    split1_recipient: pubkey;
    split1_bps: u64;
    split2_recipient: pubkey;
    split2_bps: u64;
    split3_recipient: pubkey;
    split3_bps: u64;
    split4_recipient: pubkey;
    split4_bps: u64;
    split5_recipient: pubkey;
    split5_bps: u64;
    total_distributed: u64;
    has_distributed: u8;
    allow_update: u8;
    bump: u8;
}

account UserFeeClaim {
    recipient: pubkey;
    token_mint: pubkey;
    total_allocated: u64;
    total_claimed: u64;
    bump: u8;
}

pub initialize_fee_config(
    config: FeeConfig @mut @init(payer=creator, space=512) @signer,
    creator: account @mut @signer,
    token_mint: pubkey,
    split_count: u8,
    split1_recipient: pubkey,
    split1_bps: u64,
    allow_update: u8
) {
    require(split_count >= 1);
    require(split_count <= 5);
    require(split1_bps <= 10000);

    config.token_mint = token_mint;
    config.creator = creator.key;
    config.split_count = split_count;
    config.split1_recipient = split1_recipient;
    config.split1_bps = split1_bps;
    config.split2_recipient = 0;
    config.split2_bps = 0;
    config.split3_recipient = 0;
    config.split3_bps = 0;
    config.split4_recipient = 0;
    config.split4_bps = 0;
    config.split5_recipient = 0;
    config.split5_bps = 0;
    config.total_distributed = 0;
    config.has_distributed = 0;
    config.allow_update = allow_update;
    config.bump = 0;
}

pub add_split(
    config: FeeConfig @mut,
    creator: account @signer,
    slot_index: u8,
    recipient: pubkey,
    share_bps: u64
) {
    require(config.creator == creator.key);
    require(share_bps <= 10000);

    if slot_index == 2 {
        config.split2_recipient = recipient;
        config.split2_bps = share_bps;
    }
    if slot_index == 3 {
        config.split3_recipient = recipient;
        config.split3_bps = share_bps;
    }
    if slot_index == 4 {
        config.split4_recipient = recipient;
        config.split4_bps = share_bps;
    }
    if slot_index == 5 {
        config.split5_recipient = recipient;
        config.split5_bps = share_bps;
    }
}

pub distribute_fees(
    config: FeeConfig @mut,
    claim1: UserFeeClaim @mut,
    payer: account @signer,
    available: u64
) {
    require(available > 0);

    let share1: u64 = (available * config.split1_bps) / 10000;
    claim1.total_allocated = claim1.total_allocated + share1;

    config.total_distributed = config.total_distributed + available;
    config.has_distributed = 1;
}

pub init_user_fee_claim(
    claim: UserFeeClaim @mut @init(payer=payer, space=128) @signer,
    payer: account @mut @signer,
    recipient: pubkey,
    token_mint: pubkey
) {
    claim.recipient = recipient;
    claim.token_mint = token_mint;
    claim.total_allocated = 0;
    claim.total_claimed = 0;
    claim.bump = 0;
}

pub claim_split_fees(
    claim: UserFeeClaim @mut,
    recipient: account @signer
) -> u64 {
    require(claim.recipient == recipient.key);

    let claimable: u64 = claim.total_allocated - claim.total_claimed;
    require(claimable > 0);

    claim.total_claimed = claim.total_allocated;
    return claimable;
}
