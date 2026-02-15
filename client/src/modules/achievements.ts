import type { ProgramHandle, ExecuteResult } from "../base.js";
import type { Address } from "../types.js";

const str = (a: Address): string => typeof a === "string" ? a : a.toBase58();

export class AchievementsClient {
  constructor(private h: ProgramHandle) {}

  /** initialize_achievement_config(config @init, authority @signer) */
  initializeAchievementConfig(accounts: { config: Address; authority: Address }): Promise<ExecuteResult> {
    return this.h.execute("initialize_achievement_config", [], [str(accounts.config), str(accounts.authority)]);
  }

  /** initialize_user_achievements(user_achievements @init, config, payer @signer, user) */
  initializeUserAchievements(accounts: { userAchievements: Address; config: Address; payer: Address; user: Address }): Promise<ExecuteResult> {
    return this.h.execute("initialize_user_achievements", [], [str(accounts.userAchievements), str(accounts.config), str(accounts.payer), str(accounts.user)]);
  }

  /** record_activity(user_achievements, cranker @signer, trades, volume_lamports, tokens_launched, hold_start) */
  recordActivity(accounts: { userAchievements: Address; cranker: Address },
    args: { trades: bigint | number; volumeLamports: bigint | number; tokensLaunched: bigint | number; holdStart: bigint | number }): Promise<ExecuteResult> {
    return this.h.execute("record_activity",
      [args.trades, args.volumeLamports, args.tokensLaunched, args.holdStart],
      [str(accounts.userAchievements), str(accounts.cranker)]);
  }

  /** check_and_award(user_achievements, cranker @signer) */
  checkAndAward(accounts: { userAchievements: Address; cranker: Address }): Promise<ExecuteResult> {
    return this.h.execute("check_and_award", [], [str(accounts.userAchievements), str(accounts.cranker)]);
  }

  /** get_achievements(user_achievements) */
  getAchievements(accounts: { userAchievements: Address }): Promise<ExecuteResult> {
    return this.h.execute("get_achievements", [], [str(accounts.userAchievements)]);
  }
}
