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

### Project Status

:red_circle: **Important note:** :red_circle:

The project is still in its team building and seed funding phase. There is no investment fund yet, and the smart contracts are not deployed on the Ethereum blockchain. The project is not ready for production use.

### Getting involved

Join the Discord and give be a DM (NedAlbo):
[Discord](https://discord.gg/7yddavsV)

### License

[2023 - MIT License](LICENSE)
