import type { ProgramHandle } from "../base.js";
import type { Address } from "../types.js";

export class CopyTradingClient {
  constructor(private handle: ProgramHandle) {}

  async createTraderProfile(accounts: { profile: Address; trader: Address }) {
    const p = await this.handle.getProgram();
    return p.method("create_trader_profile").accounts(accounts).args({}).rpc();
  }

  async followTrader(accounts: { leaderProfile: Address; copyPosition: Address; follower: Address },
    args: { maxAllocation: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("follow_trader").accounts({
      leader_profile: accounts.leaderProfile, copy_position: accounts.copyPosition,
      follower: accounts.follower,
    }).args({ max_allocation: args.maxAllocation }).rpc();
  }

  async unfollowTrader(accounts: { leaderProfile: Address; copyPosition: Address; follower: Address }) {
    const p = await this.handle.getProgram();
    return p.method("unfollow_trader").accounts({
      leader_profile: accounts.leaderProfile, copy_position: accounts.copyPosition,
      follower: accounts.follower,
    }).args({}).rpc();
  }

  async executeCopyTrade(accounts: { leaderProfile: Address; copyPosition: Address; executor: Address },
    args: { leaderTradeAmount: bigint | number; leaderTotalBalance: bigint | number; isBuy: number; tradePnl: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("execute_copy_trade").accounts({
      leader_profile: accounts.leaderProfile, copy_position: accounts.copyPosition,
      executor: accounts.executor,
    }).args({
      leader_trade_amount: args.leaderTradeAmount, leader_total_balance: args.leaderTotalBalance,
      is_buy: args.isBuy, trade_pnl: args.tradePnl,
    }).rpc();
  }

  async getWinRate(accounts: { profile: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_win_rate").accounts(accounts).args({}).rpc();
  }
}
