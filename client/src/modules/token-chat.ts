import type { ProgramHandle } from "../base.js";
import type { Address } from "../types.js";

export class TokenChatClient {
  constructor(private handle: ProgramHandle) {}

  async initializeChatState(accounts: { chatState: Address; payer: Address; tokenMint: Address }) {
    const p = await this.handle.getProgram();
    return p.method("initialize_chat_state").accounts({ chat_state: accounts.chatState, payer: accounts.payer, token_mint: accounts.tokenMint }).args({}).rpc();
  }

  async postMessage(accounts: { chatState: Address; chatMessage: Address; author: Address; tokenMint: Address }) {
    const p = await this.handle.getProgram();
    return p.method("post_message").accounts({ chat_state: accounts.chatState, chat_message: accounts.chatMessage, author: accounts.author, token_mint: accounts.tokenMint }).args({}).rpc();
  }

  async likeMessage(accounts: { chatMessage: Address; liker: Address }) {
    const p = await this.handle.getProgram();
    return p.method("like_message").accounts({ chat_message: accounts.chatMessage, liker: accounts.liker }).args({}).rpc();
  }

  async deleteMessage(accounts: { chatMessage: Address; author: Address }) {
    const p = await this.handle.getProgram();
    return p.method("delete_message").accounts({ chat_message: accounts.chatMessage, author: accounts.author }).args({}).rpc();
  }

  async getMessageLikes(accounts: { chatMessage: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_message_likes").accounts({ chat_message: accounts.chatMessage }).args({}).rpc();
  }
}
