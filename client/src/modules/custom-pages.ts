import type { ProgramHandle } from "../base.js";
import type { Address } from "../types.js";

export class CustomPagesClient {
  constructor(private handle: ProgramHandle) {}

  async updateCustomPage(accounts: { page: Address; creator: Address; tokenLaunch: Address; mint: Address },
    args: { tier: number; contentHash: Address }) {
    const p = await this.handle.getProgram();
    return p.method("update_custom_page").accounts({
      page: accounts.page, creator: accounts.creator,
      token_launch: accounts.tokenLaunch, mint: accounts.mint,
    }).args({ tier: args.tier, content_hash: args.contentHash }).rpc();
  }

  async resetPage(accounts: { page: Address; creator: Address }) {
    const p = await this.handle.getProgram();
    return p.method("reset_page").accounts(accounts).args({}).rpc();
  }

  async getPageTier(accounts: { page: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_page_tier").accounts(accounts).args({}).rpc();
  }
}
