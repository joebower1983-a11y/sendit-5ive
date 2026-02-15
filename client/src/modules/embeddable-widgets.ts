import type { ProgramHandle } from "../base.js";
import type { Address } from "../types.js";

export class EmbeddableWidgetsClient {
  constructor(private handle: ProgramHandle) {}

  async createWidgetConfig(accounts: { widgetConfig: Address; creator: Address; tokenMint: Address },
    args: { widgetType: number; theme: number; customColorR: number; customColorG: number; customColorB: number; showPrice: number; showVolume: number }) {
    const p = await this.handle.getProgram();
    return p.method("create_widget_config").accounts({
      widget_config: accounts.widgetConfig, creator: accounts.creator, token_mint: accounts.tokenMint,
    }).args({
      widget_type: args.widgetType, theme: args.theme,
      custom_color_r: args.customColorR, custom_color_g: args.customColorG, custom_color_b: args.customColorB,
      show_price: args.showPrice, show_volume: args.showVolume,
    }).rpc();
  }

  async updateWidgetConfig(accounts: { widgetConfig: Address; creator: Address },
    args: { widgetType: number; theme: number; customColorR: number; customColorG: number; customColorB: number; showPrice: number; showVolume: number; showHolders: number }) {
    const p = await this.handle.getProgram();
    return p.method("update_widget_config").accounts({
      widget_config: accounts.widgetConfig, creator: accounts.creator,
    }).args({
      widget_type: args.widgetType, theme: args.theme,
      custom_color_r: args.customColorR, custom_color_g: args.customColorG, custom_color_b: args.customColorB,
      show_price: args.showPrice, show_volume: args.showVolume, show_holders: args.showHolders,
    }).rpc();
  }

  async recordWidgetView(accounts: { widgetConfig: Address }) {
    const p = await this.handle.getProgram();
    return p.method("record_widget_view").accounts({ widget_config: accounts.widgetConfig }).args({}).rpc();
  }

  async disableWidget(accounts: { widgetConfig: Address; authority: Address }) {
    const p = await this.handle.getProgram();
    return p.method("disable_widget").accounts({ widget_config: accounts.widgetConfig, authority: accounts.authority }).args({}).rpc();
  }

  async getWidgetViews(accounts: { widgetConfig: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_widget_views").accounts({ widget_config: accounts.widgetConfig }).args({}).rpc();
  }
}
