import type { ProgramHandle, ExecuteResult } from "../base.js";
import type { Address } from "../types.js";
const s = (a: Address): string => typeof a === "string" ? a : a.toBase58();

export class ContentClaimsClient {
  constructor(private h: ProgramHandle) {}

  registerContent(accounts: { claim: Address; creator: Address }, args: { tokenMint: Address; feeRedirectBps: bigint | number }): Promise<ExecuteResult> {
    return this.h.execute("register_content", [s(args.tokenMint), args.feeRedirectBps], [s(accounts.claim), s(accounts.creator)]);
  }

  submitClaim(accounts: { claim: Address; verification: Address; claimant: Address }, args: { tokenMint: Address }): Promise<ExecuteResult> {
    return this.h.execute("submit_claim", [s(args.tokenMint)], [s(accounts.claim), s(accounts.verification), s(accounts.claimant)]);
  }

  verifyClaim(accounts: { claim: Address; verification: Address; authority: Address }): Promise<ExecuteResult> {
    return this.h.execute("verify_claim", [], [s(accounts.claim), s(accounts.verification), s(accounts.authority)]);
  }

  rejectClaim(accounts: { claim: Address; verification: Address; authority: Address }): Promise<ExecuteResult> {
    return this.h.execute("reject_claim", [], [s(accounts.claim), s(accounts.verification), s(accounts.authority)]);
  }

  redirectFees(accounts: { claim: Address; payer: Address }, args: { amount: bigint | number }): Promise<ExecuteResult> {
    return this.h.execute("redirect_fees", [args.amount], [s(accounts.claim), s(accounts.payer)]);
  }
}
