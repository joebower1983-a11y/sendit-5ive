import type { ProgramHandle } from "../base.js";
import type { Address } from "../types.js";

export class DailyRewardsClient {
  constructor(private handle: ProgramHandle) {}

  async initializeDailyRewards(accounts: { config: Address; authority: Address },
    args: { pointsPerCheckin: bigint | number; streakMultiplier: bigint | number; pointsPerTradeSol: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("initialize_daily_rewards").accounts(accounts)
      .args({ points_per_checkin: args.pointsPerCheckin, streak_multiplier: args.streakMultiplier, points_per_trade_sol: args.pointsPerTradeSol }).rpc();
  }

  async dailyCheckin(accounts: { config: Address; userRewards: Address; user: Address }) {
    const p = await this.handle.getProgram();
    return p.method("daily_checkin").accounts({ config: accounts.config, user_rewards: accounts.userRewards, user: accounts.user }).args({}).rpc();
  }

  async recordTradeReward(accounts: { config: Address; userRewards: Address; user: Address },
    args: { tradeSolAmount: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("record_trade_reward").accounts({ config: accounts.config, user_rewards: accounts.userRewards, user: accounts.user })
      .args({ trade_sol_amount: args.tradeSolAmount }).rpc();
  }

  async redeemPoints(accounts: { userRewards: Address; user: Address },
    args: { pointsToSpend: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("redeem_points").accounts({ user_rewards: accounts.userRewards, user: accounts.user })
      .args({ points_to_spend: args.pointsToSpend }).rpc();
  }

  async getUserPoints(accounts: { userRewards: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_user_points").accounts({ user_rewards: accounts.userRewards }).args({}).rpc();
  }
}
