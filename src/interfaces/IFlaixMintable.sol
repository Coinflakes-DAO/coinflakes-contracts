// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFlaixMintable {
  event Mint(address indexed recipient, uint256 amount);

  function mint(address recipient, uint256 amount) external;
}
