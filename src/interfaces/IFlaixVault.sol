// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IFlaixVault is IERC20 {
  /// @notice Error code for when a function is restricted for the admin.
  error OnlyAllowedForAdmin();

  /// @notice Error code for when the maturity is changed below the hard coded limit.
  error MaturityChangeBelowLimit();

  /// @notice Error code for when an option is issued with a maturity below the current minimum.
  error MaturityTooLow();

  /// @notice Error code for when an asset is already on the allow list.
  error AssetAlreadyOnAllowList();

  /// @notice Error code for when an asset is not on the allow list.
  error AssetNotOnAllowList();

  /// @notice Error code for when an asset is not on the allow list.
  error AssetCannotBeNull();

  /// @notice Error code for when index is after last asset in allow list.
  error AssetIndexOutOfBounds();

  /// @notice Error code for when an recipient is null.
  error RecipientCannotBeNullAddress();

  /// @notice Emitted when admin account is changed.
  event AdminChanged(address newAdmin, address oldAdmin);

  /// @notice Emitted when an asset is added to the allow list.
  event AssetAllowed(address asset);

  /// @notice Emitted when an asset is added to the allow list.
  event AssetDisallowed(address asset);

  event IssueCallOptions(
    address indexed options,
    address indexed recipient,
    string name,
    string symbol,
    uint256 amount,
    address indexed asset,
    uint256 assetAmount,
    uint256 maturity
  );

  /// @notice Burn the given amount of tokens from the sender of the transaction.
  function burn(uint256 amount) external;
}
