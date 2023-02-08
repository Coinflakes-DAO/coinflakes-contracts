// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IFlaixMintable.sol";
import "./IFlaixBurnable.sol";

interface IFlaixVault is IFlaixMintable, IFlaixBurnable {
  function treasury() external view returns (address);

  function voteToken() external view returns (address);

  function voteEmissionsBegin() external view returns (uint256);

  function mintVotes(address recipient, uint256 amount) external;

  function burnVotes(address owner, uint256 amount) external;
}
