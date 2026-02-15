interface Token2022 @program("TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb") {
    @discriminator(3)
    spl_transfer(from: account @mut, to: account @mut, authority: account @signer, amount: u64);
}
// Send.it Bridge Module — ported from Anchor to 5IVE DSL


// ---------------------------------------------------------------------------
// Accounts
// ---------------------------------------------------------------------------

account BridgeConfig {
    authority: pubkey;
    wormhole_program: pubkey;
    wormhole_bridge: pubkey;
    fee_collector: pubkey;
    total_bridged: u64;
    total_requests: u64;
    paused: u8;
    default_fee_bps: u64;
    default_min_amount: u64;
    bump: u8;
}

account BridgeRequest {
    user: pubkey;
    token_mint: pubkey;
    amount: u64;
    fee_amount: u64;
    net_amount: u64;
    destination_chain: u64;
    status: u8;
    created_at: u64;
    wormhole_sequence: u64;
    nonce: u64;
    bump: u8;
}

// ---------------------------------------------------------------------------
// Instructions
// ---------------------------------------------------------------------------

/// Initialize bridge config
pub initialize_bridge(
    bridge_config: BridgeConfig @mut @init(payer=authority, space=512) @signer,
    authority: account @mut @signer,
    wormhole_program: pubkey,
    wormhole_bridge: pubkey,
    fee_collector: pubkey,
    default_fee_bps: u64,
    default_min_amount: u64
) {
    bridge_config.authority = authority.key;
    bridge_config.wormhole_program = wormhole_program;
    bridge_config.wormhole_bridge = wormhole_bridge;
    bridge_config.fee_collector = fee_collector;
    bridge_config.total_bridged = 0;
    bridge_config.total_requests = 0;
    bridge_config.paused = 0;
    bridge_config.default_fee_bps = default_fee_bps;
    bridge_config.default_min_amount = default_min_amount;
    bridge_config.bump = 0;
}

/// Initiate a bridge request — locks tokens in vault
pub initiate_bridge(
    bridge_config: BridgeConfig @mut,
    bridge_request: BridgeRequest @mut @init(payer=user, space=256) @signer,
    user: account @mut @signer,
    user_token_account: account @mut,
    token_vault: account @mut,
    fee_vault: account @mut,
    token_program: account,
    amount: u64,
    destination_chain: u64,
    nonce: u64
) {
    require(bridge_config.paused == 0);
    require(amount >= bridge_config.default_min_amount);

    // Calculate fee
    let fee_amount: u64 = (amount * bridge_config.default_fee_bps) / 10000;
    let net_amount: u64 = amount - fee_amount;

    // Transfer net amount to vault
    Token2022.spl_transfer(user_token_account, token_vault, user, net_amount);

    // Transfer fee to fee vault
    if fee_amount > 0 {
        Token2022.spl_transfer(user_token_account, fee_vault, user, fee_amount);
    }

    let clock: u64 = get_clock();

    bridge_request.user = user.key;
    bridge_request.token_mint = bridge_config.wormhole_bridge;
    bridge_request.amount = amount;
    bridge_request.fee_amount = fee_amount;
    bridge_request.net_amount = net_amount;
    bridge_request.destination_chain = destination_chain;
    bridge_request.status = 0;
    bridge_request.created_at = clock;
    bridge_request.wormhole_sequence = 0;
    bridge_request.nonce = nonce;
    bridge_request.bump = 0;

    bridge_config.total_requests = bridge_config.total_requests + 1;
}

/// Confirm bridge after Wormhole VAA verification
pub confirm_bridge(
    bridge_config: BridgeConfig @mut,
    bridge_request: BridgeRequest @mut,
    authority: account @signer,
    wormhole_sequence: u64
) {
    require(authority.key == bridge_config.authority);
    require(bridge_request.status == 0);

    let clock: u64 = get_clock();
    let expiry: u64 = bridge_request.created_at + 86400;
    require(clock <= expiry);

    bridge_request.status = 2;
    bridge_request.wormhole_sequence = wormhole_sequence;

    bridge_config.total_bridged = bridge_config.total_bridged + bridge_request.net_amount;
}

/// Cancel an expired bridge request — returns tokens to user
pub cancel_bridge(
    bridge_config: BridgeConfig,
    bridge_request: BridgeRequest @mut,
    user: account @mut @signer,
    user_token_account: account @mut,
    token_vault: account @mut,
    vault_authority: account @signer,
    token_program: account
) {
    require(bridge_request.status == 0);
    require(bridge_request.user == user.key);

    let clock: u64 = get_clock();
    let expiry: u64 = bridge_request.created_at + 86400;
    require(clock > expiry);

    // Refund net amount from vault to user
    Token2022.spl_transfer(token_vault, user_token_account, vault_authority, bridge_request.net_amount);

    bridge_request.status = 3;
}

/// Pause/unpause bridge
pub set_bridge_paused(
    bridge_config: BridgeConfig @mut,
    authority: account @signer,
    paused: u8
) {
    require(authority.key == bridge_config.authority);
    bridge_config.paused = paused;
}

/// View: get total bridged
pub get_total_bridged(
    bridge_config: BridgeConfig
) -> u64 {
    return bridge_config.total_bridged;
}
