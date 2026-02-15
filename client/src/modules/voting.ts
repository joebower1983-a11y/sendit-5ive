import type { ProgramHandle } from "../base.js";
import type { Address } from "../types.js";

export class VotingClient {
  constructor(private handle: ProgramHandle) {}

  async createProposal(accounts: { proposal: Address; creator: Address },
    args: { tokenMint: Address; optionCount: number; startTime: bigint | number; endTime: bigint | number; quorum: bigint | number; proposalId: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("create_proposal").accounts(accounts)
      .args({ token_mint: args.tokenMint, option_count: args.optionCount, start_time: args.startTime, end_time: args.endTime, quorum: args.quorum, proposal_id: args.proposalId }).rpc();
  }

  async castVote(accounts: { proposal: Address; userVote: Address; voter: Address },
    args: { optionIndex: number; weight: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("cast_vote").accounts({ proposal: accounts.proposal, user_vote: accounts.userVote, voter: accounts.voter })
      .args({ option_index: args.optionIndex, weight: args.weight }).rpc();
  }

  async finalizeProposal(accounts: { proposal: Address; finalizer: Address }) {
    const p = await this.handle.getProgram();
    return p.method("finalize_proposal").accounts(accounts).args({}).rpc();
  }

  async getTotalVotes(accounts: { proposal: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_total_votes").accounts(accounts).args({}).rpc();
  }
}
