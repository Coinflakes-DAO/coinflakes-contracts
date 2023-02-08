// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/IAccessControl.sol";

import "../interfaces/IFlaixMintable.sol";
import "../interfaces/IFlaixBurnable.sol";

contract FlaixVotes is ERC20, IFlaixMintable, IFlaixBurnable {
  address public vault;

  bytes32 public constant MINT_VOTES_ROLE = keccak256("MINT_VOTES_ROLE");
  bytes32 public constant BURN_VOTES_ROLE = keccak256("BURN_VOTES_ROLE");

  modifier onlyAllowed() {
    require(IAccessControl(vault).hasRole(MINT_VOTES_ROLE, msg.sender), "FlaixVotes: votes minting/burning denied");
    _;
  }

  constructor(address vault_) ERC20("Coinflakes AI Vault Votes", "vFLAIX") {
    vault = vault_;
  }

  function mint(address recipient, uint256 amount) external onlyAllowed {
    _mint(recipient, amount);
    emit Mint(recipient, amount);
  }

  function burn(address owner, uint256 amount) external onlyAllowed {
    _burn(owner, amount);
    emit Burn(owner, amount);
  }
}
