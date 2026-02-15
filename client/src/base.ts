/**
 * Base client — wraps FiveSDK static methods for the deployed SendIt script.
 */

import { Connection, Keypair, PublicKey } from "@solana/web3.js";
import { FiveSDK } from "@5ive-tech/sdk";

export interface SenditSDKConfig {
  /** Solana RPC connection */
  connection: Connection;
  /** Fee-payer / signer keypair */
  payer: Keypair;
  /** The deployed script account address */
  scriptAccount: string;
  /** Optional: Five VM program ID override */
  fiveVMProgramId?: string;
}

export interface ExecuteResult {
  success: boolean;
  result?: unknown;
  transactionId?: string;
  computeUnitsUsed?: number;
  cost?: number;
  error?: string;
  logs?: string[];
}

/**
 * Shared program handle for all module clients.
 * Wraps `FiveSDK.executeOnSolana()` with the configured script account.
 */
export class ProgramHandle {
  readonly connection: Connection;
  readonly payer: Keypair;
  readonly scriptAccount: string;
  private fiveVMProgramId?: string;

  constructor(config: SenditSDKConfig) {
    this.connection = config.connection;
    this.payer = config.payer;
    this.scriptAccount = config.scriptAccount;
    this.fiveVMProgramId = config.fiveVMProgramId;
  }

  /**
   * Execute an on-chain function by name.
   *
   * @param functionName - the function name as declared in the .v source
   * @param parameters  - ordered parameter values (matching the ABI)
   * @param accounts    - ordered account public key strings
   * @returns execution result including transactionId
   */
  async execute(
    functionName: string,
    parameters: unknown[] = [],
    accounts: string[] = [],
  ): Promise<ExecuteResult> {
    return FiveSDK.executeOnSolana(
      this.scriptAccount,
      this.connection,
      this.payer,
      functionName,
      parameters,
      accounts,
      {
        fiveVMProgramId: this.fiveVMProgramId,
      },
    );
  }
}
