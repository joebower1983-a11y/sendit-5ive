// Tests for Send.it PYUSD Vault Module

// --- Savings Vault ---

// @test-params 1000000 300 1000000000000 300
pub test_yield_accumulation(deposited: u64, rate_bps: u64, elapsed: u64) -> u64 {
    // yield = elapsed * rate_bps / deposited
    return (elapsed * rate_bps) / deposited;
}

// @test-params 500000 200 1000000000000 400
pub test_pending_yield(deposited: u64, diff: u64, precision: u64) -> u64 {
    return (deposited * diff) / precision;
}

// --- On-Ramp Tracking ---

// @test-params 1000000 500000 1500000
pub test_onramp_accumulation(existing: u64, new_amount: u64) -> u64 {
    return existing + new_amount;
}

// @test-params 5 1 6
pub test_onramp_tx_count(existing: u64, increment: u64) -> u64 {
    return existing + increment;
}

// --- Stablecoin Swap (1:1 minus fee) ---

// @test-params 1000000 5 500
pub test_stable_swap_fee(amount_in: u64, fee_bps: u64) -> u64 {
    return (amount_in * fee_bps) / 10000;
}

// @test-params 1000000 5 999500
pub test_stable_swap_output(amount_in: u64, fee_bps: u64) -> u64 {
    let fee: u64 = (amount_in * fee_bps) / 10000;
    return amount_in - fee;
}

// @test-params 1000000 1 999900
pub test_stable_swap_1bps(amount_in: u64, fee_bps: u64) -> u64 {
    let fee: u64 = (amount_in * fee_bps) / 10000;
    return amount_in - fee;
}

// --- Incentive Points ---

// @test-params 100 50 150
pub test_points_accumulation(existing: u64, bonus: u64) -> u64 {
    return existing + bonus;
}

// --- Lending LTV Helpers ---

// @test-params 1 9000
pub test_stablecoin_ltv(is_stablecoin: u8) -> u64 {
    if is_stablecoin == 1 {
        return 9000;
    }
    return 7000;
}

// @test-params 0 7000
pub test_volatile_ltv(is_stablecoin: u8) -> u64 {
    if is_stablecoin == 1 {
        return 9000;
    }
    return 7000;
}

// --- Stable Pairs PYUSD helpers ---

// @test-params 1000000 1000000 500000 5 499998
pub test_stable_stable_swap_output(reserve_in: u64, reserve_out: u64, amount_in: u64, fee_bps: u64) -> u64 {
    let fee: u64 = (amount_in * fee_bps) / 10000;
    let net: u64 = amount_in - fee;
    let numerator: u64 = reserve_out * net;
    let denominator: u64 = reserve_in + net;
    return numerator / denominator;
}
