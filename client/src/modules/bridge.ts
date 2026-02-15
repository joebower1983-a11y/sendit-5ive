import type { ProgramHandle } from "../base.js";
import type { Address } from "../types.js";

export class BridgeClient {
  constructor(private handle: ProgramHandle) {}

  async initializeBridge(accounts: { bridgeConfig: Address; authority: Address }, args: {
    wormholeProgram: Address; wormholeBridge: Address; feeCollector: Address;
    defaultFeeBps: bigint | number; defaultMinAmount: bigint | number;
  }) {
    const p = await this.handle.getProgram();
    return p.method("initialize_bridge").accounts({
      bridge_config: accounts.bridgeConfig, authority: accounts.authority,
    }).args({
      wormhole_program: args.wormholeProgram, wormhole_bridge: args.wormholeBridge,
      fee_collector: args.feeCollector, default_fee_bps: args.defaultFeeBps,
      default_min_amount: args.defaultMinAmount,
    }).rpc();
  }

  async initiateBridge(accounts: {
    bridgeConfig: Address; bridgeRequest: Address; user: Address;
    userTokenAccount: Address; tokenVault: Address; feeVault: Address; tokenProgram: Address;
  }, args: { amount: bigint | number; destinationChain: bigint | number; nonce: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("initiate_bridge").accounts({
      bridge_config: accounts.bridgeConfig, bridge_request: accounts.bridgeRequest,
      user: accounts.user, user_token_account: accounts.userTokenAccount,
      token_vault: accounts.tokenVault, fee_vault: accounts.feeVault,
      token_program: accounts.tokenProgram,
    }).args({ amount: args.amount, destination_chain: args.destinationChain, nonce: args.nonce }).rpc();
  }

  async confirmBridge(accounts: { bridgeConfig: Address; bridgeRequest: Address; authority: Address },
    args: { wormholeSequence: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("confirm_bridge").accounts({
      bridge_config: accounts.bridgeConfig, bridge_request: accounts.bridgeRequest,
      authority: accounts.authority,
    }).args({ wormhole_sequence: args.wormholeSequence }).rpc();
  }

  async cancelBridge(accounts: {
    bridgeConfig: Address; bridgeRequest: Address; user: Address;
    userTokenAccount: Address; tokenVault: Address; vaultAuthority: Address; tokenProgram: Address;
  }) {
    const p = await this.handle.getProgram();
    return p.method("cancel_bridge").accounts({
      bridge_config: accounts.bridgeConfig, bridge_request: accounts.bridgeRequest,
      user: accounts.user, user_token_account: accounts.userTokenAccount,
      token_vault: accounts.tokenVault, vault_authority: accounts.vaultAuthority,
      token_program: accounts.tokenProgram,
    }).args({}).rpc();
  }

  async setBridgePaused(accounts: { bridgeConfig: Address; authority: Address }, args: { paused: number }) {
    const p = await this.handle.getProgram();
    return p.method("set_bridge_paused").accounts({
      bridge_config: accounts.bridgeConfig, authority: accounts.authority,
    }).args({ paused: args.paused }).rpc();
  }

  async getTotalBridged(accounts: { bridgeConfig: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_total_bridged").accounts({ bridge_config: accounts.bridgeConfig }).args({}).rpc();
  }
}
