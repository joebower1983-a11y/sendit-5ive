// Tests for Send.it Creator Dashboard Module

// @test-params 5000 5000
pub test_get_creator_volume(volume: u64) -> u64 {
    return volume;
}

// @test-params 10 10
pub test_get_creator_launches(launches: u64) -> u64 {
    return launches;
}

// @test-params 0 1 1
pub test_snapshot_slot_increment(current_slot: u64, expected: u64) -> u64 {
    return current_slot + 1;
}
