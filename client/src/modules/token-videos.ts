import type { ProgramHandle } from "../base.js";
import type { Address } from "../types.js";

export class TokenVideosClient {
  constructor(private handle: ProgramHandle) {}

  async setTokenVideo(accounts: { tokenVideo: Address; creator: Address; tokenMint: Address }) {
    const p = await this.handle.getProgram();
    return p.method("set_token_video").accounts({ token_video: accounts.tokenVideo, creator: accounts.creator, token_mint: accounts.tokenMint }).args({}).rpc();
  }

  async upvoteVideo(accounts: { tokenVideo: Address; userVote: Address; voter: Address; tokenMint: Address }) {
    const p = await this.handle.getProgram();
    return p.method("upvote_video").accounts({ token_video: accounts.tokenVideo, user_vote: accounts.userVote, voter: accounts.voter, token_mint: accounts.tokenMint }).args({}).rpc();
  }

  async downvoteVideo(accounts: { tokenVideo: Address; userVote: Address; voter: Address; tokenMint: Address }) {
    const p = await this.handle.getProgram();
    return p.method("downvote_video").accounts({ token_video: accounts.tokenVideo, user_vote: accounts.userVote, voter: accounts.voter, token_mint: accounts.tokenMint }).args({}).rpc();
  }

  async removeVideo(accounts: { tokenVideo: Address; authority: Address }) {
    const p = await this.handle.getProgram();
    return p.method("remove_video").accounts({ token_video: accounts.tokenVideo, authority: accounts.authority }).args({}).rpc();
  }

  async getTotalVotes(accounts: { tokenVideo: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_total_votes").accounts({ token_video: accounts.tokenVideo }).args({}).rpc();
  }
}
