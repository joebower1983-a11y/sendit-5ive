import type { ProgramHandle } from "../base.js";
import type { Address } from "../types.js";

export class AirdropsClient {
  constructor(private handle: ProgramHandle) {}

  async createAirdrop(accounts: {
    campaign: Address; creator: Address; tokenMint: Address;
    vault: Address; creatorTokenAccount: Address; tokenProgram: Address;
  }, args: {
    campaignId: bigint | number; totalAmount: bigint | number;
    maxRecipients: bigint | number; snapshotSlot: bigint | number;
  }) {
    const p = await this.handle.getProgram();
    return p.method("create_airdrop").accounts({
      campaign: accounts.campaign, creator: accounts.creator,
      token_mint: accounts.tokenMint, vault: accounts.vault,
      creator_token_account: accounts.creatorTokenAccount,
      token_program: accounts.tokenProgram,
    }).args({
      campaign_id: args.campaignId, total_amount: args.totalAmount,
      max_recipients: args.maxRecipients, snapshot_slot: args.snapshotSlot,
    }).rpc();
  }

  async claimAirdrop(accounts: {
    campaign: Address; claimReceipt: Address; claimant: Address;
    vault: Address; claimantTokenAccount: Address;
    vaultAuthority: Address; tokenProgram: Address;
  }, args: { amount: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("claim_airdrop").accounts({
      campaign: accounts.campaign, claim_receipt: accounts.claimReceipt,
      claimant: accounts.claimant, vault: accounts.vault,
      claimant_token_account: accounts.claimantTokenAccount,
      vault_authority: accounts.vaultAuthority, token_program: accounts.tokenProgram,
    }).args({ amount: args.amount }).rpc();
  }

  async cancelAirdrop(accounts: {
    campaign: Address; creator: Address; vault: Address;
    creatorTokenAccount: Address; vaultAuthority: Address; tokenProgram: Address;
  }, args: { remainingAmount: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("cancel_airdrop").accounts({
      campaign: accounts.campaign, creator: accounts.creator, vault: accounts.vault,
      creator_token_account: accounts.creatorTokenAccount,
      vault_authority: accounts.vaultAuthority, token_program: accounts.tokenProgram,
    }).args({ remaining_amount: args.remainingAmount }).rpc();
  }

  async getClaimedCount(accounts: { campaign: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_claimed_count").accounts({ campaign: accounts.campaign }).args({}).rpc();
  }

  async isCampaignActive(accounts: { campaign: Address }) {
    const p = await this.handle.getProgram();
    return p.method("is_campaign_active").accounts({ campaign: accounts.campaign }).args({}).rpc();
  }
}
