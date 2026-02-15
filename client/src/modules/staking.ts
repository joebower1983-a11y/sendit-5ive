import type { ProgramHandle } from "../base.js";
import type { Address } from "../types.js";

/** Client for main.v — staking module */
export class StakingClient {
  constructor(private handle: ProgramHandle) {}

  async createStakePool(accounts: { stakePool: Address; creator: Address; mint: Address; vault: Address },
    args: { rewardRate: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("create_stake_pool").accounts({
      stake_pool: accounts.stakePool, creator: accounts.creator, mint: accounts.mint, vault: accounts.vault,
    }).args({ reward_rate: args.rewardRate }).rpc();
  }

  async stakeTokens(accounts: {
    stakePool: Address; userStake: Address; user: Address;
    userTokenAccount: Address; vaultTokenAccount: Address; tokenProgram: Address;
  }, args: { amount: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("stake_tokens").accounts({
      stake_pool: accounts.stakePool, user_stake: accounts.userStake, user: accounts.user,
      user_token_account: accounts.userTokenAccount, vault_token_account: accounts.vaultTokenAccount,
      token_program: accounts.tokenProgram,
    }).args({ amount: args.amount }).rpc();
  }

  async unstakeTokens(accounts: {
    stakePool: Address; userStake: Address; user: Address;
    userTokenAccount: Address; vaultTokenAccount: Address; vaultAuthority: Address; tokenProgram: Address;
  }, args: { amount: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("unstake_tokens").accounts({
      stake_pool: accounts.stakePool, user_stake: accounts.userStake, user: accounts.user,
      user_token_account: accounts.userTokenAccount, vault_token_account: accounts.vaultTokenAccount,
      vault_authority: accounts.vaultAuthority, token_program: accounts.tokenProgram,
    }).args({ amount: args.amount }).rpc();
  }

  async claimStakingRewards(accounts: {
    stakePool: Address; userStake: Address; user: Address;
    userTokenAccount: Address; vaultTokenAccount: Address; vaultAuthority: Address; tokenProgram: Address;
  }) {
    const p = await this.handle.getProgram();
    return p.method("claim_staking_rewards").accounts({
      stake_pool: accounts.stakePool, user_stake: accounts.userStake, user: accounts.user,
      user_token_account: accounts.userTokenAccount, vault_token_account: accounts.vaultTokenAccount,
      vault_authority: accounts.vaultAuthority, token_program: accounts.tokenProgram,
    }).args({}).rpc();
  }

  async getPendingRewards(accounts: { stakePool: Address; userStake: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_pending_rewards").accounts({ stake_pool: accounts.stakePool, user_stake: accounts.userStake }).args({}).rpc();
  }
}
