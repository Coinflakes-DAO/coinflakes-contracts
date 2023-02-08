// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFlaixBurnable {
  event Burn(address indexed owner, uint256 amount);

  function burn(address owner, uint256 amount) external;
}
