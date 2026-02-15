import type { ProgramHandle } from "../base.js";
import type { Address } from "../types.js";

export class StablePairsClient {
  constructor(private handle: ProgramHandle) {}

  async createStablePair(accounts: { stablePair: Address; creator: Address },
    args: { tokenMint: Address; stableMint: Address; feeBps: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("create_stable_pair").accounts({ stable_pair: accounts.stablePair, creator: accounts.creator })
      .args({ token_mint: args.tokenMint, stable_mint: args.stableMint, fee_bps: args.feeBps }).rpc();
  }

  async swapTokenForStable(accounts: {
    stablePair: Address; user: Address; userTokenAccount: Address; userStableAccount: Address;
    tokenVault: Address; stableVault: Address; vaultAuthority: Address; tokenProgram: Address;
  }, args: { amountIn: bigint | number; minAmountOut: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("swap_token_for_stable").accounts({
      stable_pair: accounts.stablePair, user: accounts.user,
      user_token_account: accounts.userTokenAccount, user_stable_account: accounts.userStableAccount,
      token_vault: accounts.tokenVault, stable_vault: accounts.stableVault,
      vault_authority: accounts.vaultAuthority, token_program: accounts.tokenProgram,
    }).args({ amount_in: args.amountIn, min_amount_out: args.minAmountOut }).rpc();
  }

  async swapStableForToken(accounts: {
    stablePair: Address; user: Address; userStableAccount: Address; userTokenAccount: Address;
    stableVault: Address; tokenVault: Address; vaultAuthority: Address; tokenProgram: Address;
  }, args: { amountIn: bigint | number; minAmountOut: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("swap_stable_for_token").accounts({
      stable_pair: accounts.stablePair, user: accounts.user,
      user_stable_account: accounts.userStableAccount, user_token_account: accounts.userTokenAccount,
      stable_vault: accounts.stableVault, token_vault: accounts.tokenVault,
      vault_authority: accounts.vaultAuthority, token_program: accounts.tokenProgram,
    }).args({ amount_in: args.amountIn, min_amount_out: args.minAmountOut }).rpc();
  }

  async addLiquidity(accounts: {
    stablePair: Address; lpPosition: Address; provider: Address;
    userTokenAccount: Address; userStableAccount: Address;
    tokenVault: Address; stableVault: Address; tokenProgram: Address;
  }, args: { tokenAmount: bigint | number; stableAmount: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("add_liquidity").accounts({
      stable_pair: accounts.stablePair, lp_position: accounts.lpPosition, provider: accounts.provider,
      user_token_account: accounts.userTokenAccount, user_stable_account: accounts.userStableAccount,
      token_vault: accounts.tokenVault, stable_vault: accounts.stableVault, token_program: accounts.tokenProgram,
    }).args({ token_amount: args.tokenAmount, stable_amount: args.stableAmount }).rpc();
  }

  async removeLiquidity(accounts: {
    stablePair: Address; lpPosition: Address; provider: Address;
    userTokenAccount: Address; userStableAccount: Address;
    tokenVault: Address; stableVault: Address; vaultAuthority: Address; tokenProgram: Address;
  }, args: { lpSharesToBurn: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("remove_liquidity").accounts({
      stable_pair: accounts.stablePair, lp_position: accounts.lpPosition, provider: accounts.provider,
      user_token_account: accounts.userTokenAccount, user_stable_account: accounts.userStableAccount,
      token_vault: accounts.tokenVault, stable_vault: accounts.stableVault,
      vault_authority: accounts.vaultAuthority, token_program: accounts.tokenProgram,
    }).args({ lp_shares_to_burn: args.lpSharesToBurn }).rpc();
  }

  async setPairPaused(accounts: { stablePair: Address; authority: Address }, args: { paused: number }) {
    const p = await this.handle.getProgram();
    return p.method("set_pair_paused").accounts({ stable_pair: accounts.stablePair, authority: accounts.authority })
      .args({ paused: args.paused }).rpc();
  }

  async updatePairFee(accounts: { stablePair: Address; authority: Address }, args: { newFeeBps: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("update_pair_fee").accounts({ stable_pair: accounts.stablePair, authority: accounts.authority })
      .args({ new_fee_bps: args.newFeeBps }).rpc();
  }

  async getTokenReserve(accounts: { stablePair: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_token_reserve").accounts({ stable_pair: accounts.stablePair }).args({}).rpc();
  }

  async getStableReserve(accounts: { stablePair: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_stable_reserve").accounts({ stable_pair: accounts.stablePair }).args({}).rpc();
  }
}
