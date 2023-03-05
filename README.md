[![Unit Tests](https://github.com/Coinflakes-DAO/coinflakes-contracts/actions/workflows/test.yml/badge.svg)](https://github.com/Coinflakes-DAO/coinflakes-contracts/actions/workflows/test.yml)
[![Slither Analysis](https://github.com/Coinflakes-DAO/coinflakes-contracts/actions/workflows/slither.yml/badge.svg)](https://github.com/Coinflakes-DAO/coinflakes-contracts/actions/workflows/slither.yml)

# Coinflakes DAO

## ~ Smart contracts repository ~

### Project Summary

This repository contains the source code for the Coinflakes DAO smart contracts.

Coinflakes DAO is a decentralized and self-innovating investment fund for crypto projects in the most promising areas of the sector.

The DAO is meant to maintain different funds and strategies, each of which is based on a different sector of the crypto industry. But for starters, we are launching the FLAIX fund, which is based on the AI sector.

### Project Structure

The project is based on [Foundry](https://github.com/foundry-rs/foundry), a framework for building and deploying smart contracts on the Ethereum blockchain.

- [src](src) - smart contracts.
  - [flaix](src/flaix) - smart contracts for the AI investment fund (FLAIX token).
  - [interfaces](src/interfaces) - interfaces for the inclusion in other projects.
  - [utils](src/utils) - utility contracts for testing etc.

### Installation

1. Clone the repository

2. Project setup

```bash
forge install
```

3. Run unit tests:

```bash
forge test
```

4. Run security tests:

Install _slither_: [see here](https://github.com/crytic/slither#how-to-install)

```bash
slither .
```

### Project Deployments

#### Sepolia

The project is deployed on the Sepolia testnet. The addresses of the deployed contracts are:

FlaixVault: `0xBf24F7580c99Aae5A4872639E97C1083Fee70AD7`

To get access to the admin functions of the contract, you can use the test governance
contract `FlaixTestGov` but you need to be added to the list of authorized testers first. If you want to be added, please do not hesitate to contact us on Discord (see below). The address of the test governance contract is:

FlaixTestGov: `0x643470b7a90D6aCF8f6A2fB3aA2C315Ae749Dfb4`

There is an ERC20 token implementation deployed on the Sepolia testnet, which can be used as an underlying asset for testing. The address of the deployed token is:

MockERC20: `0x15EdA4f507F0A942184A5b57E2077DCAc927dCF1`

`mint()` and `burn()` functions can be used without permission to mint/burn tokens
for/from any address.

All contracts are verified by Etherscan:

[FlaixVault on Etherscan](https://sepolia.etherscan.io/address/0xBf24F7580c99Aae5A4872639E97C1083Fee70AD7)

[FlaixTestGov on Etherscan](https://sepolia.etherscan.io/address/0x643470b7a90D6aCF8f6A2fB3aA2C315Ae749Dfb4)

[MockERC20 on Etherscan](https://sepolia.etherscan.io/address/0x15EdA4f507F0A942184A5b57E2077DCAc927dCF1)

### Project Status

:red_circle: **Important note:** :red_circle:

The project is still in its team building and seed funding phase. There is no investment fund yet, and the smart contracts are not deployed on the Ethereum blockchain. The project is not ready for production use.

### Getting involved

Join the Discord and give be a DM (NedAlbo):
[Discord](https://discord.gg/zWsC6tSpAN)

### License

[2023 - MIT License](LICENSE)
