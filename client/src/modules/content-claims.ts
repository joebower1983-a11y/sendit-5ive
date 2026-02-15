import type { ProgramHandle } from "../base.js";
import type { Address } from "../types.js";

export class ContentClaimsClient {
  constructor(private handle: ProgramHandle) {}

  async registerContent(accounts: { claim: Address; creator: Address },
    args: { tokenMint: Address; feeRedirectBps: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("register_content").accounts({ claim: accounts.claim, creator: accounts.creator })
      .args({ token_mint: args.tokenMint, fee_redirect_bps: args.feeRedirectBps }).rpc();
  }

  async submitClaim(accounts: { claim: Address; verification: Address; claimant: Address },
    args: { tokenMint: Address }) {
    const p = await this.handle.getProgram();
    return p.method("submit_claim").accounts({
      claim: accounts.claim, verification: accounts.verification, claimant: accounts.claimant,
    }).args({ token_mint: args.tokenMint }).rpc();
  }

  async verifyClaim(accounts: { claim: Address; verification: Address; authority: Address }) {
    const p = await this.handle.getProgram();
    return p.method("verify_claim").accounts(accounts).args({}).rpc();
  }

  async rejectClaim(accounts: { claim: Address; verification: Address; authority: Address }) {
    const p = await this.handle.getProgram();
    return p.method("reject_claim").accounts(accounts).args({}).rpc();
  }

  async redirectFees(accounts: { claim: Address; payer: Address }, args: { amount: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("redirect_fees").accounts(accounts).args({ amount: args.amount }).rpc();
  }
}
