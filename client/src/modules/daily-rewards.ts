import type { ProgramHandle, ExecuteResult } from "../base.js";
import type { Address } from "../types.js";
const s = (a: Address): string => typeof a === "string" ? a : a.toBase58();

export class DailyRewardsClient {
  constructor(private h: ProgramHandle) {}

  initializeDailyRewards(accounts: { config: Address; authority: Address },
    args: { pointsPerCheckin: bigint | number; streakMultiplier: bigint | number; pointsPerTradeSol: bigint | number }): Promise<ExecuteResult> {
    return this.h.execute("initialize_daily_rewards", [args.pointsPerCheckin, args.streakMultiplier, args.pointsPerTradeSol],
      [s(accounts.config), s(accounts.authority)]);
  }

  dailyCheckin(accounts: { config: Address; userRewards: Address; user: Address }): Promise<ExecuteResult> {
    return this.h.execute("daily_checkin", [], [s(accounts.config), s(accounts.userRewards), s(accounts.user)]);
  }

  recordTradeReward(accounts: { config: Address; userRewards: Address; user: Address },
    args: { tradeSolAmount: bigint | number }): Promise<ExecuteResult> {
    return this.h.execute("record_trade_reward", [args.tradeSolAmount],
      [s(accounts.config), s(accounts.userRewards), s(accounts.user)]);
  }

  redeemPoints(accounts: { userRewards: Address; user: Address }, args: { pointsToSpend: bigint | number }): Promise<ExecuteResult> {
    return this.h.execute("redeem_points", [args.pointsToSpend], [s(accounts.userRewards), s(accounts.user)]);
  }

  getUserPoints(accounts: { userRewards: Address }): Promise<ExecuteResult> {
    return this.h.execute("get_user_points", [], [s(accounts.userRewards)]);
  }
}
