// Tests for Send.it Voting Module

// @test-params 0 100 100
pub test_vote_accumulation(current: u64, weight: u64) -> u64 {
    return current + weight;
}

// @test-params 1000 500 2
pub test_quorum_reached_passed(total_votes: u64, quorum: u64) -> u8 {
    if total_votes >= quorum {
        return 2;
    }
    return 3;
}

// @test-params 100 500 3
pub test_quorum_not_reached_rejected(total_votes: u64, quorum: u64) -> u8 {
    if total_votes >= quorum {
        return 2;
    }
    return 3;
}

// @test-params 2 4 1
pub test_valid_option_count(count: u8, max: u8) -> u8 {
    if count >= 2 {
        if count <= 4 {
            return 1;
        }
    }
    return 0;
}

// @test-params 0 0 0
pub test_zero_weight_rejected(weight: u64, expected: u8) -> u8 {
    if weight > 0 {
        return 1;
    }
    return 0;
}
