// Tests for Send.it Price Alerts Module

// @test-params 150 100 1 1
pub test_above_alert_triggered(current: u64, target: u64, direction: u8) -> u8 {
    if direction == 1 {
        if current >= target {
            return 1;
        }
    }
    return 0;
}

// @test-params 50 100 2 1
pub test_below_alert_triggered(current: u64, target: u64, direction: u8) -> u8 {
    if direction == 2 {
        if current <= target {
            return 1;
        }
    }
    return 0;
}

// @test-params 80 100 1 0
pub test_above_alert_not_triggered(current: u64, target: u64, direction: u8) -> u8 {
    if direction == 1 {
        if current >= target {
            return 1;
        }
    }
    return 0;
}

// @test-params 0 0 0
pub test_zero_price_rejected(price: u64, expected: u8) -> u8 {
    if price > 0 {
        return 1;
    }
    return 0;
}

// @test-params 3 0 0
pub test_invalid_direction(direction: u8, expected: u8) -> u8 {
    if direction >= 1 {
        if direction <= 2 {
            return 1;
        }
    }
    return 0;
}
