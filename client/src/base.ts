/**
 * Base client — shared program handle for all module clients.
 */

import { Connection, Keypair, PublicKey } from "@solana/web3.js";
import { FiveSDK } from "@5ive-tech/sdk";
import fs from "node:fs";
import path from "node:path";

/** Resolved program handle returned by FiveSDK.loadProgram */
export type FiveProgram = Awaited<ReturnType<FiveSDK["loadProgram"]>>;

export interface SenditSDKConfig {
  /** Solana RPC connection */
  connection: Connection;
  /** Fee-payer / signer keypair */
  payer: Keypair;
  /** Deployed program ID */
  programId: PublicKey;
  /** Path to the compiled .five artifact (default: build/sendit-5ive.five) */
  artifactPath?: string;
}

/**
 * Lazy-initialised wrapper around the 5IVE SDK program handle.
 * All module clients receive a reference to this and call `getProgram()`.
 */
export class ProgramHandle {
  private _program: FiveProgram | null = null;
  private _sdk: FiveSDK;
  private _programId: PublicKey;
  private _artifactPath: string;

  constructor(config: SenditSDKConfig) {
    this._sdk = new FiveSDK(config.connection, config.payer);
    this._programId = config.programId;
    this._artifactPath =
      config.artifactPath ??
      path.resolve(process.cwd(), "build", "sendit-5ive.five");
  }

  /** Returns the loaded program, initialising on first call. */
  async getProgram(): Promise<FiveProgram> {
    if (!this._program) {
      const bytecode = fs.readFileSync(this._artifactPath);
      this._program = await this._sdk.loadProgram({
        programId: this._programId,
        bytecode,
      });
    }
    return this._program;
  }

  get sdk(): FiveSDK {
    return this._sdk;
  }

  get programId(): PublicKey {
    return this._programId;
  }
}
