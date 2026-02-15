# 5IVE VM Project

A basic project built with 5IVE VM.

## Getting Started

### Prerequisites

- Node.js 18+
- 5IVE CLI: `npm install -g @5ive-tech/cli`

### Building

```bash
# Compile the project
npm run build

# Compile with optimizations
npm run build:release

# Compile with debug information
npm run build:debug
```

### Testing

#### Discover and Run Tests

5IVE CLI discovers test functions from your `tests/*.v` files using `pub test_*`:

```bash
# Run all tests
npm test

# Run with watch mode for continuous testing
5ive test --watch

# Run specific tests by filter
5ive test --filter "test_add"

# Run with verbose output
5ive test --verbose

# Run with JSON output for CI/CD
5ive test --format json

# Run on-chain tests (local/devnet/mainnet)
5ive test --on-chain --target local
5ive test --on-chain --target devnet
5ive test --on-chain --target mainnet --allow-mainnet-tests --max-cost-sol 0.5
```

#### Writing Tests

Test functions in your `.v` files use the `pub test_*` naming convention and include `@test-params` comments:

```v
// @test-params 10 20 30
pub test_add(a: u64, b: u64) -> u64 {
    return a + b;
}

// @test-params 5 2 10
pub test_multiply(a: u64, b: u64) -> u64 {
    return a * b;
}
```

The `@test-params` comment specifies inputs. For non-void functions the last value is treated as expected result. The test runner will:
1. Discover test functions automatically
2. Compile the source file
3. Execute with the specified parameters
4. Validate the result matches

For stateful on-chain tests, use companion fixture files (e.g. `tests/main.test.json`) to define per-test accounts/parameters.

### Node Client

Use the generated Node starter under `client/main.ts` for devnet/mainnet execution:

```bash
# Build contract artifact first
npm run build

# Build and run on-chain client
npm run client:build
npm run client:run
```

The starter is self-contained (default devnet RPC, generated script-account file, payer auto-loading) and prints signature, `meta.err`, and CU.

### Development

```bash
# Watch for changes and auto-compile
npm run watch
```

### Deployment

```bash
# Deploy to devnet
npm run deploy
```

## Project Structure

- `src/` - 5IVE VM source files (.v)
- `tests/` - Test files (.v files with test_* functions)
- `client/` - Node TypeScript client starter (FiveProgram + ABI)
- `build/` - Compiled bytecode
- `docs/` - Documentation
- `five.toml` - Project configuration

## Multi-File Projects

If your project uses multiple modules with `use` or `import` statements, 5IVE CLI automatically handles:

```bash
# Automatic discovery of imported modules
5ive compile src/main.v --auto-discover

# Or use the build command which respects five.toml configuration
5ive build
```

## Cross-Module Composition Layer

The `src/composer.v` module provides a composition layer that orchestrates interactions between Send.it's 31 independent modules. Since 5IVE modules compile independently, the composer uses a **bridge pattern** — it mirrors external account layouts for read access and maintains its own `UserComposerState` to track pending cross-module effects.

### Compositions Implemented

| Composition | Description |
|---|---|
| **Staking ↔ Reputation** | Staking amounts boost reputation score (capped at +25); reputation tier gates staking access |
| **Points ↔ Achievements** | Achievement badges grant point multipliers; point levels unlock new achievement badges |
| **Lending ↔ Staking** | Staked positions count as lending collateral (configurable ratio); lending interest partially routes to staking rewards |
| **Referral ↔ Points** | Referral activity earns points; point milestones unlock referral bonuses |
| **Reputation ↔ Prediction** | Reputation score gates prediction market creation; winning bets boost reputation |
| **Fee Splitting ↔ Holder Rewards** | Protocol fees are partially routed to holder reward pools |

### Architecture

- **`ComposerConfig`** — global config with tunable parameters for all composition ratios
- **`UserComposerState`** — per-user state tracking pending cross-module effects
- Pure view functions (`calc_*`, `check_*`) for off-chain queries
- Recording functions (`record_*`) for on-chain state updates consumed by oracles/cranks

### Compile

```bash
npx 5ive compile src/composer.v
npx 5ive compile tests/composer.test.v
```

## Learn More

- [5IVE VM Documentation](https://five-vm.dev)
- [5IVE VM GitHub](https://github.com/five-vm)
- [Multi-File Compilation Guide](./docs/multi-file.md)
- [Examples](./examples)

## License

MIT
