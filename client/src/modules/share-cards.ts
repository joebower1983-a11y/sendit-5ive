import type { ProgramHandle } from "../base.js";
import type { Address } from "../types.js";

export class ShareCardsClient {
  constructor(private handle: ProgramHandle) {}

  async updateShareCard(accounts: { shareCard: Address; payer: Address; tokenMint: Address },
    args: { currentPrice: bigint | number; marketCap: bigint | number; volume24h: bigint | number; holderCount: bigint | number; creator: Address; migrationProgressBps: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("update_share_card").accounts({ share_card: accounts.shareCard, payer: accounts.payer, token_mint: accounts.tokenMint })
      .args({ current_price: args.currentPrice, market_cap: args.marketCap, volume_24h: args.volume24h, holder_count: args.holderCount, creator: args.creator, migration_progress_bps: args.migrationProgressBps }).rpc();
  }

  async getShareCardPrice(accounts: { shareCard: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_share_card_price").accounts({ share_card: accounts.shareCard }).args({}).rpc();
  }

  async getShareCardMarketCap(accounts: { shareCard: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_share_card_market_cap").accounts({ share_card: accounts.shareCard }).args({}).rpc();
  }
}
