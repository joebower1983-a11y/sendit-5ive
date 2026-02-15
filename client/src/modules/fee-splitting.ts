import type { ProgramHandle } from "../base.js";
import type { Address } from "../types.js";

export class FeeSplittingClient {
  constructor(private handle: ProgramHandle) {}

  async initializeFeeConfig(accounts: { config: Address; creator: Address },
    args: { tokenMint: Address; splitCount: number; split1Recipient: Address; split1Bps: bigint | number; allowUpdate: number }) {
    const p = await this.handle.getProgram();
    return p.method("initialize_fee_config").accounts(accounts)
      .args({ token_mint: args.tokenMint, split_count: args.splitCount, split1_recipient: args.split1Recipient, split1_bps: args.split1Bps, allow_update: args.allowUpdate }).rpc();
  }

  async addSplit(accounts: { config: Address; creator: Address },
    args: { slotIndex: number; recipient: Address; shareBps: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("add_split").accounts(accounts)
      .args({ slot_index: args.slotIndex, recipient: args.recipient, share_bps: args.shareBps }).rpc();
  }

  async distributeFees(accounts: { config: Address; claim1: Address; payer: Address },
    args: { available: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("distribute_fees").accounts(accounts).args({ available: args.available }).rpc();
  }

  async initUserFeeClaim(accounts: { claim: Address; payer: Address },
    args: { recipient: Address; tokenMint: Address }) {
    const p = await this.handle.getProgram();
    return p.method("init_user_fee_claim").accounts(accounts).args({ recipient: args.recipient, token_mint: args.tokenMint }).rpc();
  }

  async claimSplitFees(accounts: { claim: Address; recipient: Address }) {
    const p = await this.handle.getProgram();
    return p.method("claim_split_fees").accounts(accounts).args({}).rpc();
  }
}
