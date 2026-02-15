import type { ProgramHandle } from "../base.js";
import type { Address } from "../types.js";

export class LendingClient {
  constructor(private handle: ProgramHandle) {}

  async createLendingPool(accounts: { lendingPool: Address; authority: Address },
    args: { collateralMint: Address; interestRateBps: bigint | number; ltvRatio: bigint | number; liquidationThresholdBps: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("create_lending_pool").accounts({ lending_pool: accounts.lendingPool, authority: accounts.authority })
      .args({ collateral_mint: args.collateralMint, interest_rate_bps: args.interestRateBps, ltv_ratio: args.ltvRatio, liquidation_threshold_bps: args.liquidationThresholdBps }).rpc();
  }

  async depositSol(accounts: { lendingPool: Address; userPosition: Address; user: Address },
    args: { amount: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("deposit_sol").accounts({ lending_pool: accounts.lendingPool, user_position: accounts.userPosition, user: accounts.user })
      .args({ amount: args.amount }).rpc();
  }

  async borrowAgainstTokens(accounts: {
    lendingPool: Address; userPosition: Address; user: Address;
    userTokenAccount: Address; tokenVault: Address; tokenProgram: Address;
  }, args: { collateralAmount: bigint | number; borrowAmount: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("borrow_against_tokens").accounts({
      lending_pool: accounts.lendingPool, user_position: accounts.userPosition,
      user: accounts.user, user_token_account: accounts.userTokenAccount,
      token_vault: accounts.tokenVault, token_program: accounts.tokenProgram,
    }).args({ collateral_amount: args.collateralAmount, borrow_amount: args.borrowAmount }).rpc();
  }

  async repay(accounts: { lendingPool: Address; userPosition: Address; user: Address },
    args: { amount: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("repay").accounts({ lending_pool: accounts.lendingPool, user_position: accounts.userPosition, user: accounts.user })
      .args({ amount: args.amount }).rpc();
  }

  async withdrawSol(accounts: { lendingPool: Address; userPosition: Address; user: Address },
    args: { amount: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("withdraw_sol").accounts({ lending_pool: accounts.lendingPool, user_position: accounts.userPosition, user: accounts.user })
      .args({ amount: args.amount }).rpc();
  }

  async liquidate(accounts: {
    lendingPool: Address; userPosition: Address; liquidator: Address;
    tokenVault: Address; liquidatorTokenAccount: Address; vaultAuthority: Address; tokenProgram: Address;
  }) {
    const p = await this.handle.getProgram();
    return p.method("liquidate").accounts({
      lending_pool: accounts.lendingPool, user_position: accounts.userPosition,
      liquidator: accounts.liquidator, token_vault: accounts.tokenVault,
      liquidator_token_account: accounts.liquidatorTokenAccount,
      vault_authority: accounts.vaultAuthority, token_program: accounts.tokenProgram,
    }).args({}).rpc();
  }

  async getPoolUtilization(accounts: { lendingPool: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_pool_utilization").accounts({ lending_pool: accounts.lendingPool }).args({}).rpc();
  }
}
