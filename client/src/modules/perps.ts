import type { ProgramHandle } from "../base.js";
import type { Address } from "../types.js";

/** Client for the perpetuals / derivatives module (perps.v) */
export class PerpsClient {
  constructor(private handle: ProgramHandle) {}

  async initializePerpMarket(accounts: {
    market: Address; orderBook: Address; insFund: Address; authority: Address;
    tokenMint: Address; collateralMint: Address; raydiumPool: Address;
    solforgeVault: Address; collateralVault: Address; insuranceVault: Address;
  }) {
    const p = await this.handle.getProgram();
    return p.method("initialize_perp_market").accounts({
      market: accounts.market, order_book: accounts.orderBook, ins_fund: accounts.insFund,
      authority: accounts.authority, token_mint: accounts.tokenMint, collateral_mint: accounts.collateralMint,
      raydium_pool: accounts.raydiumPool, solforge_vault: accounts.solforgeVault,
      collateral_vault: accounts.collateralVault, insurance_vault: accounts.insuranceVault,
    }).args({}).rpc();
  }

  async createMarginAccount(accounts: { marginAccount: Address; owner: Address }) {
    const p = await this.handle.getProgram();
    return p.method("create_margin_account").accounts({ margin_account: accounts.marginAccount, owner: accounts.owner }).args({}).rpc();
  }

  async depositCollateral(accounts: {
    marginAccount: Address; owner: Address; userTokenAccount: Address;
    collateralVault: Address; tokenProgram: Address;
  }, args: { amount: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("deposit_collateral").accounts({
      margin_account: accounts.marginAccount, owner: accounts.owner,
      user_token_account: accounts.userTokenAccount, collateral_vault: accounts.collateralVault,
      token_program: accounts.tokenProgram,
    }).args({ amount: args.amount }).rpc();
  }

  async withdrawCollateral(accounts: {
    marginAccount: Address; market: Address; owner: Address;
    userTokenAccount: Address; collateralVault: Address; vaultAuthority: Address; tokenProgram: Address;
  }, args: { amount: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("withdraw_collateral").accounts({
      margin_account: accounts.marginAccount, market: accounts.market, owner: accounts.owner,
      user_token_account: accounts.userTokenAccount, collateral_vault: accounts.collateralVault,
      vault_authority: accounts.vaultAuthority, token_program: accounts.tokenProgram,
    }).args({ amount: args.amount }).rpc();
  }

  async openPosition(accounts: {
    market: Address; marginAccount: Address; position: Address; owner: Address;
  }, args: { side: number; size: bigint | number; leverage: bigint | number; collateralAmount: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("open_position").accounts({
      market: accounts.market, margin_account: accounts.marginAccount,
      position: accounts.position, owner: accounts.owner,
    }).args({ side: args.side, size: args.size, leverage: args.leverage, collateral_amount: args.collateralAmount }).rpc();
  }

  async closePosition(accounts: { market: Address; position: Address; marginAccount: Address; owner: Address }) {
    const p = await this.handle.getProgram();
    return p.method("close_position").accounts({
      market: accounts.market, position: accounts.position,
      margin_account: accounts.marginAccount, owner: accounts.owner,
    }).args({}).rpc();
  }

  async increasePosition(accounts: { market: Address; position: Address; marginAccount: Address; owner: Address },
    args: { additionalSize: bigint | number; additionalCollateral: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("increase_position").accounts({
      market: accounts.market, position: accounts.position,
      margin_account: accounts.marginAccount, owner: accounts.owner,
    }).args({ additional_size: args.additionalSize, additional_collateral: args.additionalCollateral }).rpc();
  }

  async decreasePosition(accounts: { market: Address; position: Address; marginAccount: Address; owner: Address },
    args: { decreaseSize: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("decrease_position").accounts({
      market: accounts.market, position: accounts.position,
      margin_account: accounts.marginAccount, owner: accounts.owner,
    }).args({ decrease_size: args.decreaseSize }).rpc();
  }

  async placeOrder(accounts: {
    market: Address; orderBook: Address; orderEntry: Address; marginAccount: Address; owner: Address;
  }, args: { side: number; orderType: number; price: bigint | number; size: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("place_order").accounts({
      market: accounts.market, order_book: accounts.orderBook, order_entry: accounts.orderEntry,
      margin_account: accounts.marginAccount, owner: accounts.owner,
    }).args({ side: args.side, order_type: args.orderType, price: args.price, size: args.size }).rpc();
  }

  async cancelOrder(accounts: { orderBook: Address; orderEntry: Address; owner: Address }) {
    const p = await this.handle.getProgram();
    return p.method("cancel_order").accounts({ order_book: accounts.orderBook, order_entry: accounts.orderEntry, owner: accounts.owner }).args({}).rpc();
  }

  async matchOrders(accounts: { market: Address; orderBook: Address; bidOrder: Address; askOrder: Address; cranker: Address }) {
    const p = await this.handle.getProgram();
    return p.method("match_orders").accounts({
      market: accounts.market, order_book: accounts.orderBook,
      bid_order: accounts.bidOrder, ask_order: accounts.askOrder, cranker: accounts.cranker,
    }).args({}).rpc();
  }

  async updateFundingRate(accounts: { market: Address; cranker: Address }) {
    const p = await this.handle.getProgram();
    return p.method("update_funding_rate").accounts(accounts).args({}).rpc();
  }

  async liquidatePosition(accounts: {
    market: Address; position: Address; positionMargin: Address; insFund: Address; liquidator: Address;
  }, args: { liquidationSize: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("liquidate_position").accounts({
      market: accounts.market, position: accounts.position,
      position_margin: accounts.positionMargin, ins_fund: accounts.insFund,
      liquidator: accounts.liquidator,
    }).args({ liquidation_size: args.liquidationSize }).rpc();
  }

  async updateOraclePrice(accounts: { market: Address; cranker: Address }, args: { price: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("update_oracle_price").accounts(accounts).args({ price: args.price }).rpc();
  }

  async setMarketPaused(accounts: { market: Address; authority: Address }, args: { paused: number }) {
    const p = await this.handle.getProgram();
    return p.method("set_market_paused").accounts(accounts).args({ paused: args.paused }).rpc();
  }

  async getMarkPrice(accounts: { market: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_mark_price").accounts(accounts).args({}).rpc();
  }

  async getPositionPnl(accounts: { market: Address; position: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_position_pnl").accounts(accounts).args({}).rpc();
  }

  async getMarginRatio(accounts: { market: Address; position: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_margin_ratio").accounts(accounts).args({}).rpc();
  }

  async isLiquidatable(accounts: { market: Address; position: Address }) {
    const p = await this.handle.getProgram();
    return p.method("is_liquidatable").accounts(accounts).args({}).rpc();
  }

  async depositInsurance(accounts: {
    insFund: Address; depositor: Address; depositorTokenAccount: Address;
    insuranceVault: Address; tokenProgram: Address;
  }, args: { amount: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("deposit_insurance").accounts({
      ins_fund: accounts.insFund, depositor: accounts.depositor,
      depositor_token_account: accounts.depositorTokenAccount,
      insurance_vault: accounts.insuranceVault, token_program: accounts.tokenProgram,
    }).args({ amount: args.amount }).rpc();
  }
}
