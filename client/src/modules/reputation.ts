import type { ProgramHandle } from "../base.js";
import type { Address } from "../types.js";

export class ReputationClient {
  constructor(private handle: ProgramHandle) {}

  async initializeReputationConfig(accounts: { config: Address; authority: Address },
    args: { oracleAuthority: Address }) {
    const p = await this.handle.getProgram();
    return p.method("initialize_reputation_config").accounts(accounts)
      .args({ oracle_authority: args.oracleAuthority }).rpc();
  }

  async updateReputationConfig(accounts: { config: Address; authority: Address },
    args: {
      minScoreToLaunch: number; minScorePremiumLaunch: number; strictVestingThreshold: number;
      feeDiscountBronzeBps: bigint | number; feeDiscountSilverBps: bigint | number;
      feeDiscountGoldBps: bigint | number; feeDiscountPlatinumBps: bigint | number;
    }) {
    const p = await this.handle.getProgram();
    return p.method("update_reputation_config").accounts(accounts)
      .args({
        min_score_to_launch: args.minScoreToLaunch, min_score_premium_launch: args.minScorePremiumLaunch,
        strict_vesting_threshold: args.strictVestingThreshold,
        fee_discount_bronze_bps: args.feeDiscountBronzeBps, fee_discount_silver_bps: args.feeDiscountSilverBps,
        fee_discount_gold_bps: args.feeDiscountGoldBps, fee_discount_platinum_bps: args.feeDiscountPlatinumBps,
      }).rpc();
  }

  async updateReputation(accounts: { attestation: Address; config: Address; oracleAuthority: Address },
    args: { wallet: Address; fairscore: number; tier: number }) {
    const p = await this.handle.getProgram();
    return p.method("update_reputation").accounts({ attestation: accounts.attestation, config: accounts.config, oracle_authority: accounts.oracleAuthority })
      .args({ wallet: args.wallet, fairscore: args.fairscore, tier: args.tier }).rpc();
  }

  async checkLaunchEligibility(accounts: { attestation: Address; config: Address }, args: { premium: number }) {
    const p = await this.handle.getProgram();
    return p.method("check_launch_eligibility").accounts(accounts).args({ premium: args.premium }).rpc();
  }

  async getFeeDiscount(accounts: { attestation: Address; config: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_fee_discount").accounts(accounts).args({}).rpc();
  }

  async getVestingMultiplier(accounts: { attestation: Address; config: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_vesting_multiplier").accounts(accounts).args({}).rpc();
  }
}
