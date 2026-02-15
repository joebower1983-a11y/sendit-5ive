interface Token2022 @program("TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb") {
    @discriminator(3)
    spl_transfer(from: account @mut, to: account @mut, authority: account @signer, amount: u64);
}
// Send.it Raffle Module — ported from Anchor to 5IVE DSL


// ---------------------------------------------------------------------------
// Accounts
// ---------------------------------------------------------------------------

account Raffle {
    token_launch: pubkey;
    mint: pubkey;
    creator: pubkey;
    ticket_price: u64;
    max_tickets: u64;
    sold_tickets: u64;
    winner_count: u64;
    draw_time: u64;
    randomness_seed: u64;
    token_allocation: u64;
    tokens_per_winner: u64;
    drawn: u8;
    bump: u8;
}

account RaffleTicket {
    raffle: pubkey;
    owner: pubkey;
    ticket_index: u64;
    is_winner: u8;
    claimed: u8;
    bump: u8;
}

// ---------------------------------------------------------------------------
// Instructions
// ---------------------------------------------------------------------------

/// Create a raffle tied to a token launch
pub create_raffle(
    raffle: Raffle @mut @init(payer=creator, space=256) @signer,
    creator: account @mut @signer,
    token_launch: pubkey,
    mint: pubkey,
    ticket_price: u64,
    max_tickets: u64,
    winner_count: u64,
    draw_delay_seconds: u64,
    token_allocation: u64
) {
    require(ticket_price > 0);
    require(max_tickets > 0);
    require(max_tickets <= 10000);
    require(winner_count > 0);
    require(winner_count <= 100);
    require(winner_count <= max_tickets);
    require(token_allocation > 0);

    let clock: u64 = get_clock();

    raffle.token_launch = token_launch;
    raffle.mint = mint;
    raffle.creator = creator.key;
    raffle.ticket_price = ticket_price;
    raffle.max_tickets = max_tickets;
    raffle.sold_tickets = 0;
    raffle.winner_count = winner_count;
    raffle.draw_time = clock + draw_delay_seconds;
    raffle.randomness_seed = 0;
    raffle.token_allocation = token_allocation;
    raffle.tokens_per_winner = token_allocation / winner_count;
    raffle.drawn = 0;
    raffle.bump = 0;
}

/// Buy a raffle ticket
pub buy_ticket(
    raffle: Raffle @mut,
    raffle_ticket: RaffleTicket @mut @init(payer=buyer, space=128) @signer,
    buyer: account @mut @signer
) {
    require(raffle.drawn == 0);
    require(raffle.sold_tickets < raffle.max_tickets);

    let clock: u64 = get_clock();
    require(clock < raffle.draw_time);

    let ticket_index: u64 = raffle.sold_tickets;

    raffle_ticket.raffle = raffle.creator;
    raffle_ticket.owner = buyer.key;
    raffle_ticket.ticket_index = ticket_index;
    raffle_ticket.is_winner = 0;
    raffle_ticket.claimed = 0;
    raffle_ticket.bump = 0;

    raffle.sold_tickets = raffle.sold_tickets + 1;
}

/// Draw winners using clock as randomness source
pub draw_winners(
    raffle: Raffle @mut,
    payer: account @mut @signer
) {
    require(raffle.drawn == 0);
    require(raffle.sold_tickets > 0);

    let clock: u64 = get_clock();
    require(clock >= raffle.draw_time);

    // Use clock as a simple randomness seed
    raffle.randomness_seed = clock;
    raffle.drawn = 1;
}

/// Claim raffle prize — simplified winner check
pub claim_raffle_prize(
    raffle: Raffle,
    raffle_ticket: RaffleTicket @mut,
    claimer: account @mut @signer,
    raffle_token_vault: account @mut,
    claimer_token_account: account @mut,
    vault_authority: account @signer,
    token_program: account
) {
    require(raffle.drawn == 1);
    require(raffle_ticket.owner == claimer.key);
    require(raffle_ticket.claimed == 0);

    // Simplified winner determination:
    // winner if (seed + ticket_index) % sold_tickets < winner_count
    let mixed: u64 = raffle.randomness_seed + raffle_ticket.ticket_index;
    let result: u64 = mixed % raffle.sold_tickets;
    require(result < raffle.winner_count);

    // Transfer tokens from raffle vault to claimer
    Token2022.spl_transfer(raffle_token_vault, claimer_token_account, vault_authority, raffle.tokens_per_winner);

    raffle_ticket.is_winner = 1;
    raffle_ticket.claimed = 1;
}

/// View: get raffle info
pub get_raffle_sold(
    raffle: Raffle
) -> u64 {
    return raffle.sold_tickets;
}
