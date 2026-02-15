// Tests for Send.it Prediction Market Module

// @test-params 100 200 300
pub test_pool_update_side_a(pool_a: u64, amount: u64) -> u64 {
    return pool_a + amount;
}

// @test-params 50 150 200
pub test_pool_update_side_b(pool_b: u64, amount: u64) -> u64 {
    return pool_b + amount;
}

// @test-params 1000 500 1500
pub test_total_pool(pool_a: u64, pool_b: u64) -> u64 {
    return pool_a + pool_b;
}

// @test-params 100 1500 500 300
pub test_claim_payout(user_amount: u64, total_pool: u64, winning_pool: u64) -> u64 {
    let payout: u64 = (user_amount * total_pool) / winning_pool;
    return payout;
}

// @test-params 1 0 1
pub test_resolve_a_graduated(grad_a: u8, grad_b: u8) -> u8 {
    let mut winner: u8 = 1;
    if grad_a == 0 {
        if grad_b == 1 {
            winner = 2;
        }
    }
    return winner;
}

// @test-params 0 1 2
pub test_resolve_b_graduated(grad_a: u8, grad_b: u8) -> u8 {
    let mut winner: u8 = 1;
    if grad_a == 0 {
        if grad_b == 1 {
            winner = 2;
        }
    }
    return winner;
}

// @test-params 1 1 1
pub test_resolve_both_graduated(grad_a: u8, grad_b: u8) -> u8 {
    let mut winner: u8 = 1;
    if grad_a == 0 {
        if grad_b == 1 {
            winner = 2;
        }
    }
    return winner;
}

// @test-params 0 0 1
pub test_resolve_neither_graduated(grad_a: u8, grad_b: u8) -> u8 {
    let mut winner: u8 = 1;
    if grad_a == 0 {
        if grad_b == 1 {
            winner = 2;
        }
    }
    return winner;
}

// @test-params 1 1 1
pub test_side_validation_valid(side: u8) -> u8 {
    if side >= 1 {
        if side <= 2 {
            return 1;
        }
    }
    return 0;
}

// @test-params 0 0 0
pub test_side_validation_zero(side: u8) -> u8 {
    if side >= 1 {
        if side <= 2 {
            return 1;
        }
    }
    return 0;
}

// @test-params 3 0 0
pub test_side_validation_three(side: u8) -> u8 {
    if side >= 1 {
        if side <= 2 {
            return 1;
        }
    }
    return 0;
}

// @test-params 0 1 1
pub test_already_claimed(claimed: u8) -> u8 {
    if claimed == 0 {
        return 1;
    }
    return 0;
}
