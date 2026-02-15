import type { ProgramHandle, ExecuteResult } from "../base.js";
import type { Address } from "../types.js";
const s = (a: Address): string => typeof a === "string" ? a : a.toBase58();

export class BridgeClient {
  constructor(private h: ProgramHandle) {}

  initializeBridge(accounts: { bridgeConfig: Address; authority: Address },
    args: { wormholeProgram: Address; wormholeBridge: Address; feeCollector: Address; defaultFeeBps: bigint | number; defaultMinAmount: bigint | number }): Promise<ExecuteResult> {
    return this.h.execute("initialize_bridge",
      [s(args.wormholeProgram), s(args.wormholeBridge), s(args.feeCollector), args.defaultFeeBps, args.defaultMinAmount],
      [s(accounts.bridgeConfig), s(accounts.authority)]);
  }

  initiateBridge(accounts: { bridgeConfig: Address; bridgeRequest: Address; user: Address; userTokenAccount: Address; tokenVault: Address; feeVault: Address; tokenProgram: Address },
    args: { amount: bigint | number; destinationChain: bigint | number; nonce: bigint | number }): Promise<ExecuteResult> {
    return this.h.execute("initiate_bridge", [args.amount, args.destinationChain, args.nonce],
      [s(accounts.bridgeConfig), s(accounts.bridgeRequest), s(accounts.user), s(accounts.userTokenAccount), s(accounts.tokenVault), s(accounts.feeVault), s(accounts.tokenProgram)]);
  }

  confirmBridge(accounts: { bridgeConfig: Address; bridgeRequest: Address; authority: Address },
    args: { wormholeSequence: bigint | number }): Promise<ExecuteResult> {
    return this.h.execute("confirm_bridge", [args.wormholeSequence],
      [s(accounts.bridgeConfig), s(accounts.bridgeRequest), s(accounts.authority)]);
  }

  cancelBridge(accounts: { bridgeConfig: Address; bridgeRequest: Address; user: Address; userTokenAccount: Address; tokenVault: Address; vaultAuthority: Address; tokenProgram: Address }): Promise<ExecuteResult> {
    return this.h.execute("cancel_bridge", [],
      [s(accounts.bridgeConfig), s(accounts.bridgeRequest), s(accounts.user), s(accounts.userTokenAccount), s(accounts.tokenVault), s(accounts.vaultAuthority), s(accounts.tokenProgram)]);
  }

  setBridgePaused(accounts: { bridgeConfig: Address; authority: Address }, args: { paused: number }): Promise<ExecuteResult> {
    return this.h.execute("set_bridge_paused", [args.paused], [s(accounts.bridgeConfig), s(accounts.authority)]);
  }

  getTotalBridged(accounts: { bridgeConfig: Address }): Promise<ExecuteResult> {
    return this.h.execute("get_total_bridged", [], [s(accounts.bridgeConfig)]);
  }
}
