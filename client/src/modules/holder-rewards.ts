import type { ProgramHandle } from "../base.js";
import type { Address } from "../types.js";

export class HolderRewardsClient {
  constructor(private handle: ProgramHandle) {}

  async initializeRewardPool(accounts: { pool: Address; authority: Address },
    args: { mint: Address; rewardFeeBps: bigint | number; minHoldSeconds: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("initialize_reward_pool").accounts(accounts)
      .args({ mint: args.mint, reward_fee_bps: args.rewardFeeBps, min_hold_seconds: args.minHoldSeconds }).rpc();
  }

  async accrueRewards(accounts: { pool: Address; authority: Address }, args: { rewardAmount: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("accrue_rewards").accounts(accounts).args({ reward_amount: args.rewardAmount }).rpc();
  }

  async updateUserRewardState(accounts: { pool: Address; userState: Address; authority: Address },
    args: { userKey: Address; newBalance: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("update_user_reward_state").accounts({ pool: accounts.pool, user_state: accounts.userState, authority: accounts.authority })
      .args({ user_key: args.userKey, new_balance: args.newBalance }).rpc();
  }

  async claimHolderRewards(accounts: { pool: Address; userState: Address; user: Address }) {
    const p = await this.handle.getProgram();
    return p.method("claim_holder_rewards").accounts({ pool: accounts.pool, user_state: accounts.userState, user: accounts.user }).args({}).rpc();
  }

  async toggleAutoCompound(accounts: { userState: Address; user: Address }, args: { enabled: number }) {
    const p = await this.handle.getProgram();
    return p.method("toggle_auto_compound").accounts({ user_state: accounts.userState, user: accounts.user })
      .args({ enabled: args.enabled }).rpc();
  }

  async getPendingRewards(accounts: { pool: Address; userState: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_pending_rewards").accounts({ pool: accounts.pool, user_state: accounts.userState }).args({}).rpc();
  }
}
