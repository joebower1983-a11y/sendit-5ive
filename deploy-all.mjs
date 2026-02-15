import { Connection, Keypair } from '@solana/web3.js';
import { FiveSDK } from '@5ive-tech/sdk';
import fs from 'fs';
import path from 'path';

const conn = new Connection('https://api.devnet.solana.com', 'finalized');
const deployer = Keypair.fromSecretKey(Uint8Array.from(JSON.parse(fs.readFileSync('deployer.json', 'utf8'))));

const buildDir = './build';
const files = fs.readdirSync(buildDir).filter(f => f.endsWith('.five') && f !== 'sendit-5ive.five');

console.log(`Deployer: ${deployer.publicKey.toBase58()}`);
const bal = await conn.getBalance(deployer.publicKey);
console.log(`Balance: ${bal / 1e9} SOL`);
console.log(`Modules to deploy: ${files.length}\n`);

const results = [];

for (const file of files) {
  const name = file.replace('.five', '');
  const bytecode = fs.readFileSync(path.join(buildDir, file));
  
  console.log(`--- ${name} (${bytecode.length} bytes) ---`);
  
  try {
    // Use deployToSolana for small, deployLargeProgramToSolana for large
    let result;
    if (bytecode.length <= 800) {
      result = await FiveSDK.deployToSolana(bytecode, conn, deployer, {
        network: 'devnet',
        debug: false,
        maxRetries: 5,
      });
    } else {
      result = await FiveSDK.deployLargeProgramToSolana(bytecode, conn, deployer, {
        network: 'devnet',
        debug: false,
        maxRetries: 5,
        chunkSize: 50000,
      });
    }
    
    const prog = result?.scriptAccount || result?.programId || result?.signature || 'ok';
    console.log(`✅ ${name} | ${prog}`);
    results.push({ name, status: 'ok', id: prog });
  } catch (e) {
    console.log(`❌ ${name} | ${e.message}`);
    results.push({ name, status: 'fail', error: e.message });
  }
  
  await new Promise(r => setTimeout(r, 3000));
}

console.log('\n=== RESULTS ===');
results.forEach(r => {
  console.log(`${r.status === 'ok' ? '✅' : '❌'} ${r.name}${r.id ? ' → ' + r.id : ''} ${r.error || ''}`);
});
console.log(`\n✅ ${results.filter(r => r.status === 'ok').length} / ❌ ${results.filter(r => r.status === 'fail').length}`);

const finalBal = await conn.getBalance(deployer.publicKey);
console.log(`Remaining: ${finalBal / 1e9} SOL`);
