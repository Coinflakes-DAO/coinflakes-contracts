// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IFlaixVault is IERC20 {
  /// @notice Error code for when the maturity is changed below the hard coded limit.
  error MinimalOptionsMaturityBelowLimit(uint limit);

  /// @notice Error code for when an option is issued with a maturity below the current minimum.
  error OptionsMaturityTooLow();

  /// @notice Error code for when an asset is not on the allow list.
  error AssetNotOnAllowList();

  /// @notice Burn the given amount of tokens from the sender of the transaction.
  function burn(uint256 amount) external;
}
