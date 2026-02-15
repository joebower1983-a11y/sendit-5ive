import type { ProgramHandle } from "../base.js";
import type { Address } from "../types.js";

export class SeasonsClient {
  constructor(private handle: ProgramHandle) {}

  async startSeason(accounts: { season: Address; authority: Address },
    args: { seasonNumber: bigint | number; startTime: bigint | number; endTime: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("start_season").accounts(accounts)
      .args({ season_number: args.seasonNumber, start_time: args.startTime, end_time: args.endTime }).rpc();
  }

  async addSeasonReward(accounts: { season: Address; seasonReward: Address; authority: Address },
    args: { level: bigint | number; minXp: bigint | number; rewardType: number; rewardAmount: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("add_season_reward").accounts({ season: accounts.season, season_reward: accounts.seasonReward, authority: accounts.authority })
      .args({ level: args.level, min_xp: args.minXp, reward_type: args.rewardType, reward_amount: args.rewardAmount }).rpc();
  }

  async joinSeason(accounts: { season: Address; seasonPass: Address; user: Address }) {
    const p = await this.handle.getProgram();
    return p.method("join_season").accounts({ season: accounts.season, season_pass: accounts.seasonPass, user: accounts.user }).args({}).rpc();
  }

  async recordSeasonXp(accounts: { season: Address; seasonPass: Address; user: Address },
    args: { xpAmount: bigint | number; source: number; tradeVolumeLamports: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("record_season_xp").accounts({ season: accounts.season, season_pass: accounts.seasonPass, user: accounts.user })
      .args({ xp_amount: args.xpAmount, source: args.source, trade_volume_lamports: args.tradeVolumeLamports }).rpc();
  }

  async claimSeasonReward(accounts: { season: Address; seasonPass: Address; seasonReward: Address; user: Address }) {
    const p = await this.handle.getProgram();
    return p.method("claim_season_reward").accounts({ season: accounts.season, season_pass: accounts.seasonPass, season_reward: accounts.seasonReward, user: accounts.user }).args({}).rpc();
  }

  async endSeason(accounts: { season: Address; authority: Address }) {
    const p = await this.handle.getProgram();
    return p.method("end_season").accounts(accounts).args({}).rpc();
  }

  async fundSeason(accounts: { season: Address; funder: Address }, args: { lamports: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("fund_season").accounts(accounts).args({ lamports: args.lamports }).rpc();
  }

  async getSeasonInfo(accounts: { season: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_season_info").accounts(accounts).args({}).rpc();
  }
}
