# Bug: Chunked deployment fails on devnet — "Script account not found after initialization"

## Summary
`deployLargeProgramToSolana()` in `@5ive-tech/sdk@1.1.10` fails on devnet for any bytecode > 800 bytes. The init transaction confirms, but the subsequent `getAccountInfo()` call returns null because it reads at `confirmed` commitment while the account state hasn't propagated yet.

## Root Cause
In `dist/modules/deploy.js`, the chunked deploy path:

1. **Line ~533**: Sends init TX and confirms with `"confirmed"` commitment ✅
2. **Line ~552**: Immediately calls `connection.getAccountInfo(scriptKeypair.publicKey)` — but uses the connection's default commitment (usually `confirmed`)
3. On devnet, there's a propagation delay between TX confirmation and account visibility
4. The retry logic (line 554-561) only waits 1 second and tries once — not enough for devnet

## The Fix
Two changes needed in `dist/modules/deploy.js`:

### Fix 1: Confirm init TX with `finalized` commitment (line ~535)
```diff
- await connection.confirmTransaction(initSignature, "confirmed");
+ await connection.confirmTransaction(initSignature, "finalized");
```

### Fix 2: Read account with `finalized` commitment (line ~552)
```diff
- let currentInfo = await connection.getAccountInfo(scriptKeypair.publicKey);
+ let currentInfo = await connection.getAccountInfo(scriptKeypair.publicKey, "finalized");
```

And same for the retry reads (line ~559):
```diff
- currentInfo = await connection.getAccountInfo(scriptKeypair.publicKey);
+ currentInfo = await connection.getAccountInfo(scriptKeypair.publicKey, "finalized");
```

### Fix 3 (also recommended): Same issue at line ~639 for final verification
```diff
- const finalInfo = await connection.getAccountInfo(scriptKeypair.publicKey);
+ const finalInfo = await connection.getAccountInfo(scriptKeypair.publicKey, "finalized");
```

## Why this works
Using `finalized` commitment ensures the RPC node won't return stale state. The tradeoff is slightly longer confirmation times (~2-3s vs ~0.5s), but it eliminates the race condition entirely.

## Evidence
- `deployToSolana()` (small program path, single TX) works fine — no account lookup needed between steps
- Custom deploy script using `new Connection(url, 'finalized')` deploys all modules successfully
- Same bytecode, same wallet, same devnet RPC — only difference is commitment level

## Affected versions
- `@5ive-tech/sdk@1.1.10`
- `@5ive-tech/cli@1.0.26`

## Reproduction
```bash
five init test-project && cd test-project
# Write any contract > 800 bytes raw bytecode
five compile src/main.v
five deploy build/main.five --target devnet --keypair wallet.json --debug
# Will show: "Script account not found after initialization"
```

## Workaround
Use the SDK directly with a `finalized` commitment connection:
```js
const conn = new Connection('https://api.devnet.solana.com', 'finalized');
const result = await FiveSDK.deployLargeProgramToSolana(bytecode, conn, deployer, {
  network: 'devnet',
  chunkSize: 50000,
});
```
