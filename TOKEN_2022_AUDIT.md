# Token-2022 Extension Compatibility Audit

**Protocol:** Send.it (5IVE DSL modules)  
**Token:** SENDIT (`F8qWTN8JfyDCvj4RoCHuvNMVbTV9XQksLuziA8PYpump`)  
**Token Standard:** SPL Token-2022 (pump.fun launch)  
**Date:** 2026-02-15  
**Auditor:** Automated security audit  
**Severity:** MAINNET-CRITICAL

---

## Executive Summary

**Overall Risk: LOW** (with one critical fix needed in airdrops.v)

SENDIT is a pump.fun token. Pump.fun tokens are minted via Token-2022 but with **no extensions enabled** — no transfer fees, no transfer hooks, no freeze authority, no mint close authority, no permanent delegate, no CPI guard, no confidential transfers. They are effectively vanilla tokens on the Token-2022 program.

However, the audit identified **1 CRITICAL issue** (wrong program ID) and several **WARN-level** defensive coding concerns.

---

## Pump.fun Token Extension Profile

Pump.fun tokens on Token-2022 typically have:

| Extension | Enabled? | Impact |
|-----------|----------|--------|
| Transfer Fees | ❌ No | No impact |
| Mint Close Authority | ❌ No | No impact |
| Permanent Delegate | ❌ No | No impact |
| Non-Transferable | ❌ No | No impact |
| Confidential Transfers | ❌ No | No impact |
| Transfer Hook | ❌ No | No impact |
| Metadata | ✅ Yes (via Metaplex) | Safe — read-only |
| Default Account State | ❌ No (initialized, not frozen) | No impact |
| Interest-Bearing | ❌ No | No impact |
| CPI Guard | ❌ No (per-account, user-opt-in) | See notes |

**Key insight:** Since SENDIT has NO extensions beyond metadata, the protocol's use of basic `spl_transfer` (Transfer instruction, discriminator 3) is **functionally correct** for this specific token. Transfer amounts are exact — no fee deductions, no hooks, no guards on vault accounts.

---

## CPI Interface Analysis

All modules (except airdrops.v) declare:
```
interface Token2022 @program("TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb") {
    @discriminator(3)
    spl_transfer(from, to, authority, amount);
}
```

This invokes the **Transfer** instruction (index 3) on the Token-2022 program. For tokens WITHOUT transfer fee extensions, this works identically to `TransferChecked` minus the decimal/mint validation. Since SENDIT has no transfer fees, the amount sent equals the amount received.

### Original Anchor Source Comparison

The Anchor staking module (`staking.rs`) uses `anchor_spl::token::Token` — the **old SPL Token program**, not Token-2022. This means:
- The Anchor source was written for SPL Token, not Token-2022
- The 5IVE port correctly upgraded to Token-2022 program ID
- However, the Anchor source's use of basic `token::transfer` (not `transfer_checked`) carries over

---

## Per-Module Audit

### 1. main.v (Staking) — ⚠️ WARN

**Token operations:** 3 (`stake_tokens`, `unstake_tokens`, `claim_staking_rewards`)

| Check | Status | Notes |
|-------|--------|-------|
| Correct program ID | ✅ PASS | Token-2022 program |
| Transfer fee handling | ✅ PASS | SENDIT has none |
| CPI Guard | ⚠️ WARN | If a user enables CPI Guard on their token account, vault→user transfers via CPI would fail |
| Amount accounting | ✅ PASS | `amount` sent == `amount` received for this token |
| Uses TransferChecked | ❌ No | Uses basic Transfer — works but less safe |

**Verdict: WARN** — Functional for SENDIT. Would break if token ever adds transfer fees (impossible for pump.fun tokens — extensions are immutable at mint). CPI Guard is user-opt-in risk only.

---

### 2. perps.v (Perpetual Futures) — ⚠️ WARN

**Token operations:** 3 (`deposit_collateral`, `withdraw_collateral`, `deposit_insurance`)

| Check | Status | Notes |
|-------|--------|-------|
| Correct program ID | ✅ PASS | Token-2022 program |
| Transfer fee handling | ✅ PASS | SENDIT has none |
| CPI Guard | ⚠️ WARN | vault→user withdrawal could fail if user has CPI Guard |
| Amount accounting | ✅ PASS | Collateral tracking matches transfer amounts exactly |

**Verdict: WARN** — Same CPI Guard concern. Collateral math is sound for fee-less tokens.

---

### 3. lending.v (Lending) — ⚠️ WARN

**Token operations:** 2 (`borrow_against_tokens` — collateral lock, `liquidate` — collateral seizure)

| Check | Status | Notes |
|-------|--------|-------|
| Correct program ID | ✅ PASS | Token-2022 program |
| Transfer fee handling | ✅ PASS | SENDIT has none |
| CPI Guard | ⚠️ WARN | Liquidation transfers to liquidator — CPI Guard could block |
| LTV calculations | ✅ PASS | Collateral amounts match transferred amounts |

**Verdict: WARN** — Liquidation could fail if liquidator has CPI Guard enabled (unlikely for a liquidation bot). SOL deposits/withdrawals don't use token transfers.

---

### 4. bridge.v (Cross-Chain Bridge) — ⚠️ WARN

**Token operations:** 3 (`initiate_bridge` — 2 transfers: net + fee, `cancel_bridge` — refund)

| Check | Status | Notes |
|-------|--------|-------|
| Correct program ID | ✅ PASS | Token-2022 program |
| Transfer fee handling | ✅ PASS | SENDIT has none |
| Fee calculation | ✅ PASS | `net_amount = amount - fee_amount`, both transferred separately |
| CPI Guard | ⚠️ WARN | Refund transfer could fail |

**Verdict: WARN** — Bridge fee math is clean. Two separate transfers (net to vault, fee to fee_vault) from user account — correct.

---

### 5. raffle.v (Raffle) — ⚠️ WARN

**Token operations:** 1 (`claim_raffle_prize`)

| Check | Status | Notes |
|-------|--------|-------|
| Correct program ID | ✅ PASS | Token-2022 program |
| Transfer fee handling | ✅ PASS | SENDIT has none |
| Prize amount | ✅ PASS | `tokens_per_winner` is pre-calculated, vault→claimer |
| CPI Guard | ⚠️ WARN | Prize claim fails if winner has CPI Guard |

**Verdict: WARN** — Prize distribution is vault→user only. Low risk.

---

### 6. stable_pairs.v (AMM Swaps) — ⚠️ WARN

**Token operations:** 6 (swap in/out × 2 directions, add/remove liquidity × 2 tokens each)

| Check | Status | Notes |
|-------|--------|-------|
| Correct program ID | ✅ PASS | Token-2022 program |
| Transfer fee handling | ✅ PASS | SENDIT has none |
| Reserve accounting | ✅ PASS | Reserves updated by exact transfer amounts |
| Constant product math | ✅ PASS | `amount_out` calculated before transfer, no fee discrepancy |
| CPI Guard | ⚠️ WARN | Vault→user transfers in swaps/withdrawals |

**Verdict: WARN** — Most complex token module. All reserve tracking matches transfer amounts. Would be severely broken with transfer fees (reserve tracking would drift), but SENDIT has none.

---

### 7. airdrops.v — 🔴 FAIL

**Token operations:** 3 (`create_airdrop`, `claim_airdrop`, `cancel_airdrop`)

| Check | Status | Notes |
|-------|--------|-------|
| **Correct program ID** | **🔴 FAIL** | Uses `TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA` (OLD SPL Token program!) |
| Transfer fee handling | ✅ PASS | N/A if program ID is fixed |
| CPI Guard | ⚠️ WARN | vault→claimant transfers |

**CRITICAL: airdrops.v uses the WRONG program ID.** It references the legacy SPL Token program, NOT Token-2022. All CPI calls in this module will fail at runtime because SENDIT token accounts are owned by Token-2022, not SPL Token.

**Fix required:**
```diff
- interface TokenProgram @program("TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA") {
+ interface Token2022 @program("TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb") {
```
And update all `TokenProgram.spl_transfer` → `Token2022.spl_transfer`.

---

### 8. holder_rewards.v — ✅ PASS

**Token operations:** 0 (no direct token transfers — returns claimable amount, actual transfer done externally)

**Verdict: PASS** — Pure accounting module. `claim_holder_rewards` returns a u64 amount; no CPI transfers.

---

### 9. fee_splitting.v — ✅ PASS

**Token operations:** 0 (accounting only — `distribute_fees` updates allocations, `claim_split_fees` returns amount)

**Verdict: PASS** — Pure accounting. No token CPIs.

---

### 10. daily_rewards.v — ✅ PASS

**Token operations:** 0 (points system only, no token transfers)

**Verdict: PASS** — Points/streak tracking. No tokens touched.

---

### 11. fund_tokens.v — ✅ PASS

**Token operations:** 0 (SOL deposits tracked, no token CPI — "tracking only" as noted in comments)

**Verdict: PASS** — Deposit/redeem are tracking only. No Token-2022 interaction despite declaring the interface.

---

## Summary Table

| Module | Status | Token Ops | Critical Issues |
|--------|--------|-----------|-----------------|
| main.v (staking) | ⚠️ WARN | 3 | CPI Guard edge case |
| perps.v | ⚠️ WARN | 3 | CPI Guard edge case |
| lending.v | ⚠️ WARN | 2 | CPI Guard edge case |
| bridge.v | ⚠️ WARN | 3 | CPI Guard edge case |
| raffle.v | ⚠️ WARN | 1 | CPI Guard edge case |
| stable_pairs.v | ⚠️ WARN | 6 | CPI Guard edge case |
| **airdrops.v** | **🔴 FAIL** | **3** | **Wrong program ID — all transfers will fail** |
| holder_rewards.v | ✅ PASS | 0 | None |
| fee_splitting.v | ✅ PASS | 0 | None |
| daily_rewards.v | ✅ PASS | 0 | None |
| fund_tokens.v | ✅ PASS | 0 | None |

---

## Recommended Fixes

### CRITICAL (Must fix before mainnet)

1. **airdrops.v — Wrong program ID**
   - Change `TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA` → `TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb`
   - Change all `TokenProgram.spl_transfer` → `Token2022.spl_transfer`

### ADVISORY (Best practices, not blocking)

2. **CPI Guard documentation** — Document that users who enable CPI Guard on their SENDIT token accounts will be unable to receive tokens from protocol vaults via CPI. This is a user-side opt-in restriction and affects all DeFi protocols, not just Send.it. The frontend should detect and warn.

3. **Consider TransferChecked** — All modules use basic `Transfer` (discriminator 3) instead of `TransferChecked` (discriminator 12). For SENDIT specifically this is fine, but `TransferChecked` provides additional safety by validating the mint and decimals. If the protocol ever supports other Token-2022 tokens, `TransferChecked` should be used.

4. **Future-proofing** — If Send.it ever supports tokens with transfer fees, every module that transfers tokens needs:
   - Pre-transfer balance snapshots to determine actual received amount
   - `TransferChecked` instead of `Transfer`
   - Additional `mint` account passed to the instruction
   - Reserve/collateral tracking based on actual received amounts, not sent amounts

### Anchor Source Notes

The original Anchor staking.rs uses `anchor_spl::token::Token` (legacy SPL Token program). The 5IVE port correctly upgraded to Token-2022, but inherited the basic `Transfer` pattern. This is acceptable for SENDIT.

---

## Extension Immutability Note

Pump.fun tokens have their extensions set at mint creation and **cannot be modified after the fact**. SENDIT cannot retroactively add:
- Transfer fees
- Transfer hooks
- Permanent delegate
- Mint close authority
- Non-transferable flag

This means the current protocol design is **safe for SENDIT specifically**. The WARN statuses are defensive recommendations, not active vulnerabilities.

---

## Conclusion

The Send.it 5IVE protocol is **compatible with SENDIT (Token-2022)** with one critical fix:

1. 🔴 **Fix airdrops.v program ID** — This is a deploy-blocker
2. ⚠️ All other modules work correctly for SENDIT's extension-free Token-2022 profile
3. ✅ Amount accounting is correct across all modules (no transfer fee discrepancy)
4. ✅ The Token-2022 program ID is correctly used in 10/11 modules

**Mainnet readiness after fix: YES**
