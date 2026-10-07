# Foundry Timelock Vault

A Foundry-based time-locked ETH vault that enforces withdrawal restrictions until a configured lock duration has elapsed. This project demonstrates how to build trustless custody where funds remain inaccessible until a predefined timestamp.

## What the product does
This contract lets users deposit ETH and specify a lock duration. The contract records the deposit amount and calculates an unlock time based on the current block timestamp plus the lock duration. Users can only withdraw their deposit after the unlock time has been reached.

## The problem it solves
Sometimes users need to lock funds for a set period to enforce commitment or prevent accidental transfers. A timelock vault provides transparent, on-chain assurance that funds will remain locked without relying on a custodian. This project models that pattern.

## My specific contribution
I implemented the deposit and withdrawal logic, unlock time verification, and deployment configuration. The focus is on making the timelock logic clear and testable.

## Architecture
The repository includes:

- `src/TimeVault.sol` — time-locked vault logic
- `script/DeployTimeVault.s.sol` — deployment script
- `test/TimeVaultTest.t.sol` — timelock enforcement tests
- `lib/` — Foundry dependencies
- `foundry.toml` — Foundry configuration

## Technologies
- Solidity
- Foundry
- Forge testing
- Time-based access control
- Vault and escrow patterns

## Important technical decisions
- Deposits are stored in a mapping with a struct that includes the amount and unlock time.
- Withdrawal is only permitted after block.timestamp reaches or exceeds the unlock time.
- The contract prevents multiple active deposits per address to avoid confusion about which deposit is locked.
- Custom errors make invalid deposit and withdrawal states explicit and testable.
- The design is intentionally minimal to keep focus on timelock enforcement.

## Key features
- Time-locked ETH deposit and withdrawal
- User-specified lock duration
- Unlock time verification before withdrawals
- Protection against duplicate active deposits
- Event-driven auditing of deposits and withdrawals
- Clear error states for invalid operations

## Screenshots
No screenshots are included.

## Live demo
No live deployment is included in the repository.

## Challenges and solutions
The main challenge is preventing users from withdrawing too early. This is solved by comparing the current block timestamp against the stored unlock time and reverting if the lock period has not yet elapsed.

Another challenge is handling edge cases like zero-amount deposits. The solution is explicit validation at deposit time.

## Setup instructions
```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Clone
git clone https://github.com/Hayotunday/foundry-timelock-vault.git
cd foundry-timelock-vault

# Install dependencies
forge install

# Build
forge build

# Run tests
forge test

# Optional
forge fmt
forge snapshot
```
