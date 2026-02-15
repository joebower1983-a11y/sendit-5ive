// Send.it Embeddable Widgets Module — ported from Anchor to 5IVE DSL

// ---------------------------------------------------------------------------
// Accounts
// ---------------------------------------------------------------------------

account WidgetConfig {
    token_mint: pubkey;
    creator: pubkey;
    widget_type: u8;
    theme: u8;
    custom_color_r: u8;
    custom_color_g: u8;
    custom_color_b: u8;
    show_price: u8;
    show_volume: u8;
    show_holders: u8;
    show_market_cap: u8;
    enabled: u8;
    views: u64;
    bump: u8;
}

// ---------------------------------------------------------------------------
// Instructions
// ---------------------------------------------------------------------------

/// Create a widget config for a token
/// widget_type: 0=PriceBadge, 1=TradingCard, 2=LeaderboardBadge, 3=MiniChart
/// theme: 0=Dark, 1=Light, 2=Custom
pub create_widget_config(
    widget_config: WidgetConfig @mut @init(payer=creator, space=256) @signer,
    creator: account @mut @signer,
    token_mint: account,
    widget_type: u8,
    theme: u8,
    custom_color_r: u8,
    custom_color_g: u8,
    custom_color_b: u8,
    show_price: u8,
    show_volume: u8,
    show_holders: u8,
    show_market_cap: u8
) {
    require(widget_type <= 3);
    require(theme <= 2);

    widget_config.token_mint = token_mint.key;
    widget_config.creator = creator.key;
    widget_config.widget_type = widget_type;
    widget_config.theme = theme;
    widget_config.custom_color_r = custom_color_r;
    widget_config.custom_color_g = custom_color_g;
    widget_config.custom_color_b = custom_color_b;
    widget_config.show_price = show_price;
    widget_config.show_volume = show_volume;
    widget_config.show_holders = show_holders;
    widget_config.show_market_cap = show_market_cap;
    widget_config.enabled = 1;
    widget_config.views = 0;
    widget_config.bump = 0;
}

/// Update widget config (creator only)
pub update_widget_config(
    widget_config: WidgetConfig @mut,
    creator: account @signer,
    widget_type: u8,
    theme: u8,
    custom_color_r: u8,
    custom_color_g: u8,
    custom_color_b: u8,
    show_price: u8,
    show_volume: u8,
    show_holders: u8,
    show_market_cap: u8
) {
    require(creator.key == widget_config.creator);
    require(widget_type <= 3);
    require(theme <= 2);

    widget_config.widget_type = widget_type;
    widget_config.theme = theme;
    widget_config.custom_color_r = custom_color_r;
    widget_config.custom_color_g = custom_color_g;
    widget_config.custom_color_b = custom_color_b;
    widget_config.show_price = show_price;
    widget_config.show_volume = show_volume;
    widget_config.show_holders = show_holders;
    widget_config.show_market_cap = show_market_cap;
}

/// Record a widget view
pub record_widget_view(
    widget_config: WidgetConfig @mut
) {
    require(widget_config.enabled == 1);
    widget_config.views = widget_config.views + 1;
}

/// Disable a widget (creator only)
pub disable_widget(
    widget_config: WidgetConfig @mut,
    authority: account @signer
) {
    require(authority.key == widget_config.creator);
    widget_config.enabled = 0;
}

/// Get widget views (view)
pub get_widget_views(
    widget_config: WidgetConfig
) -> u64 {
    return widget_config.views;
}
