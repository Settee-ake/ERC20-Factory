## ERC20Tokens (Foundry)

**Minimal ERC20 token factory with CREATE2-based deployment.** This project uses Foundry (`forge`, `cast`, `anvil`) and ships a simple `ERC20` implementation, a `MyToken` wrapper, and a `Factory` that deploys tokens using `CREATE2` with a keccak256-derived salt.

### Contracts

- **`src/ERC20.sol`**: Basic ERC20 implementation used by `MyToken`.
- **`src/MyToken.sol`**: Concrete ERC20 whose constructor mints the provided supply to a specified address (the factory passes `msg.sender`).
- **`src/Factory.sol`**: Exposes `deployToken(string _name, string _symbol, uint8 decimals, uint256 _totalSupply)` and deploys `MyToken` via `CREATE2`.

### CREATE2 salt behavior

`Factory.deployToken` computes the `salt` as:

```solidity
keccak256(abi.encode(msg.sender, block.timestamp, _name, _symbol, decimals))
```

- **Implications**:
  - The salt includes `block.timestamp`, so the resulting address is not precomputable off-chain ahead of the transaction. Two calls with the same inputs at different blocks will deploy to different addresses.
  - If you need a fully precomputable, deterministic address, consider refactoring the factory to accept an explicit `bytes32 salt` parameter and remove `block.timestamp` from the salt calculation.

### Supply parameter note

The current factory passes `_totalSupply * decimals` to the token constructor. This multiplies by the numeric value of `decimals` (e.g., 18), not `10**decimals`.

- If you want a supply of `S` tokens with `decimals = 18`, you typically expect `S * 10**18` units. The current implementation instead uses `S * 18` units. Adjust your `_totalSupply` input accordingly or update the contract logic to use `10**decimals`.

### Requirements

- Rust toolchain (for Foundry installation)
- Foundry: `forge`, `cast`, `anvil`

Install Foundry if needed:

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### Build

```bash
forge build
```

### Test

```bash
forge test -vv
```

### Format

```bash
forge fmt
```

### Run a local node

```bash
anvil
```

### Deploy the Factory

If you don’t already have a deployed factory, deploy it with `forge create` or a script. Example with `forge create` (replace RPC URL and key):

```bash
forge create src/Factory.sol:Factory \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY
```

Record the deployed factory address from the output.

### Network: Sonic Mainnet

- **Chain ID**: 146
- **Explorer**: `https://sonicscan.org`
- **Factory (deployed)**: `0x2EA3E93f864a4848098673a8274a20bA40b6D90a`

Example environment setup:

```bash
export RPC_URL=<sonic_mainnet_rpc>
export PRIVATE_KEY=<deployer_private_key>
```

### Deploy a token via the Factory

Use `cast send` to call `deployToken` on the factory:

```bash
cast send 0x2EA3E93f864a4848098673a8274a20bA40b6D90a \
  "deployToken(string,string,uint8,uint256)" \
  "My Token" "MTK" 18 1000000 \
  --chain 146 --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY
```

Notes:

- Due to the salt using `block.timestamp`, the token address cannot be known until the tx is mined. Retrieve it from the transaction logs/return value.
- Adjust `_totalSupply` per the supply note above.

### Reading the deployed token address

`deployToken` returns the new token’s address. With `cast`, you can fetch the return value from the receipt or parse emitted logs if you add events. Example to get the return from a recent tx hash:

```bash
cast receipt <TX_HASH> --rpc-url $RPC_URL | cat
```

### Verifying contracts

If you verify on a block explorer, ensure your compiler settings match `foundry.toml`. For CREATE2 deployments, verification is the same as standard deployments; constructor args are `(name, symbol, decimals, totalSupplyParam, to)` where `to` is the recipient of the initial mint (set to the caller by the factory).

### License

This project is licensed under **AGPL-3.0-only**. See SPDX headers in source files.
