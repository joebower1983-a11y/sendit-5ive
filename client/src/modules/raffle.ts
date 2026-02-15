import type { ProgramHandle } from "../base.js";
import type { Address } from "../types.js";

export class RaffleClient {
  constructor(private handle: ProgramHandle) {}

  async createRaffle(accounts: { raffle: Address; creator: Address },
    args: { tokenLaunch: Address; mint: Address; ticketPrice: bigint | number; maxTickets: bigint | number; winnerCount: bigint | number; drawDelaySeconds: bigint | number; tokenAllocation: bigint | number }) {
    const p = await this.handle.getProgram();
    return p.method("create_raffle").accounts(accounts)
      .args({ token_launch: args.tokenLaunch, mint: args.mint, ticket_price: args.ticketPrice, max_tickets: args.maxTickets, winner_count: args.winnerCount, draw_delay_seconds: args.drawDelaySeconds, token_allocation: args.tokenAllocation }).rpc();
  }

  async buyTicket(accounts: { raffle: Address; raffleTicket: Address; buyer: Address }) {
    const p = await this.handle.getProgram();
    return p.method("buy_ticket").accounts({ raffle: accounts.raffle, raffle_ticket: accounts.raffleTicket, buyer: accounts.buyer }).args({}).rpc();
  }

  async drawWinners(accounts: { raffle: Address; payer: Address }) {
    const p = await this.handle.getProgram();
    return p.method("draw_winners").accounts(accounts).args({}).rpc();
  }

  async claimRafflePrize(accounts: {
    raffle: Address; raffleTicket: Address; claimer: Address;
    raffleTokenVault: Address; claimerTokenAccount: Address; vaultAuthority: Address; tokenProgram: Address;
  }) {
    const p = await this.handle.getProgram();
    return p.method("claim_raffle_prize").accounts({
      raffle: accounts.raffle, raffle_ticket: accounts.raffleTicket, claimer: accounts.claimer,
      raffle_token_vault: accounts.raffleTokenVault, claimer_token_account: accounts.claimerTokenAccount,
      vault_authority: accounts.vaultAuthority, token_program: accounts.tokenProgram,
    }).args({}).rpc();
  }

  async getRaffleSold(accounts: { raffle: Address }) {
    const p = await this.handle.getProgram();
    return p.method("get_raffle_sold").accounts(accounts).args({}).rpc();
  }
}
