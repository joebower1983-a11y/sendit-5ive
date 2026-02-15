import type { ProgramHandle } from "../base.js";
import type { Address } from "../types.js";

export class PriceAlertsClient {
  constructor(private handle: ProgramHandle) {}

  async createAlert(accounts: { alert: Address; owner: Address },
    args: { tokenMint: Address; alertId: bigint | number; targetPrice: bigint | number; direction: number }) {
    const p = await this.handle.getProgram();
    return p.method("create_alert").accounts(accounts)
      .args({ token_mint: args.tokenMint, alert_id: args.alertId, target_price: args.targetPrice, direction: args.direction }).rpc();
  }

  async cancelAlert(accounts: { alert: Address; owner: Address }) {
    const p = await this.handle.getProgram();
    return p.method("cancel_alert").accounts(accounts).args({}).rpc();
  }

  async checkAlert(accounts: { alert: Address; crank: Address }, args: { currentPrice: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("check_alert").accounts(accounts).args({ current_price: args.currentPrice }).rpc();
  }

  async getAlertTarget(accounts: { alert: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_alert_target").accounts(accounts).args({}).rpc();
  }
}
