import type { ProgramHandle } from "../base.js";
import type { Address } from "../types.js";

export class LiveChatClient {
  constructor(private handle: ProgramHandle) {}

  async initializeChatRoom(accounts: { chatRoom: Address; creator: Address; authority: Address; tokenMint: Address },
    args: { slowmodeSeconds: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("initialize_chat_room").accounts({
      chat_room: accounts.chatRoom, creator: accounts.creator, authority: accounts.authority, token_mint: accounts.tokenMint,
    }).args({ slowmode_seconds: args.slowmodeSeconds }).rpc();
  }

  async sendLiveMessage(accounts: {
    chatRoom: Address; liveMessage: Address; userChatState: Address; author: Address;
  }, args: { textHash: Address; tipLamports: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("send_live_message").accounts({
      chat_room: accounts.chatRoom, live_message: accounts.liveMessage,
      user_chat_state: accounts.userChatState, author: accounts.author,
    }).args({ text_hash: args.textHash, tip_lamports: args.tipLamports }).rpc();
  }

  async toggleSlowmode(accounts: { chatRoom: Address; signer: Address },
    args: { slowmodeSeconds: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("toggle_slowmode").accounts({ chat_room: accounts.chatRoom, signer: accounts.signer })
      .args({ slowmode_seconds: args.slowmodeSeconds }).rpc();
  }

  async closeChat(accounts: { chatRoom: Address; signer: Address }) {
    const p = await this.handle.getProgram();
    return p.method("close_chat").accounts({ chat_room: accounts.chatRoom, signer: accounts.signer }).args({}).rpc();
  }

  async getMessageCount(accounts: { chatRoom: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_message_count").accounts({ chat_room: accounts.chatRoom }).args({}).rpc();
  }
}
