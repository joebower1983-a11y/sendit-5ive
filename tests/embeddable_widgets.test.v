// Tests for Send.it Embeddable Widgets Module

// @test-params 0 1 1
pub test_view_increment(views: u64, expected: u64) -> u64 {
    return views + 1;
}

// @test-params 3 1 1
pub test_valid_widget_type(wtype: u8, expected: u8) -> u8 {
    if wtype <= 3 {
        return 1;
    }
    return 0;
}

// @test-params 4 0 0
pub test_invalid_widget_type(wtype: u8, expected: u8) -> u8 {
    if wtype <= 3 {
        return 1;
    }
    return 0;
}

// @test-params 0 0 0
pub test_disabled_widget_no_view(enabled: u8, expected: u8) -> u8 {
    if enabled == 1 {
        return 1;
    }
    return 0;
}
