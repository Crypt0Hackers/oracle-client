# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A mock Chainlink-compatible oracle system with two components:
1. **Solidity contracts** (Foundry) — `MockOracle.sol` implements `IAggregatorV3`
2. **Go HTTP API server** — reads/writes to the oracle, with Redis caching and Postgres persistence

## Commands

### Solidity / Foundry

```bash
# Install Chainlink npm dependency (required before forge build)
yarn install

# Build contracts
forge build

# Run all tests
forge test

# Run a single test
forge test --match-test testOnlyOwnerCanUpdate

# Run tests with verbosity
forge test -vvvv

# Deploy to local anvil
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast
```

### Go Server

```bash
cd go-client

# Run server
go run cmd/server/main.go

# Build binary
go build ./cmd/server

# Run all Go tests
go test ./...

# Run tests for a specific package
go test ./internal/retry/...
```

### Docker (full stack)

```bash
docker-compose up -d     # Start API + Redis + Postgres
docker-compose logs -f   # Tail logs
docker-compose down      # Stop
```

## Architecture

### Data Access Pattern

Every read request follows this fallback chain:

```
Redis Cache (10s TTL) → Postgres DB → Ethereum RPC (with exponential backoff retry)
```

On a successful RPC fetch, the result is written to both Redis and Postgres. On a write (`/updatePrice`), the `latest` Redis key is invalidated.

### Middleware Stack (applied in order)

`CORSMiddleware → LoggingMiddleware → RateLimitMiddleware → AuthMiddleware`

- Auth requires `Authorization: Bearer <API_KEY>` header on all endpoints except `/health`.
- Rate limiter is in-memory (10 req/min per IP) — not suitable for multi-instance deployments.

### Contract Bindings

The Go file `go-client/internal/contracts/mock_oracle.go` contains auto-generated `abigen` bindings for `MockOracle.sol`. If the contract ABI changes, regenerate this file with:

```bash
abigen --abi <abi-file> --pkg contracts --type MockOracle --out go-client/internal/contracts/mock_oracle.go
```

### Key Go Packages

- `go-client/internal/reader` — read-only contract calls via go-ethereum `bind.CallOpts`
- `go-client/internal/updater` — write transactions (signs with ECDSA private key, fetches chain ID at startup)
- `go-client/internal/retry` — exponential backoff: 3 attempts, 100ms base, 2x multiplier, 5s cap
- `go-client/internal/db` — GORM-based Postgres, auto-migrates `OracleRound` table on startup
- `go-client/internal/cache` — Redis client wrapper (separate package from `go-client/internal/`)
- `go-client/api` — HTTP handlers and middleware (standard library `net/http`, no framework)
- `go-client/config` — loads from `.env` file (searches `.`, `../`, `../../`) then env vars; `PRIVATE_KEY` and `CONTRACT_ADDRESS` are required

### Contract Details

- `MockOracle` initializes with round 1 at `$2000` (200000000000 with 8 decimals)
- Only the deployer (`owner`) can call `updateAnswer`
- `DataConsumerV3.sol` is an example consumer showing how to read from the oracle

### Foundry Note

`foundry.toml` remaps `@chainlink/contracts/` to `node_modules/@chainlink/contracts/`. Run `yarn install` at the repo root before `forge build`.

### Deployment Tracking

After deploying, update `deployments/anvil.json` with the actual contract address, deployer, and transaction hash.
