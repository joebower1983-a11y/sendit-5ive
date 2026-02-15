import type { ProgramHandle } from "../base.js";
import type { Address } from "../types.js";

export class CreatorDashboardClient {
  constructor(private handle: ProgramHandle) {}

  async updateCreatorAnalytics(accounts: { creatorAnalytics: Address; payer: Address; creator: Address },
    args: {
      totalLaunches: bigint | number; totalVolumeGenerated: bigint | number;
      totalFeesEarned: bigint | number; totalHoldersAcrossTokens: bigint | number;
      bestPerformingToken: Address; avgGraduationTime: bigint | number;
    }) {
    const p = await this.handle.getProgram();
    return p.method("update_creator_analytics").accounts({
      creator_analytics: accounts.creatorAnalytics, payer: accounts.payer, creator: accounts.creator,
    }).args({
      total_launches: args.totalLaunches, total_volume_generated: args.totalVolumeGenerated,
      total_fees_earned: args.totalFeesEarned, total_holders_across_tokens: args.totalHoldersAcrossTokens,
      best_performing_token: args.bestPerformingToken, avg_graduation_time: args.avgGraduationTime,
    }).rpc();
  }

  async updateTokenSnapshot(accounts: { snapshot: Address; payer: Address; tokenMint: Address },
    args: { hourlyVolumeEntry: bigint | number; holderGrowthEntry: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("update_token_snapshot").accounts({
      snapshot: accounts.snapshot, payer: accounts.payer, token_mint: accounts.tokenMint,
    }).args({ hourly_volume_entry: args.hourlyVolumeEntry, holder_growth_entry: args.holderGrowthEntry }).rpc();
  }

  async getCreatorVolume(accounts: { creatorAnalytics: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_creator_volume").accounts({ creator_analytics: accounts.creatorAnalytics }).args({}).rpc();
  }

  async getCreatorLaunches(accounts: { creatorAnalytics: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_creator_launches").accounts({ creator_analytics: accounts.creatorAnalytics }).args({}).rpc();
  }
}
