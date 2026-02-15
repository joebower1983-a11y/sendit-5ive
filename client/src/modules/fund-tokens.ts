import type { ProgramHandle } from "../base.js";
import type { Address } from "../types.js";

export class FundTokensClient {
  constructor(private handle: ProgramHandle) {}

  async createFund(accounts: { fundConfig: Address; creator: Address },
    args: { shareMint: Address; nameHash: Address; managementFeeBps: bigint | number; numTokens: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("create_fund").accounts({ fund_config: accounts.fundConfig, creator: accounts.creator })
      .args({ share_mint: args.shareMint, name_hash: args.nameHash, management_fee_bps: args.managementFeeBps, num_tokens: args.numTokens }).rpc();
  }

  async depositToFund(accounts: { fundConfig: Address; userPosition: Address; depositor: Address },
    args: { solAmount: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("deposit_to_fund").accounts({ fund_config: accounts.fundConfig, user_position: accounts.userPosition, depositor: accounts.depositor })
      .args({ sol_amount: args.solAmount }).rpc();
  }

  async redeemShares(accounts: { fundConfig: Address; userPosition: Address; redeemer: Address },
    args: { shareAmount: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("redeem_shares").accounts({ fund_config: accounts.fundConfig, user_position: accounts.userPosition, redeemer: accounts.redeemer })
      .args({ share_amount: args.shareAmount }).rpc();
  }

  async rebalanceFund(accounts: { fundConfig: Address; creator: Address },
    args: { newWeightSum: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("rebalance_fund").accounts({ fund_config: accounts.fundConfig, creator: accounts.creator })
      .args({ new_weight_sum: args.newWeightSum }).rpc();
  }

  async setFundActive(accounts: { fundConfig: Address; creator: Address }, args: { active: number }) {
    const p = await this.handle.getProgram();
    return p.method("set_fund_active").accounts({ fund_config: accounts.fundConfig, creator: accounts.creator })
      .args({ active: args.active }).rpc();
  }

  async getTotalDeposits(accounts: { fundConfig: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_total_deposits").accounts({ fund_config: accounts.fundConfig }).args({}).rpc();
  }
}
