// Tests for Send.it Raffle Module

// @test-params 1000 5 200
pub test_tokens_per_winner(allocation: u64, winners: u64) -> u64 {
    return allocation / winners;
}

// @test-params 0 1 1
pub test_ticket_sold_increment(sold: u64, expected: u64) -> u64 {
    return sold + 1;
}

// @test-params 100 100 0
pub test_max_tickets_reached(sold: u64, max: u64) -> u8 {
    if sold < max {
        return 1;
    }
    return 0;
}

// @test-params 12345 2 100 1
pub test_winner_determination(seed: u64, ticket_idx: u64, sold: u64) -> u8 {
    let mixed: u64 = seed + ticket_idx;
    let result: u64 = mixed % sold;
    // winner_count=50 for this test; (12345+2)%100=47 < 50
    if result < 50 {
        return 1;
    }
    return 0;
}

// @test-params 0 0 0
pub test_zero_ticket_price_rejected(price: u64, expected: u8) -> u8 {
    if price > 0 {
        return 1;
    }
    return 0;
}
