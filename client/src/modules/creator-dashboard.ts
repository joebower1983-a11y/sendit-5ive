import type { ProgramHandle, ExecuteResult } from "../base.js";
import type { Address } from "../types.js";
const s = (a: Address): string => typeof a === "string" ? a : a.toBase58();

export class CreatorDashboardClient {
  constructor(private h: ProgramHandle) {}

  updateCreatorAnalytics(accounts: { creatorAnalytics: Address; payer: Address; creator: Address },
    args: { totalLaunches: bigint | number; totalVolumeGenerated: bigint | number; totalFeesEarned: bigint | number; totalHoldersAcrossTokens: bigint | number; bestPerformingToken: Address; avgGraduationTime: bigint | number }): Promise<ExecuteResult> {
    return this.h.execute("update_creator_analytics",
      [args.totalLaunches, args.totalVolumeGenerated, args.totalFeesEarned, args.totalHoldersAcrossTokens, s(args.bestPerformingToken), args.avgGraduationTime],
      [s(accounts.creatorAnalytics), s(accounts.payer), s(accounts.creator)]);
  }

  updateTokenSnapshot(accounts: { snapshot: Address; payer: Address; tokenMint: Address },
    args: { hourlyVolumeEntry: bigint | number; holderGrowthEntry: bigint | number }): Promise<ExecuteResult> {
    return this.h.execute("update_token_snapshot", [args.hourlyVolumeEntry, args.holderGrowthEntry],
      [s(accounts.snapshot), s(accounts.payer), s(accounts.tokenMint)]);
  }

  getCreatorVolume(accounts: { creatorAnalytics: Address }): Promise<ExecuteResult> {
    return this.h.execute("get_creator_volume", [], [s(accounts.creatorAnalytics)]);
  }

  getCreatorLaunches(accounts: { creatorAnalytics: Address }): Promise<ExecuteResult> {
    return this.h.execute("get_creator_launches", [], [s(accounts.creatorAnalytics)]);
  }
}
