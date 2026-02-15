import type { ProgramHandle, ExecuteResult } from "../base.js";
import type { Address } from "../types.js";
const s = (a: Address): string => typeof a === "string" ? a : a.toBase58();

export class CustomPagesClient {
  constructor(private h: ProgramHandle) {}

  updateCustomPage(accounts: { page: Address; creator: Address; tokenLaunch: Address; mint: Address },
    args: { tier: number; contentHash: Address }): Promise<ExecuteResult> {
    return this.h.execute("update_custom_page", [args.tier, s(args.contentHash)],
      [s(accounts.page), s(accounts.creator), s(accounts.tokenLaunch), s(accounts.mint)]);
  }

  resetPage(accounts: { page: Address; creator: Address }): Promise<ExecuteResult> {
    return this.h.execute("reset_page", [], [s(accounts.page), s(accounts.creator)]);
  }

  getPageTier(accounts: { page: Address }): Promise<ExecuteResult> {
    return this.h.execute("get_page_tier", [], [s(accounts.page)]);
  }
}
