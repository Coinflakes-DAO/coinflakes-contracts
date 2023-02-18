// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "../interfaces/IFlaixVault.sol";
import "../interfaces/IFlaixOption.sol";

/// @title FlaixPutOption Contract
/// @author Ned Albo
/// @notice Contract for FlaixPutOptions. Put options are used to sell an
///         underlying asset on behalf of the vault. If put options are
///         issued, the issuer transfers a certain amount of shares
///         to the options contract and the vault transfers a certain amount of
///         the underlying asset. After that, the options
///         contract holds both the shares and the underlying assets until the option
///         matures. If on maturity, an option is exercised the options owner
///         burns the amount of options and receives the underlying assets pro rata to his
///         burnt share of options. During the same operation, the vault burns an amount
///         of shares equal to the amount of options exercised. If instead the option owner
///         decides to revoke the options, she receives an equal amount of shares to
///         the amount of options revoked and the vault receives the underlying assets from
///         the options contract pro rata to the amount of options revoked. Revoking options
///         is meant as a reverse operation to exercising options.
contract FlaixPutOption is ERC20, IFlaixOption {
  using SafeERC20 for IERC20;
  using Math for uint256;

  /// @notice The address of the vault which issued the options.
  address public immutable vault;

  /// @notice The address of the underlying asset.
  address public immutable asset;

  /// @notice The timestamp at which the options mature.
  uint public immutable maturityTimestamp;

  modifier onlyWhenMatured() {
    require(block.timestamp >= maturityTimestamp, "FlaixPutOption: not matured");
    _;
  }

  /// @param name The name of the options.
  /// @param symbol The symbol of the options.
  /// @param asset_ The address of the underlying asset.
  /// @param minter_ The address of the minter.
  /// @param vault_ The address of the vault.
  /// @param totalSupply_ The total supply of the options.
  /// @param maturityTimestamp_ The timestamp at which the options mature.
  constructor(
    string memory name,
    string memory symbol,
    address asset_,
    address minter_,
    address vault_,
    uint256 totalSupply_,
    uint maturityTimestamp_
  ) ERC20(name, symbol) {
    require(maturityTimestamp_ >= block.timestamp, "FlaixPutOption: maturity in the past");
    maturityTimestamp = maturityTimestamp_;
    asset = asset_;
    vault = vault_;
    _mint(minter_, totalSupply_);
    emit Issue(minter_, totalSupply_, maturityTimestamp_);
  }

  /// @notice Exercise the given amount of options. The options are burnt as well
  ///         as an equal amount of vault shares. The recipient receives the
  ///         underlying assets pro rata to the amount of options exercised.
  /// @param recipient The address of the recipient.
  /// @param amount The amount of options to exercise.
  function exercise(address recipient, uint256 amount) public onlyWhenMatured {
    require(amount <= balanceOf(msg.sender), "FlaixPutOption: insufficient balance");
    _burn(msg.sender, amount);
    IFlaixVault(vault).burn(amount);
    uint256 assetAmount = convertToAssets(amount);
    IERC20(asset).safeTransfer(recipient, assetAmount);
    emit Exercise(recipient, amount, assetAmount);
  }

  /// @notice Returns the amount of underlying assets for the given amount of
  ///         options when exercised.
  function convertToAssets(uint256 amount) public view returns (uint256) {
    uint256 assetBalance = IERC20(asset).balanceOf(address(this));
    return assetBalance.mulDiv(amount, totalSupply());
  }

  function _exercise(address recipient, uint256 amount) internal {}

  /// @notice Revoke the given amount of options. Transfers an equal amount
  ///         of shares to the recipient as the amouunt of options revoked.
  ///         Transfers a pro rata amount of underlying assets from the
  ///         options contract to the vault.
  /// @param recipient The address of the recipient.
  /// @param amount The amount of options to revoke.
  function revoke(address recipient, uint256 amount) public onlyWhenMatured {
    require(amount <= balanceOf(msg.sender), "FlaixPutOption: insufficient balance");
    _burn(msg.sender, amount);
    IERC20(vault).safeTransfer(recipient, amount);
    IERC20(asset).safeTransfer(vault, convertToAssets(amount));
  }
}
