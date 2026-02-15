import type { ProgramHandle, ExecuteResult } from "../base.js";
import type { Address } from "../types.js";
const s = (a: Address): string => typeof a === "string" ? a : a.toBase58();

export class CopyTradingClient {
  constructor(private h: ProgramHandle) {}

  createTraderProfile(accounts: { profile: Address; trader: Address }): Promise<ExecuteResult> {
    return this.h.execute("create_trader_profile", [], [s(accounts.profile), s(accounts.trader)]);
  }

  followTrader(accounts: { leaderProfile: Address; copyPosition: Address; follower: Address }, args: { maxAllocation: bigint | number }): Promise<ExecuteResult> {
    return this.h.execute("follow_trader", [args.maxAllocation], [s(accounts.leaderProfile), s(accounts.copyPosition), s(accounts.follower)]);
  }

  unfollowTrader(accounts: { leaderProfile: Address; copyPosition: Address; follower: Address }): Promise<ExecuteResult> {
    return this.h.execute("unfollow_trader", [], [s(accounts.leaderProfile), s(accounts.copyPosition), s(accounts.follower)]);
  }

  executeCopyTrade(accounts: { leaderProfile: Address; copyPosition: Address; executor: Address },
    args: { leaderTradeAmount: bigint | number; leaderTotalBalance: bigint | number; isBuy: number; tradePnl: bigint | number }): Promise<ExecuteResult> {
    return this.h.execute("execute_copy_trade", [args.leaderTradeAmount, args.leaderTotalBalance, args.isBuy, args.tradePnl],
      [s(accounts.leaderProfile), s(accounts.copyPosition), s(accounts.executor)]);
  }

  getWinRate(accounts: { profile: Address }): Promise<ExecuteResult> {
    return this.h.execute("get_win_rate", [], [s(accounts.profile)]);
  }
}
