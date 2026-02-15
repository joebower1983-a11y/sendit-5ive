// Tests for Send.it Live Chat Module

// @test-params 0 1 1
pub test_message_count_increment(count: u64, expected: u64) -> u64 {
    return count + 1;
}

// @test-params 300 1 1
pub test_valid_slowmode(seconds: u64, expected: u8) -> u8 {
    if seconds <= 300 {
        return 1;
    }
    return 0;
}

// @test-params 301 0 0
pub test_invalid_slowmode(seconds: u64, expected: u8) -> u8 {
    if seconds <= 300 {
        return 1;
    }
    return 0;
}

// @test-params 80 60 30 0
pub test_rate_limit_too_soon(clock: u64, last_msg: u64, slowmode: u64) -> u8 {
    let elapsed: u64 = clock - last_msg;
    if elapsed >= slowmode {
        return 1;
    }
    return 0;
}
