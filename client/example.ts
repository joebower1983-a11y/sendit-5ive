/**
 * SendIt 5IVE SDK — Example Usage
 *
 * Demonstrates: connect to devnet, create a stake pool, stake tokens,
 * create a prediction market, and place a bet.
 *
 * Prerequisites:
 *   - Deploy the sendit-5ive program and replace PROGRAM_ID below
 *   - Fund a payer keypair on devnet
 */

import { Connection, Keypair, PublicKey, LAMPORTS_PER_SOL } from "@solana/web3.js";
import fs from "node:fs";
import { SenditSDK } from "./src/index.js";

// ---------------------------------------------------------------------------
// Configuration — replace with your values
// ---------------------------------------------------------------------------

const PROGRAM_ID = new PublicKey("11111111111111111111111111111111"); // TODO: replace
const RPC_URL = "https://api.devnet.solana.com";

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function loadKeypair(path: string): Keypair {
  const secret = JSON.parse(fs.readFileSync(path, "utf8"));
  return Keypair.fromSecretKey(Uint8Array.from(secret));
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

async function main() {
  // 1. Connect to devnet
  const connection = new Connection(RPC_URL, "confirmed");
  console.log("Connected to", RPC_URL);

  // 2. Load payer keypair (generate a fresh one for demo purposes)
  const payer = Keypair.generate();
  console.log("Payer:", payer.publicKey.toBase58());

  // If you have a funded keypair file:
  // const payer = loadKeypair("./payer.json");

  // 3. Initialise the SDK
  const sdk = new SenditSDK({
    connection,
    payer,
    programId: PROGRAM_ID,
    artifactPath: "./build/sendit-5ive.five",
  });

  // ---------------------------------------------------------------------------
  // Staking: create pool & stake
  // ---------------------------------------------------------------------------

  const stakePoolKp = Keypair.generate();
  const userStakeKp = Keypair.generate();
  const mintKp = Keypair.generate();   // placeholder mint
  const vaultKp = Keypair.generate();  // placeholder vault
  const TOKEN_PROGRAM_ID = new PublicKey("TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA");

  console.log("\n--- Create Stake Pool ---");
  try {
    const sig1 = await sdk.staking.createStakePool(
      {
        stakePool: stakePoolKp.publicKey,
        creator: payer.publicKey,
        mint: mintKp.publicKey,
        vault: vaultKp.publicKey,
      },
      { rewardRate: 1000 },
    );
    console.log("createStakePool tx:", sig1);
  } catch (e) {
    console.error("createStakePool failed (expected on unfunded devnet):", (e as Error).message);
  }

  console.log("\n--- Stake Tokens ---");
  try {
    const sig2 = await sdk.staking.stakeTokens(
      {
        stakePool: stakePoolKp.publicKey,
        userStake: userStakeKp.publicKey,
        user: payer.publicKey,
        userTokenAccount: Keypair.generate().publicKey,
        vaultTokenAccount: vaultKp.publicKey,
        tokenProgram: TOKEN_PROGRAM_ID,
      },
      { amount: 500_000_000n }, // 0.5 tokens (assuming 9 decimals)
    );
    console.log("stakeTokens tx:", sig2);
  } catch (e) {
    console.error("stakeTokens failed:", (e as Error).message);
  }

  // ---------------------------------------------------------------------------
  // Prediction Market: create & bet
  // ---------------------------------------------------------------------------

  const marketKp = Keypair.generate();
  const userBetKp = Keypair.generate();
  const predVaultKp = Keypair.generate();

  console.log("\n--- Create Prediction Market ---");
  try {
    const sig3 = await sdk.prediction.createPrediction(
      {
        market: marketKp.publicKey,
        creator: payer.publicKey,
      },
      {
        tokenA: mintKp.publicKey,
        tokenB: Keypair.generate().publicKey,
        deadline: BigInt(Math.floor(Date.now() / 1000) + 86400), // +24h
        marketIndex: 1n,
      },
    );
    console.log("createPrediction tx:", sig3);
  } catch (e) {
    console.error("createPrediction failed:", (e as Error).message);
  }

  console.log("\n--- Place Bet ---");
  try {
    const sig4 = await sdk.prediction.placeBet(
      {
        market: marketKp.publicKey,
        userBet: userBetKp.publicKey,
        user: payer.publicKey,
        vault: predVaultKp.publicKey,
      },
      {
        side: 0,                        // bet on token A
        amount: 100_000_000n,           // 0.1 SOL
      },
    );
    console.log("placeBet tx:", sig4);
  } catch (e) {
    console.error("placeBet failed:", (e as Error).message);
  }

  console.log("\nDone! All module clients available on sdk.*");
  console.log("Available modules:", [
    "achievements", "airdrops", "analytics", "bridge", "contentClaims",
    "copyTrading", "creatorDashboard", "customPages", "dailyRewards",
    "embeddableWidgets", "feeSplitting", "fundTokens", "holderRewards",
    "lending", "limitOrders", "liveChat", "staking", "perps",
    "pointsSystem", "prediction", "premium", "priceAlerts", "raffle",
    "referral", "reputation", "seasons", "shareCards", "socialLaunch",
    "stablePairs", "tokenChat", "tokenVideos", "voting",
  ].join(", "));
}

main().catch(console.error);
