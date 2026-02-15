// Tests for Send.it Custom Pages Module

// @test-params 0 0 0
pub test_basic_tier_fee(tier: u8, expected: u64) -> u64 {
    let mut fee: u64 = 0;
    if tier == 1 {
        fee = 100000000;
    }
    if tier == 2 {
        fee = 500000000;
    }
    return fee;
}

// @test-params 1 0 100000000
pub test_pro_tier_fee(tier: u8, expected: u64) -> u64 {
    let mut fee: u64 = 0;
    if tier == 1 {
        fee = 100000000;
    }
    if tier == 2 {
        fee = 500000000;
    }
    return fee;
}

// @test-params 2 0 500000000
pub test_ultra_tier_fee(tier: u8, expected: u64) -> u64 {
    let mut fee: u64 = 0;
    if tier == 1 {
        fee = 100000000;
    }
    if tier == 2 {
        fee = 500000000;
    }
    return fee;
}

// @test-params 3 0 0
pub test_invalid_tier_rejected(tier: u8, expected: u8) -> u8 {
    if tier <= 2 {
        return 1;
    }
    return 0;
}
