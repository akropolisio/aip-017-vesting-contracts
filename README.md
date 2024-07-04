# AIP-017 Vesting Contracts

This repository contains the contracts for [AIP-017 proposal](https://gov.akropolis.io/t/aip-017-akro-a-new-generation-tokenomics-phase-1-and-product-roadmap/624), based on the openzeppelin [VestingWallet](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/finance/VestingWallet.sol) contract.

Run test on the mainnet fork to check unlock amounts:

```shell
forge test --fork-url $MAINNET_RPC -vvv
```

## Foundry Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ source .env
$ forge test --fork-url $MAINNET_RPC -vvv
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ source .env
$ forge script script/DeployAIP_017.s.sol:DeployAIP_017Script --rpc-url $MAINNET_RPC --verify --broadcast -vvv
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
