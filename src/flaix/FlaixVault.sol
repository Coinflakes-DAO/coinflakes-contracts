// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/// @title FlaixVault
/// @author Ned Albo
/// @notice This contract describes the FlaixVault contract which is a
///         vehicle for investing in AI tokens. The contract holds tokens
///         which hopefully will appreciate in value over time.
///         Shares of the vault are represented by the FLAIX token which are
///         a pro rata share of the vault's token holdings.
/// @dev This contract is based on the OpenZeppelin ERC20 contract.

contract FlaixVault is ERC20, AccessControl {
  using EnumerableSet for EnumerableSet.AddressSet;

  EnumerableSet.AddressSet private _allowedAssets;

  /// @notice The address of the role manager. The role manager is a single account which can grant and revoke roles an the contract.
  address public roleManager;

  /// @notice The role which allows an account to add or remove assets from the vault.
  bytes32 public constant ADD_REMOVE_ASSET_ROLE = keccak256("ADD_REMOVE_ASSET_ROLE");

  /// @dev Constructor
  constructor() ERC20("Coinflakes AI Vault", "FLAIX") {
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    roleManager = _msgSender();
  }

  /// @notice Set the role manager. The role manager is a single account which can grant and revoke roles an the contract.
  /// @param account The address of the new role manager. Replaces the current role manager.
  /// @dev This function can only be called by the current role manager.
  function setRoleManager(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
    _grantRole(DEFAULT_ADMIN_ROLE, account);
    _revokeRole(DEFAULT_ADMIN_ROLE, roleManager);
    roleManager = account;
  }

  /// @notice Grants the right to add or remove assets to/from the vault to an address.
  /// @param account The address to grant the right to.
  /// @dev This function can only be called by the role manager.
  function grantAddRemoveAssetRole(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
    _grantRole(ADD_REMOVE_ASSET_ROLE, account);
  }

  /// @notice Revokes the right to add or remove assets to/from the vault from an address.
  /// @param account The address to revoke the right from.
  /// @dev This function can only be called by the role manager.
  function revokeAddRemoveAssetRole(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
    _revokeRole(ADD_REMOVE_ASSET_ROLE, account);
  }

  /// @notice Adds an asset to the allowed asset list of the vault
  /// @param assetAddress The address of the asset to add to the allowed asset list.
  /// @dev This function can only be called by an account with the ADD_REMOVE_ASSET_ROLE.
  function allowAsset(address assetAddress) public onlyRole(ADD_REMOVE_ASSET_ROLE) {
    require(!_allowedAssets.contains(assetAddress), "Vault: Asset already on allow list");
    _allowedAssets.add(assetAddress);
  }

  /// @notice Removes an asset from the allowed asset list of the vault. Note that this
  ///         only prevents new assets from being added to the vault. It does not remove
  ///         existing assets nor does it remove the right to withdraw existing assets.
  /// @param assetAddress  The address of the asset to remove from the allowed asset list.
  /// @dev This function can only be called by an account with the ADD_REMOVE_ASSET_ROLE.

  function disallowAsset(address assetAddress) public onlyRole(ADD_REMOVE_ASSET_ROLE) {
    require(_allowedAssets.contains(assetAddress), "Vault: Asset not on allow list");
    _allowedAssets.remove(assetAddress);
  }

  /// @notice Checks if a certain asset is allowed to be added to the vault.
  /// @param assetAddress The address of the asset to check.
  /// @return True if the asset is allowed to be added to the vault, false otherwise.
  function isAssetAllowed(address assetAddress) public view returns (bool) {
    return _allowedAssets.contains(assetAddress);
  }

  /// @notice Returns the number of allowed assets
  /// @return uint256 The number of allowed assets
  function allowedAssets() public view returns (uint256) {
    return _allowedAssets.length();
  }

  /// @notice Returns the address of an allowed asset at a certain index
  /// @param index The index of the asset to return
  /// @return address The address of the asset at the given index
  function allowedAsset(uint256 index) public view returns (address) {
    return _allowedAssets.at(index);
  }
}
