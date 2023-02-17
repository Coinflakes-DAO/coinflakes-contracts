// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IFlaixOption is IERC20Metadata {
  /// @notice Emitted when this option contract is issued.
  event Issue(address indexed recipient, uint256 amount, uint maturityTimestamp);

  /// @notice Emitted when this option contract is exercised.
  event Exercise(address indexed recipient, uint256 amount, uint256 assetAmount);

  /// @notice Emitted when this option contract is revoked.
  event Revoke(address indexed recipient, uint256 amount);

  /// @notice Returns the address of the vault that issued the options.
  function vault() external view returns (address);

  /// @notice Returns the timestamp when the options mature.
  function maturityTimestamp() external view returns (uint);

  /// @notice Returns the address of the underlying asset.
  function asset() external view returns (address);

  
  function exercise(address recipient, uint256 amount) external;

  /// @notice Returns the amount of underlying assets for the given amount of
  ///         options.
  function convertToAssets(uint256 amount) external view returns (uint256);

  /// @notice Revoke the given amount of options and transfers the result to
  ///         the recipient.
  function revoke(address recipient, uint256 amount) external;
}
