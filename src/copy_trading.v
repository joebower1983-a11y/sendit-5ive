// Send.it Copy Trading Module — ported from Anchor to 5IVE DSL
// Simplified: no i64/i128, no bool, no events

account TraderProfile {
    trader: pubkey;
    total_pnl: u64;
    total_trades: u64;
    winning_trades: u64;
    followers_count: u64;
    created_at: u64;
    last_trade_at: u64;
    active: u8;
    bump: u8;
}

account CopyPosition {
    follower: pubkey;
    leader: pubkey;
    max_allocation: u64;
    used_allocation: u64;
    active: u8;
    created_at: u64;
    total_copied_trades: u64;
    copy_pnl: u64;
    bump: u8;
}

pub create_trader_profile(
    profile: TraderProfile @mut @init(payer=trader, space=256) @signer,
    trader: account @mut @signer
) {
    let clock: u64 = get_clock();
    profile.trader = trader.key;
    profile.total_pnl = 0;
    profile.total_trades = 0;
    profile.winning_trades = 0;
    profile.followers_count = 0;
    profile.created_at = clock;
    profile.last_trade_at = 0;
    profile.active = 1;
    profile.bump = 0;
}

pub follow_trader(
    leader_profile: TraderProfile @mut,
    copy_position: CopyPosition @mut @init(payer=follower, space=256) @signer,
    follower: account @mut @signer,
    max_allocation: u64
) {
    require(leader_profile.active == 1);
    require(follower.key != leader_profile.trader);
    require(leader_profile.followers_count < 10000);
    require(max_allocation >= 100000000);

    leader_profile.followers_count = leader_profile.followers_count + 1;

    let clock: u64 = get_clock();
    copy_position.follower = follower.key;
    copy_position.leader = leader_profile.trader;
    copy_position.max_allocation = max_allocation;
    copy_position.used_allocation = 0;
    copy_position.active = 1;
    copy_position.created_at = clock;
    copy_position.total_copied_trades = 0;
    copy_position.copy_pnl = 0;
    copy_position.bump = 0;
}

pub unfollow_trader(
    leader_profile: TraderProfile @mut,
    copy_position: CopyPosition @mut,
    follower: account @signer
) {
    require(copy_position.active == 1);
    require(copy_position.follower == follower.key);

    copy_position.active = 0;

    if leader_profile.followers_count > 0 {
        leader_profile.followers_count = leader_profile.followers_count - 1;
    }
}

pub execute_copy_trade(
    leader_profile: TraderProfile @mut,
    copy_position: CopyPosition @mut,
    executor: account @signer,
    leader_trade_amount: u64,
    leader_total_balance: u64,
    is_buy: u8,
    trade_pnl: u64
) {
    require(leader_profile.active == 1);
    require(copy_position.active == 1);

    let mut follower_amount: u64 = 0;
    if leader_total_balance > 0 {
        follower_amount = (leader_trade_amount * copy_position.max_allocation) / leader_total_balance;
    }

    if is_buy == 1 {
        let remaining: u64 = copy_position.max_allocation - copy_position.used_allocation;
        require(follower_amount <= remaining);
        copy_position.used_allocation = copy_position.used_allocation + follower_amount;
    }
    if is_buy == 0 {
        if copy_position.used_allocation >= follower_amount {
            copy_position.used_allocation = copy_position.used_allocation - follower_amount;
        }
        if copy_position.used_allocation < follower_amount {
            copy_position.used_allocation = 0;
        }
    }

    copy_position.total_copied_trades = copy_position.total_copied_trades + 1;
    copy_position.copy_pnl = copy_position.copy_pnl + trade_pnl;

    leader_profile.total_trades = leader_profile.total_trades + 1;
    leader_profile.total_pnl = leader_profile.total_pnl + trade_pnl;

    if trade_pnl > 0 {
        leader_profile.winning_trades = leader_profile.winning_trades + 1;
    }

    let clock: u64 = get_clock();
    leader_profile.last_trade_at = clock;
}

pub get_win_rate(
    profile: TraderProfile
) -> u64 {
    if profile.total_trades == 0 {
        return 0;
    }
    let rate: u64 = (profile.winning_trades * 10000) / profile.total_trades;
    return rate;
}
