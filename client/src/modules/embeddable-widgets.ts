import type { ProgramHandle, ExecuteResult } from "../base.js";
import type { Address } from "../types.js";
const s = (a: Address): string => typeof a === "string" ? a : a.toBase58();

export class EmbeddableWidgetsClient {
  constructor(private h: ProgramHandle) {}

  createWidgetConfig(accounts: { widgetConfig: Address; creator: Address; tokenMint: Address },
    args: { widgetType: number; theme: number; customColorR: number; customColorG: number; customColorB: number; showPrice: number; showVolume: number }): Promise<ExecuteResult> {
    return this.h.execute("create_widget_config",
      [args.widgetType, args.theme, args.customColorR, args.customColorG, args.customColorB, args.showPrice, args.showVolume],
      [s(accounts.widgetConfig), s(accounts.creator), s(accounts.tokenMint)]);
  }

  updateWidgetConfig(accounts: { widgetConfig: Address; creator: Address },
    args: { widgetType: number; theme: number; customColorR: number; customColorG: number; customColorB: number; showPrice: number; showVolume: number; showHolders: number }): Promise<ExecuteResult> {
    return this.h.execute("update_widget_config",
      [args.widgetType, args.theme, args.customColorR, args.customColorG, args.customColorB, args.showPrice, args.showVolume, args.showHolders],
      [s(accounts.widgetConfig), s(accounts.creator)]);
  }

  recordWidgetView(accounts: { widgetConfig: Address }): Promise<ExecuteResult> {
    return this.h.execute("record_widget_view", [], [s(accounts.widgetConfig)]);
  }

  disableWidget(accounts: { widgetConfig: Address; authority: Address }): Promise<ExecuteResult> {
    return this.h.execute("disable_widget", [], [s(accounts.widgetConfig), s(accounts.authority)]);
  }

  getWidgetViews(accounts: { widgetConfig: Address }): Promise<ExecuteResult> {
    return this.h.execute("get_widget_views", [], [s(accounts.widgetConfig)]);
  }
}
