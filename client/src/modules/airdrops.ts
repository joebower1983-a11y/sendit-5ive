import type { ProgramHandle, ExecuteResult } from "../base.js";
import type { Address } from "../types.js";
const s = (a: Address): string => typeof a === "string" ? a : a.toBase58();

export class AirdropsClient {
  constructor(private h: ProgramHandle) {}

  createAirdrop(accounts: { campaign: Address; creator: Address; tokenMint: Address; vault: Address; creatorTokenAccount: Address; tokenProgram: Address },
    args: { campaignId: bigint | number; totalAmount: bigint | number; maxRecipients: bigint | number; snapshotSlot: bigint | number }): Promise<ExecuteResult> {
    return this.h.execute("create_airdrop",
      [args.campaignId, args.totalAmount, args.maxRecipients, args.snapshotSlot],
      [s(accounts.campaign), s(accounts.creator), s(accounts.tokenMint), s(accounts.vault), s(accounts.creatorTokenAccount), s(accounts.tokenProgram)]);
  }

  claimAirdrop(accounts: { campaign: Address; claimReceipt: Address; claimant: Address; vault: Address; claimantTokenAccount: Address; vaultAuthority: Address; tokenProgram: Address },
    args: { amount: bigint | number }): Promise<ExecuteResult> {
    return this.h.execute("claim_airdrop", [args.amount],
      [s(accounts.campaign), s(accounts.claimReceipt), s(accounts.claimant), s(accounts.vault), s(accounts.claimantTokenAccount), s(accounts.vaultAuthority), s(accounts.tokenProgram)]);
  }

  cancelAirdrop(accounts: { campaign: Address; creator: Address; vault: Address; creatorTokenAccount: Address; vaultAuthority: Address; tokenProgram: Address },
    args: { remainingAmount: bigint | number }): Promise<ExecuteResult> {
    return this.h.execute("cancel_airdrop", [args.remainingAmount],
      [s(accounts.campaign), s(accounts.creator), s(accounts.vault), s(accounts.creatorTokenAccount), s(accounts.vaultAuthority), s(accounts.tokenProgram)]);
  }

  getClaimedCount(accounts: { campaign: Address }): Promise<ExecuteResult> {
    return this.h.execute("get_claimed_count", [], [s(accounts.campaign)]);
  }

  isCampaignActive(accounts: { campaign: Address }): Promise<ExecuteResult> {
    return this.h.execute("is_campaign_active", [], [s(accounts.campaign)]);
  }
}
