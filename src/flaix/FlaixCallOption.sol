// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "../interfaces/IFlaixOption.sol";
import "../interfaces/IFlaixVault.sol";

/// @title FlaixCallOption Contract
/// @author Ned Albo
/// @notice Contract for FlaixCallOptions. Call options are used to buy an
///         underlying asset on behalf of the vault. If call options are
///         issued, the issuer transfers a certain amount of underlying assets
///         to the options contract and the vault mints a certain amount of
///         shares, transferring them to the options contract. After that, the options
///         contract holds both the shares and the underlying assets until the option
///         matures. If on maturity, an option is exercised the options owner
///         receives the shares and the vault receives the assets corresponding to the
///         optionns owner share of the total supply of the options (pro rata).
///         If instead the option owner decides to revoke the option, the vault
///         burns the shares transfers the pro rata amount of the underlying assets
///         to the option owner.
contract FlaixCallOption is ERC20, IFlaixOption {
  using SafeERC20 for IERC20;
  using Math for uint256;

  address public immutable asset;

  address public immutable vault;

  uint public maturityTimestamp;

  modifier onlyWhenMatured() {
    if (block.timestamp < maturityTimestamp) revert IFlaixOption.OptionNotMaturedYet();
    _;
  }

  constructor(
    string memory name,
    string memory symbol,
    address asset_,
    address minter_,
    address vault_,
    uint256 totalSupply_,
    uint maturityTimestamp_
  ) ERC20(name, symbol) {
    require(maturityTimestamp_ >= block.timestamp, "FlaixCallOption: maturity in the past");
    maturityTimestamp = maturityTimestamp_;
    asset = asset_;
    vault = vault_;
    _mint(minter_, totalSupply_);
    emit Issue(minter_, totalSupply_, maturityTimestamp_);
  }

  /// @notice Exercise the given amount of options and transfers the result to
  ///         the recipient. The amount of options is burned while the same
  ///         amount of shares is transferred from the options contract to the recipient.
  ///         After that, a corresponding amount of the underlying assets is transferred
  ///         from the options contract to the vault.
  /// @param recipient The address to which the result is transferred.
  /// @param amount The amount of options to exercise.
  function exercise(uint256 amount, address recipient) public onlyWhenMatured {
    uint256 assetAmount = convertToAssets(amount);
    _burn(msg.sender, amount);
    IERC20(vault).safeTransfer(recipient, amount);
    IERC20(asset).safeTransfer(vault, assetAmount);
    emit Exercise(recipient, amount, assetAmount);
  }

  /// @notice Returns the amount of underlying assets for the given amount of
  ///         options when the option is exercised.
  function convertToAssets(uint256 amount) public view returns (uint256) {
    return IERC20(asset).balanceOf(address(this)).mulDiv(amount, totalSupply());
  }

  /// @notice Revoke the given amount of options. The amount of options is burned
  ///         while the same amount of vault shares is burned from the options contract.
  ///         After that, a corresponding amount of the underlying assets is transferred
  ///         from the options contract to the recipient. This function can be used to
  ///         reverse the effect of issuing options or to remove options from the market.
  function revoke(uint256 amount, address recipient) public onlyWhenMatured {
    uint256 assetAmount = convertToAssets(amount);
    _burn(msg.sender, amount);
    IFlaixVault(vault).burn(amount);
    IERC20(asset).safeTransfer(recipient, assetAmount);
    emit Revoke(recipient, amount);
  }
}
