import { Connection, Keypair } from '@solana/web3.js';
import { FiveSDK } from '@5ive-tech/sdk';
import fs from 'fs';
import path from 'path';

const conn = new Connection('https://api.devnet.solana.com', 'finalized');
const deployer = Keypair.fromSecretKey(Uint8Array.from(JSON.parse(fs.readFileSync('deployer.json', 'utf8'))));

// Only remaining modules
const remaining = ['social_launch', 'stable_pairs', 'token_chat', 'token_videos', 'voting'];

console.log(`Deployer: ${deployer.publicKey.toBase58()}`);
const bal = await conn.getBalance(deployer.publicKey);
console.log(`Balance: ${bal / 1e9} SOL`);
console.log(`Remaining: ${remaining.length}\n`);

for (const name of remaining) {
  const file = `build/${name}.five`;
  if (!fs.existsSync(file)) { console.log(`❌ ${name} — no artifact`); continue; }
  const bytecode = fs.readFileSync(file);
  console.log(`--- ${name} (${bytecode.length} bytes) ---`);
  try {
    const result = await FiveSDK.deployLargeProgramToSolana(bytecode, conn, deployer, {
      network: 'devnet', debug: false, maxRetries: 5, chunkSize: 50000,
    });
    console.log(`✅ ${name}`);
  } catch (e) {
    console.log(`❌ ${name} | ${e.message}`);
  }
  await new Promise(r => setTimeout(r, 3000));
}

const finalBal = await conn.getBalance(deployer.publicKey);
console.log(`\nFinal balance: ${finalBal / 1e9} SOL`);
