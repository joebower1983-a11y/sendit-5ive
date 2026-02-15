import type { ProgramHandle } from "../base.js";
import type { Address } from "../types.js";

export class AnalyticsClient {
  constructor(private handle: ProgramHandle) {}

  async initializeAnalytics(accounts: {
    analytics: Address; tracker: Address; payer: Address;
  }, args: { tokenMint: Address }) {
    const p = await this.handle.getProgram();
    return p.method("initialize_analytics").accounts({
      analytics: accounts.analytics, tracker: accounts.tracker, payer: accounts.payer,
    }).args({ token_mint: args.tokenMint }).rpc();
  }

  async updateAnalytics(accounts: { analytics: Address; crank: Address }, args: {
    tradeVolume: bigint | number; isBuy: number; trader: Address; currentHolderCount: bigint | number;
  }) {
    const p = await this.handle.getProgram();
    return p.method("update_analytics").accounts({
      analytics: accounts.analytics, crank: accounts.crank,
    }).args({
      trade_volume: args.tradeVolume, is_buy: args.isBuy,
      trader: args.trader, current_holder_count: args.currentHolderCount,
    }).rpc();
  }

  async getTotalVolume(accounts: { analytics: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_total_volume").accounts({ analytics: accounts.analytics }).args({}).rpc();
  }

  async getTotalTrades(accounts: { analytics: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_total_trades").accounts({ analytics: accounts.analytics }).args({}).rpc();
  }
}
