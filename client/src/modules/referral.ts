import type { ProgramHandle } from "../base.js";
import type { Address } from "../types.js";

export class ReferralClient {
  constructor(private handle: ProgramHandle) {}

  async initializeReferralConfig(accounts: { config: Address; authority: Address; treasury: Address },
    args: { referralFeeBps: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("initialize_referral_config").accounts(accounts)
      .args({ referral_fee_bps: args.referralFeeBps }).rpc();
  }

  async registerReferral(accounts: { referralAccount: Address; user: Address },
    args: { referrerKey: Address }) {
    const p = await this.handle.getProgram();
    return p.method("register_referral").accounts({ referral_account: accounts.referralAccount, user: accounts.user })
      .args({ referrer_key: args.referrerKey }).rpc();
  }

  async creditReferralReward(accounts: { referrerAccount: Address; config: Address; feePayer: Address },
    args: { platformFeeLamports: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("credit_referral_reward").accounts({ referrer_account: accounts.referrerAccount, config: accounts.config, fee_payer: accounts.feePayer })
      .args({ platform_fee_lamports: args.platformFeeLamports }).rpc();
  }

  async claimReferralRewards(accounts: { referralAccount: Address; user: Address }) {
    const p = await this.handle.getProgram();
    return p.method("claim_referral_rewards").accounts({ referral_account: accounts.referralAccount, user: accounts.user }).args({}).rpc();
  }

  async getClaimable(accounts: { referralAccount: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_claimable").accounts({ referral_account: accounts.referralAccount }).args({}).rpc();
  }

  async getTotalReferred(accounts: { referralAccount: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_total_referred").accounts({ referral_account: accounts.referralAccount }).args({}).rpc();
  }
}
