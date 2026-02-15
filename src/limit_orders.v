// Send.it Limit Orders Module — ported from Anchor to 5IVE DSL
// Simplified: no u128, no enums, no SPL token CPI escrow

account LimitOrder {
    owner: pubkey;
    token: pubkey;
    side: u8;
    price_target: u64;
    amount: u64;
    status: u8;
    created_at: u64;
    order_index: u64;
    bump: u8;
}

account UserOrderCounter {
    active_count: u64;
    next_index: u64;
    bump: u8;
}

pub place_limit_order(
    order: LimitOrder @mut @init(payer=owner, space=256) @signer,
    counter: UserOrderCounter @mut,
    owner: account @mut @signer,
    token_mint: pubkey,
    side: u8,
    price_target: u64,
    amount: u64
) {
    require(amount > 0);
    require(price_target > 0);
    require(side >= 1);
    require(side <= 2);
    require(counter.active_count < 50);

    let clock: u64 = get_clock();

    order.owner = owner.key;
    order.token = token_mint;
    order.side = side;
    order.price_target = price_target;
    order.amount = amount;
    order.status = 1;
    order.created_at = clock;
    order.order_index = counter.next_index;
    order.bump = 0;

    counter.active_count = counter.active_count + 1;
    counter.next_index = counter.next_index + 1;
}

pub cancel_limit_order(
    order: LimitOrder @mut,
    counter: UserOrderCounter @mut,
    owner: account @signer
) {
    require(order.status == 1);
    require(order.owner == owner.key);

    order.status = 3;

    if counter.active_count > 0 {
        counter.active_count = counter.active_count - 1;
    }
}

pub fill_limit_order(
    order: LimitOrder @mut,
    counter: UserOrderCounter @mut,
    cranker: account @signer,
    current_price: u64
) {
    require(order.status == 1);

    // side 1 = buy: fill when price drops to target
    // side 2 = sell: fill when price rises to target
    if order.side == 1 {
        require(current_price <= order.price_target);
    }
    if order.side == 2 {
        require(current_price >= order.price_target);
    }

    order.status = 2;

    if counter.active_count > 0 {
        counter.active_count = counter.active_count - 1;
    }
}

pub init_order_counter(
    counter: UserOrderCounter @mut @init(payer=owner, space=128) @signer,
    owner: account @mut @signer
) {
    counter.active_count = 0;
    counter.next_index = 0;
    counter.bump = 0;
}

pub get_order_status(
    order: LimitOrder
) -> u8 {
    return order.status;
}
