# MaveriX Oracle

A full-stack DeFi dApp built on Ethereum. Combines a Chainlink-powered price oracle with an on-chain lending protocol and a real-time Next.js dashboard.

---

## What It Does

- Reads live ETH/USD, BTC/USD, and LINK/USD prices from Chainlink feeds on-chain
- Compares oracle prices against CoinGecko market data and surfaces deviations
- Lets users deposit WETH as collateral and borrow MXT (a synthetic dollar) against it
- Tracks health factors, liquidation risk, accrued interest, and round history in real time
- Works with or without MetaMask — falls back to a public RPC for read-only data

---

## Smart Contracts (Sepolia)

| Contract | Address |
|---|---|
| PriceOracle | `0x2cFeEfdF5bbDfe530b81Fbe6caf20b17f7C4D942` |
| MXT (synthetic dollar) | `0x8Bd57b99016249c0C5d32030ab2ee370348003AD` |
| LendingPool | `0x01baa4911c9c9D5b8bBF231508156E78dF7dAD68` |

### Protocol Parameters

| Parameter | Value |
|---|---|
| Max LTV (Collateral Factor) | 75% |
| Liquidation Threshold | 80% |
| Liquidation Bonus | 10% |
| Interest Rate | 5% APR (per-second accrual) |

---

## Stack

**Contracts**
- Solidity ^0.8.24
- OpenZeppelin (ERC20Burnable, AccessControl, ReentrancyGuard, SafeERC20)
- Foundry (forge build, forge test, forge script)

**Frontend**
- Next.js 15 (App Router)
- ethers.js v6
- Tailwind CSS v4
- Framer Motion
- Recharts

---

## Project Structure

```
MaveriX-Oracle/
├── src/
│   ├── PriceOracle.sol      # Chainlink aggregator wrapper
│   ├── MXT.sol              # Synthetic dollar (ERC20 + MINTER_ROLE)
│   └── LendingPool.sol      # Deposit / borrow / repay / liquidate
├── test/
│   └── LendingPool.t.sol    # Full Foundry test suite
├── script/
│   └── DeployLending.s.sol  # Sepolia deployment script
├── dashboard/               # Next.js frontend
│   ├── src/app/
│   │   ├── page.tsx         # Main dashboard layout
│   │   ├── hooks/           # useOracle, useAlerts
│   │   └── Context/         # Web3Provider, ToastProvider
│   └── components/          # UI panels (see below)
└── foundry.toml
```

### Dashboard Components

| Component | Purpose |
|---|---|
| `MultiFeedGrid` | Live ETH/BTC/LINK prices with deviation vs market |
| `OracleHealthPanel` | Deviation score, health bar, last update time |
| `StatsPanel` | 24H high/low, volume, 7D change, market cap |
| `PriceChart` | Historical ETH/USD price chart |
| `DeviationChart` | Oracle vs market deviation over time |
| `LendingPanel` | Deposit, borrow, repay, liquidation UI |
| `SwapPanel` | Token swap interface (uses oracle pricing) |
| `YieldPanel` | Protocol yield rates |
| `RoundExplorer` | Browse historical Chainlink rounds |
| `PriceAlerts` | Set price alert thresholds |
| `EventLog` | Live on-chain event feed |
| `WalletPanel` | Connected wallet, balance, network |
| `NetworkMonitor` | Block number, base fee, chain info |

---

## Running Locally

### Contracts

```bash
# Install dependencies
forge install

# Build
forge build

# Test
forge test -v
```

### Frontend

```bash
cd dashboard
pnpm install
pnpm dev
```

Open [http://localhost:3000](http://localhost:3000).

Connect MetaMask on Sepolia, or just load the page — it will read chain data via a public fallback RPC.

---

## Deploying Contracts

```bash
PRIVATE_KEY=0x... forge script script/DeployLending.s.sol \
  --rpc-url https://ethereum-sepolia-rpc.publicnode.com \
  --broadcast
```

After deployment, update the addresses in:
- `dashboard/components/LendingPanel.tsx` — `LENDING_POOL_ADDRESS`, `MXT_ADDRESS`
- `dashboard/src/app/Constants/oracle.ts` — `oracleAddress` under chain `11155111`

---

## Contributing

This dashboard is a contribution to [Crypt0Hackers/oracle-client](https://github.com/Crypt0Hackers/oracle-client). The smart contracts and frontend were built by El-Mavericko.
