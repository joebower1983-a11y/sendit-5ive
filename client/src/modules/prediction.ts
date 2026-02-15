import type { ProgramHandle } from "../base.js";
import type { Address } from "../types.js";

export class PredictionClient {
  constructor(private handle: ProgramHandle) {}

  async createPrediction(accounts: { market: Address; creator: Address },
    args: { tokenA: Address; tokenB: Address; deadline: bigint | number; marketIndex: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("create_prediction").accounts(accounts)
      .args({ token_a: args.tokenA, token_b: args.tokenB, deadline: args.deadline, market_index: args.marketIndex }).rpc();
  }

  async placeBet(accounts: { market: Address; userBet: Address; user: Address; vault: Address },
    args: { side: number; amount: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("place_bet").accounts({ market: accounts.market, user_bet: accounts.userBet, user: accounts.user, vault: accounts.vault })
      .args({ side: args.side, amount: args.amount }).rpc();
  }

  async resolvePrediction(accounts: { market: Address; resolver: Address },
    args: { graduationA: number; graduationB: number }) {
    const p = await this.handle.getProgram();
    return p.method("resolve_prediction").accounts(accounts)
      .args({ graduation_a: args.graduationA, graduation_b: args.graduationB }).rpc();
  }

  async claimWinnings(accounts: { market: Address; userBet: Address; user: Address; vault: Address }) {
    const p = await this.handle.getProgram();
    return p.method("claim_winnings").accounts({ market: accounts.market, user_bet: accounts.userBet, user: accounts.user, vault: accounts.vault }).args({}).rpc();
  }

  async getMarketOdds(accounts: { market: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_market_odds").accounts(accounts).args({}).rpc();
  }

  async getTotalPool(accounts: { market: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_total_pool").accounts(accounts).args({}).rpc();
  }
}
