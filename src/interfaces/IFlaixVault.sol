// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IFlaixVault is IERC20 {
  /// @notice Burn the given amount of tokens from the sender of the transaction.
  function burn(uint256 amount) external;
}
