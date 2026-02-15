// Send.it Token Chat Module — ported from Anchor to 5IVE DSL
// deleted: 1 = deleted, 0 = active

// ---------------------------------------------------------------------------
// Accounts
// ---------------------------------------------------------------------------

account ChatState {
    token_mint: pubkey;
    next_index: u64;
    bump: u8;
}

account ChatMessage {
    token_mint: pubkey;
    index: u64;
    author: pubkey;
    text_hash: pubkey;
    timestamp: u64;
    likes: u64;
    deleted: u8;
    bump: u8;
}

// ---------------------------------------------------------------------------
// Instructions
// ---------------------------------------------------------------------------

/// Initialize chat state for a token
pub initialize_chat_state(
    chat_state: ChatState @mut @init(payer=payer, space=128) @signer,
    payer: account @mut @signer,
    token_mint: account
) {
    chat_state.token_mint = token_mint.key;
    chat_state.next_index = 0;
    chat_state.bump = 0;
}

/// Post a message to a token's chat
pub post_message(
    chat_state: ChatState @mut,
    chat_message: ChatMessage @mut @init(payer=author, space=512) @signer,
    author: account @mut @signer,
    token_mint: account
) {
    let clock: u64 = get_clock();

    chat_message.token_mint = token_mint.key;
    chat_message.index = chat_state.next_index;
    chat_message.author = author.key;
    chat_message.timestamp = clock;
    chat_message.likes = 0;
    chat_message.deleted = 0;
    chat_message.bump = 0;

    chat_state.next_index = chat_state.next_index + 1;
}

/// Like a message
pub like_message(
    chat_message: ChatMessage @mut,
    liker: account @signer
) {
    require(chat_message.deleted == 0);
    chat_message.likes = chat_message.likes + 1;
}

/// Delete a message (author only, soft delete)
pub delete_message(
    chat_message: ChatMessage @mut,
    author: account @signer
) {
    require(chat_message.author == author.key);
    require(chat_message.deleted == 0);
    chat_message.deleted = 1;
}

/// Get message likes (view)
pub get_message_likes(
    chat_message: ChatMessage
) -> u64 {
    return chat_message.likes;
}
