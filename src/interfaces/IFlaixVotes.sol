// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFlaixVotes {
  function vault() external view returns (address);

  function mint(address recipient, uint256 amount) external;

  function burn(address owner, uint256 amount) external;
}
