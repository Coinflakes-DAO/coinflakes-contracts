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

FlaixVault: [0xBf24F7580c99Aae5A4872639E97C1083Fee70AD7](https://sepolia.etherscan.io/address/0xBf24F7580c99Aae5A4872639E97C1083Fee70AD7)

To get access to the admin functions of the contract, you can use the test governance
contract `FlaixTestGov` but you need to be added to the list of authorized testers first. If you want to be added, please do not hesitate to contact us on Discord (see below). The address of the test governance contract is:

FlaixTestGov: [0x03A3Db793913F8Ae464eDC950556D1A2Af174CAe](https://sepolia.etherscan.io/address/0x03A3Db793913F8Ae464eDC950556D1A2Af174CAe)

There are some ERC20 token implementations deployed on the Sepolia testnet, which can be used as an underlying asset for testing. The addresses of the deployed tokens are:

alphaAI: [0xF6a05F0eE5a6F03094c4445F073d4F3C5A73527C](https://sepolia.etherscan.io/address/0xF6a05F0eE5a6F03094c4445F073d4F3C5A73527C)

betaAI: [0x57330b118Cd86E0Cd826A200aE084a2743042E7E](https://sepolia.etherscan.io/address/0x57330b118Cd86E0Cd826A200aE084a2743042E7E)

gammaAI: [0xdd3a30199A2dA74c0991f3BEc391ACcA24BbF1D9](https://sepolia.etherscan.io/address/0xdd3a30199A2dA74c0991f3BEc391ACcA24BbF1D9)

`mint()` and `burn()` functions can be used without permission to mint/burn tokens
for/from any address.

### Project Status

:red_circle: **Important note:** :red_circle:

The project is still in its team building and seed funding phase. There is no investment fund yet, and the smart contracts are not deployed on the Ethereum blockchain. The project is not ready for production use.

### Getting involved

Join the Discord and give be a DM (NedAlbo):
[Discord](https://discord.gg/zWsC6tSpAN)

### License

[2023 - MIT License](LICENSE)
