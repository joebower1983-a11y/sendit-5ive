import type { ProgramHandle } from "../base.js";
import type { Address } from "../types.js";

export class PointsSystemClient {
  constructor(private handle: ProgramHandle) {}

  async initializePointsConfig(accounts: { pointsConfig: Address; authority: Address },
    args: { pointsPerTrade: bigint | number; pointsPerLaunch: bigint | number; pointsPerReferral: bigint | number; pointsPerHoldDay: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("initialize_points_config").accounts({ points_config: accounts.pointsConfig, authority: accounts.authority })
      .args({ points_per_trade: args.pointsPerTrade, points_per_launch: args.pointsPerLaunch, points_per_referral: args.pointsPerReferral, points_per_hold_day: args.pointsPerHoldDay }).rpc();
  }

  async updatePointsConfig(accounts: { pointsConfig: Address; authority: Address },
    args: { pointsPerTrade: bigint | number; pointsPerLaunch: bigint | number; pointsPerReferral: bigint | number; pointsPerHoldDay: bigint | number; actionCooldown: bigint | number; maxDailyPoints: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("update_points_config").accounts({ points_config: accounts.pointsConfig, authority: accounts.authority })
      .args({ points_per_trade: args.pointsPerTrade, points_per_launch: args.pointsPerLaunch, points_per_referral: args.pointsPerReferral, points_per_hold_day: args.pointsPerHoldDay, action_cooldown: args.actionCooldown, max_daily_points: args.maxDailyPoints }).rpc();
  }

  async setPointsPaused(accounts: { pointsConfig: Address; authority: Address }, args: { paused: number }) {
    const p = await this.handle.getProgram();
    return p.method("set_points_paused").accounts({ points_config: accounts.pointsConfig, authority: accounts.authority })
      .args({ paused: args.paused }).rpc();
  }

  async awardPoints(accounts: { pointsConfig: Address; userPoints: Address; authority: Address },
    args: { userKey: Address; action: number; multiplier: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("award_points").accounts({ points_config: accounts.pointsConfig, user_points: accounts.userPoints, authority: accounts.authority })
      .args({ user_key: args.userKey, action: args.action, multiplier: args.multiplier }).rpc();
  }

  async claimReward(accounts: { pointsConfig: Address; userPoints: Address; user: Address },
    args: { pointsCost: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("claim_reward").accounts({ points_config: accounts.pointsConfig, user_points: accounts.userPoints, user: accounts.user })
      .args({ points_cost: args.pointsCost }).rpc();
  }

  async endPointsSeason(accounts: { pointsConfig: Address; authority: Address }) {
    const p = await this.handle.getProgram();
    return p.method("end_points_season").accounts({ points_config: accounts.pointsConfig, authority: accounts.authority }).args({}).rpc();
  }

  async getUserLevel(accounts: { userPoints: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_user_level").accounts({ user_points: accounts.userPoints }).args({}).rpc();
  }

  async getAvailablePoints(accounts: { userPoints: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_available_points").accounts({ user_points: accounts.userPoints }).args({}).rpc();
  }
}
