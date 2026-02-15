// Send.it Price Alerts Module — ported from Anchor to 5IVE DSL
// direction: 1 = Above, 2 = Below
// active: 1 = active, 0 = inactive

// ---------------------------------------------------------------------------
// Accounts
// ---------------------------------------------------------------------------

account AlertSubscription {
    owner: pubkey;
    token_mint: pubkey;
    target_price: u64;
    direction: u8;
    active: u8;
    created_at: u64;
    triggered_at: u64;
    alert_id: u64;
    bump: u8;
}

// ---------------------------------------------------------------------------
// Instructions
// ---------------------------------------------------------------------------

/// Create a new price alert
pub create_alert(
    alert: AlertSubscription @mut @init(payer=owner, space=256) @signer,
    owner: account @mut @signer,
    token_mint: pubkey,
    alert_id: u64,
    target_price: u64,
    direction: u8
) {
    require(target_price > 0);
    require(direction >= 1);
    require(direction <= 2);

    let clock: u64 = get_clock();

    alert.owner = owner.key;
    alert.token_mint = token_mint;
    alert.target_price = target_price;
    alert.direction = direction;
    alert.active = 1;
    alert.created_at = clock;
    alert.triggered_at = 0;
    alert.alert_id = alert_id;
    alert.bump = 0;
}

/// Cancel an alert (owner only)
pub cancel_alert(
    alert: AlertSubscription @mut,
    owner: account @signer
) {
    require(alert.owner == owner.key);
    require(alert.active == 1);

    alert.active = 0;
}

/// Permissionless crank: check if alert condition is met
pub check_alert(
    alert: AlertSubscription @mut,
    crank: account @signer,
    current_price: u64
) {
    require(alert.active == 1);

    let clock: u64 = get_clock();

    // Direction 1 = Above: triggered when current_price >= target_price
    // Direction 2 = Below: triggered when current_price <= target_price
    if alert.direction == 1 {
        require(current_price >= alert.target_price);
    }
    if alert.direction == 2 {
        require(current_price <= alert.target_price);
    }

    alert.active = 0;
    alert.triggered_at = clock;
}

/// Get alert target price (view)
pub get_alert_target(
    alert: AlertSubscription
) -> u64 {
    return alert.target_price;
}
