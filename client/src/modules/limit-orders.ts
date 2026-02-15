import type { ProgramHandle } from "../base.js";
import type { Address } from "../types.js";

export class LimitOrdersClient {
  constructor(private handle: ProgramHandle) {}

  async placeLimitOrder(accounts: { order: Address; counter: Address; owner: Address },
    args: { tokenMint: Address; side: number; priceTarget: bigint | number; amount: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("place_limit_order").accounts(accounts)
      .args({ token_mint: args.tokenMint, side: args.side, price_target: args.priceTarget, amount: args.amount }).rpc();
  }

  async cancelLimitOrder(accounts: { order: Address; counter: Address; owner: Address }) {
    const p = await this.handle.getProgram();
    return p.method("cancel_limit_order").accounts(accounts).args({}).rpc();
  }

  async fillLimitOrder(accounts: { order: Address; counter: Address; cranker: Address },
    args: { currentPrice: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("fill_limit_order").accounts(accounts).args({ current_price: args.currentPrice }).rpc();
  }

  async initOrderCounter(accounts: { counter: Address; owner: Address }) {
    const p = await this.handle.getProgram();
    return p.method("init_order_counter").accounts(accounts).args({}).rpc();
  }

  async getOrderStatus(accounts: { order: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_order_status").accounts(accounts).args({}).rpc();
  }
}
