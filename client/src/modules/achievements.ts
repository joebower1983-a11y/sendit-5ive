import type { PublicKey } from "@solana/web3.js";
import type { ProgramHandle } from "../base.js";
import type { Address } from "../types.js";

export class AchievementsClient {
  constructor(private handle: ProgramHandle) {}

  async initializeAchievementConfig(accounts: {
    config: Address;
    authority: Address;
  }) {
    const p = await this.handle.getProgram();
    return p.method("initialize_achievement_config").accounts(accounts).args({}).rpc();
  }

  async initializeUserAchievements(accounts: {
    userAchievements: Address;
    config: Address;
    payer: Address;
    user: Address;
  }) {
    const p = await this.handle.getProgram();
    return p.method("initialize_user_achievements")
      .accounts({ user_achievements: accounts.userAchievements, config: accounts.config, payer: accounts.payer, user: accounts.user })
      .args({}).rpc();
  }

  async recordActivity(accounts: {
    userAchievements: Address;
    cranker: Address;
  }, args: {
    trades: bigint | number;
    volumeLamports: bigint | number;
    tokensLaunched: bigint | number;
    holdStart: bigint | number;
  }) {
    const p = await this.handle.getProgram();
    return p.method("record_activity")
      .accounts({ user_achievements: accounts.userAchievements, cranker: accounts.cranker })
      .args({ trades: args.trades, volume_lamports: args.volumeLamports, tokens_launched: args.tokensLaunched, hold_start: args.holdStart })
      .rpc();
  }

  async checkAndAward(accounts: { userAchievements: Address; cranker: Address }) {
    const p = await this.handle.getProgram();
    return p.method("check_and_award")
      .accounts({ user_achievements: accounts.userAchievements, cranker: accounts.cranker })
      .args({}).rpc();
  }

  async getAchievements(accounts: { userAchievements: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_achievements")
      .accounts({ user_achievements: accounts.userAchievements })
      .args({}).rpc();
  }
}
