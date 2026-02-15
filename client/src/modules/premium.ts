import type { ProgramHandle } from "../base.js";
import type { Address } from "../types.js";

export class PremiumClient {
  constructor(private handle: ProgramHandle) {}

  async initializePremiumConfig(accounts: { config: Address; authority: Address; treasury: Address },
    args: { promotedPricePerHour: bigint | number; featuredPricePerHour: bigint | number; spotlightPricePerHour: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("initialize_premium_config").accounts(accounts)
      .args({ promoted_price_per_hour: args.promotedPricePerHour, featured_price_per_hour: args.featuredPricePerHour, spotlight_price_per_hour: args.spotlightPricePerHour }).rpc();
  }

  async purchasePremium(accounts: { listing: Address; config: Address; purchaser: Address; tokenMint: Address },
    args: { durationHours: bigint | number; tier: number }) {
    const p = await this.handle.getProgram();
    return p.method("purchase_premium").accounts(accounts)
      .args({ duration_hours: args.durationHours, tier: args.tier }).rpc();
  }

  async checkPremiumStatus(accounts: { listing: Address }) {
    const p = await this.handle.getProgram();
    return p.method("check_premium_status").accounts(accounts).args({}).rpc();
  }

  async getTimeRemaining(accounts: { listing: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_time_remaining").accounts(accounts).args({}).rpc();
  }
}
