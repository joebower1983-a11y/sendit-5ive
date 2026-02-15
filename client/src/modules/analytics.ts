import type { ProgramHandle, ExecuteResult } from "../base.js";
import type { Address } from "../types.js";
const s = (a: Address): string => typeof a === "string" ? a : a.toBase58();

export class AnalyticsClient {
  constructor(private h: ProgramHandle) {}

  initializeAnalytics(accounts: { analytics: Address; tracker: Address; payer: Address }, args: { tokenMint: Address }): Promise<ExecuteResult> {
    return this.h.execute("initialize_analytics", [s(args.tokenMint)], [s(accounts.analytics), s(accounts.tracker), s(accounts.payer)]);
  }

  updateAnalytics(accounts: { analytics: Address; crank: Address },
    args: { tradeVolume: bigint | number; isBuy: number; trader: Address; currentHolderCount: bigint | number }): Promise<ExecuteResult> {
    return this.h.execute("update_analytics", [args.tradeVolume, args.isBuy, s(args.trader), args.currentHolderCount],
      [s(accounts.analytics), s(accounts.crank)]);
  }

  getTotalVolume(accounts: { analytics: Address }): Promise<ExecuteResult> {
    return this.h.execute("get_total_volume", [], [s(accounts.analytics)]);
  }

  getTotalTrades(accounts: { analytics: Address }): Promise<ExecuteResult> {
    return this.h.execute("get_total_trades", [], [s(accounts.analytics)]);
  }
}
