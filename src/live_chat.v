// Send.it Live Chat Module — ported from Anchor to 5IVE DSL
// Note: string fields not supported in accounts; text stored off-chain
// On-chain tracks message metadata only

// ---------------------------------------------------------------------------
// Accounts
// ---------------------------------------------------------------------------

account ChatRoom {
    token_mint: pubkey;
    creator: pubkey;
    authority: pubkey;
    message_count: u64;
    is_active: u8;
    slowmode_seconds: u64;
    bump: u8;
}

account LiveMessage {
    chat_room: pubkey;
    index: u64;
    author: pubkey;
    text_hash: pubkey;
    timestamp: u64;
    tips_received: u64;
    bump: u8;
}

account UserChatState {
    chat_room: pubkey;
    user: pubkey;
    last_message_ts: u64;
    bump: u8;
}

// ---------------------------------------------------------------------------
// Instructions
// ---------------------------------------------------------------------------

/// Initialize a chat room for a token launch
pub initialize_chat_room(
    chat_room: ChatRoom @mut @init(payer=creator, space=256) @signer,
    creator: account @mut @signer,
    authority: account,
    token_mint: account,
    slowmode_seconds: u64
) {
    require(slowmode_seconds <= 300);

    chat_room.token_mint = token_mint.key;
    chat_room.creator = creator.key;
    chat_room.authority = authority.key;
    chat_room.message_count = 0;
    chat_room.is_active = 1;
    chat_room.slowmode_seconds = slowmode_seconds;
    chat_room.bump = 0;
}

/// Send a live message (text stored off-chain, hash on-chain)
pub send_live_message(
    chat_room: ChatRoom @mut,
    live_message: LiveMessage @mut @init(payer=author, space=256) @signer,
    user_chat_state: UserChatState @mut @init(payer=author, space=128) @signer,
    author: account @mut @signer,
    text_hash: pubkey,
    tip_lamports: u64
) {
    require(chat_room.is_active == 1);

    let clock: u64 = get_clock();

    // Rate limit check
    if user_chat_state.last_message_ts > 0 {
        if chat_room.slowmode_seconds > 0 {
            let elapsed: u64 = clock - user_chat_state.last_message_ts;
            require(elapsed >= chat_room.slowmode_seconds);
        }
    }

    user_chat_state.chat_room = chat_room.token_mint;
    user_chat_state.user = author.key;
    user_chat_state.last_message_ts = clock;
    user_chat_state.bump = 0;

    // Write message
    let index: u64 = chat_room.message_count;
    live_message.chat_room = chat_room.token_mint;
    live_message.index = index;
    live_message.author = author.key;
    live_message.text_hash = text_hash;
    live_message.timestamp = clock;
    live_message.tips_received = tip_lamports;
    live_message.bump = 0;

    // Increment room counter
    chat_room.message_count = chat_room.message_count + 1;
}

/// Toggle slowmode duration (creator only)
pub toggle_slowmode(
    chat_room: ChatRoom @mut,
    signer: account @signer,
    slowmode_seconds: u64
) {
    require(slowmode_seconds <= 300);
    require(signer.key == chat_room.creator);

    chat_room.slowmode_seconds = slowmode_seconds;
}

/// Close the chat room (creator only)
pub close_chat(
    chat_room: ChatRoom @mut,
    signer: account @signer
) {
    require(signer.key == chat_room.creator);

    chat_room.is_active = 0;
}

/// Get message count (view)
pub get_message_count(
    chat_room: ChatRoom
) -> u64 {
    return chat_room.message_count;
}
