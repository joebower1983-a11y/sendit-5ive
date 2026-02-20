<p align="center">
  <h1 align="center">⚡ Send.it — 5IVE VM Port</h1>
  <p align="center"><strong>31 Solana modules ported from Anchor to 5IVE DSL</strong></p>
  <p align="center">
    <img src="https://img.shields.io/badge/modules-31-00c896" alt="31 modules">
    <img src="https://img.shields.io/badge/5IVE_DSL-6k_lines-blueviolet" alt="6k lines">
    <img src="https://img.shields.io/badge/bytecode-25KB-orange" alt="25KB bytecode">
    <img src="https://img.shields.io/badge/tests-159-brightgreen" alt="159 tests">
    <img src="https://img.shields.io/badge/code_reduction-63%25-blue" alt="63% reduction">
  </p>
</p>

---

## What Is This?

A complete port of [Send.it](https://github.com/joebower1983-a11y/send_it) — 31 on-chain Anchor modules (~16,000 lines of Rust) — to [5IVE DSL](https://5ive.tech), achieving a **63% code reduction** (16k → 6k lines) with 25KB total bytecode.

Send.it is the most feature-rich token launchpad on Solana: bonding curves, Send.Swap AMM, staking, perps, lending, governance, Storacha storage, social features, and more.

| Metric | Anchor | 5IVE |
|--------|--------|------|
| Lines of code | ~16,000 | ~6,000 |
| Bytecode | ~200KB | 25KB |
| Modules | 31 | 31 |
| Tests | 4,300+ | 159 |

---

## Devnet

| | |
|---|---|
| **Anchor Program** | [`HTKq18cATdwCZb6XM66Mhn8JWKCFTrZqH6zU1zip88Zx`](https://solscan.io/account/HTKq18cATdwCZb6XM66Mhn8JWKCFTrZqH6zU1zip88Zx?cluster=devnet) |
| **SENDIT Token** | [`F8qWTN8JfyDCvj4RoCHuvNMVbTV9XQksLuziA8PYpump`](https://pump.fun/coin/F8qWTN8JfyDCvj4RoCHuvNMVbTV9XQksLuziA8PYpump) (Token-2022, pump.fun) |
| **Live App** | [senditsolana.io](https://senditsolana.io) |

---

## Modules

All 31 Send.it modules ported:

**Core:** Bonding curves (linear/exp/sigmoid), Send.Swap AMM, anti-snipe, rug protection, leaderboard, creator dashboard, custom pages, Storacha storage

**DeFi:** Staking, lending, limit orders, perps, bridge, holder rewards, PYUSD vault

**Governance:** Voting, reputation (FairScale), prediction markets

**Social:** Token chat, live chat, token videos, share cards

**Growth:** Achievements, daily rewards, seasons, referral, airdrops, raffle, premium, price alerts

**Creator:** Fee splitting, content claims, embeddable widgets

**Analytics:** On-chain analytics, copy trading

---

## Quick Start

### Prerequisites
- Node.js 18+
- 5IVE CLI: `npm install -g @5ive-tech/cli`

### Build & Test
```bash
npm run build          # Compile
npm test               # Run 159 tests
5ive test --verbose    # Verbose output
```

### Deploy
```bash
5ive deploy --target devnet
```

> **Note:** Use `"finalized"` commitment on Connection for chunked deploys. See [issue #1](https://github.com/joebower1983-a11y/sendit-5ive/issues/1).

---

## Links

| | |
|---|---|
| **Main Repo (Anchor)** | [github.com/joebower1983-a11y/send_it](https://github.com/joebower1983-a11y/send_it) |
| **Live App** | [senditsolana.io](https://senditsolana.io) |
| **Discord** | [discord.gg/vKRTyG85](https://discord.gg/vKRTyG85) |
| **Telegram** | [t.me/+Xw4E2sJ0Z3Q5ZDYx](https://t.me/+Xw4E2sJ0Z3Q5ZDYx) |
| **Twitter** | [@SendItSolana420](https://x.com/SendItSolana420) |

---

## License

MIT — see [LICENSE](LICENSE) for details.

<p align="center"><strong>Built on Solana ⚡ Ported to 5IVE 🔮</strong></p>
