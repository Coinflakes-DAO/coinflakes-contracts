// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./FlaixCallOption.sol";
import "./FlaixPutOption.sol";

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
  using SafeERC20 for IERC20;

  EnumerableSet.AddressSet private _allowedAssets;

  /// @notice The address of the role manager. The role manager is a single account which can grant and revoke roles an the contract.
  address public roleManager;

  /// @notice The role which allows an account to add or remove assets from the vault.
  bytes32 public constant ADD_REMOVE_ASSET_ROLE = keccak256("ADD_REMOVE_ASSET_ROLE");

  /// @notice The role which allows an account to mint call options.
  bytes32 public constant ISSUE_CALL_OPTIONS_ROLE = keccak256("ISSUE_CALL_OPTIONS_ROLE");

  /// @notice The role which allows an account to mint put options.
  bytes32 public constant ISSUE_PUT_OPTIONS_ROLE = keccak256("ISSUE_PUT_OPTIONS_ROLE");

  event IssueCallOptions(
    address indexed issuer,
    address indexed recipient,
    uint256 amount,
    address indexed asset,
    uint256 assetAmount,
    uint256 maturityTimestamp
  );

  /// @dev Constructor
  constructor() ERC20("Coinflakes AI Vault", "FLAIX") {
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    roleManager = _msgSender();
  }

  /// @notice Set the role manager. The role manager is a single account which can grant and revoke roles an the contract.
  ///         This function can only be called by the current role manager.
  /// @param account The address of the new role manager. Replaces the current role manager.
  function setRoleManager(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
    _grantRole(DEFAULT_ADMIN_ROLE, account);
    _revokeRole(DEFAULT_ADMIN_ROLE, roleManager);
    roleManager = account;
  }

  /// @notice Grants the right to add or remove assets to/from the vault to an address.
  ///         This function can only be called by the role manager.
  /// @param account The address to grant the right to.
  function grantAddRemoveAssetRole(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
    _grantRole(ADD_REMOVE_ASSET_ROLE, account);
  }

  /// @notice Revokes the right to add or remove assets to/from the vault from an address.
  ///         This function can only be called by the role manager.
  /// @param account The address to revoke the right from.
  function revokeAddRemoveAssetRole(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
    _revokeRole(ADD_REMOVE_ASSET_ROLE, account);
  }

  /// @notice Adds an asset to the allowed asset list of the vault
  ///         This function can only be called by an account with the ADD_REMOVE_ASSET_ROLE.
  /// @param assetAddress The address of the asset to add to the allowed asset list.
  function allowAsset(address assetAddress) public onlyRole(ADD_REMOVE_ASSET_ROLE) {
    require(!_allowedAssets.contains(assetAddress), "Vault: Asset already on allow list");
    _allowedAssets.add(assetAddress);
  }

  /// @notice Removes an asset from the allowed asset list of the vault. Note that this
  ///         only prevents new assets from being added to the vault. It does not remove
  ///         existing assets nor does it remove the right to withdraw existing assets.
  ///         This function can only be called by an account with the ADD_REMOVE_ASSET_ROLE.
  /// @param assetAddress  The address of the asset to remove from the allowed asset list.

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
  /// @param index The index of the asset to return.
  /// @return address The address of the asset at the given index.
  function allowedAsset(uint256 index) public view returns (address) {
    return _allowedAssets.at(index);
  }

  function redeemShares(uint256 amount, address recipient) public {
    require(recipient != address(0), "Vault: Recipient cannot be zero address");
    uint256 q = (amount * (10**decimals())) / totalSupply();
    _burn(msg.sender, amount);
    for (uint256 i = 0; i < _allowedAssets.length(); i++) {
      address asset = _allowedAssets.at(i);
      uint256 assetBalance = IERC20(asset).balanceOf(address(this));
      uint256 assetAmount = (assetBalance * q) / (10**decimals());
      IERC20(asset).safeTransfer(recipient, assetAmount);
    }
  }

  function burn(uint256 amount) public {
    _burn(msg.sender, amount);
  }

  /// @notice Mints FLAIX call options to the recipient. A call option is a token which can be swapped
  ///         for shares of the vault at a certain time in the future.  The call option is minted with
  ///         a certain amount of shares in exchange for a certain amount of an underlying asset. On
  ///         minting the backing asset is transferred from the minter to the options contract and the
  ///         vault mints an equal amount of vault shares to the call option contract. After that,
  ///         the call option contract should own both the underlying assets as well as the vault
  ///         shares. The recipinet receives all of the call options tokens in return for his assets.
  ///         This function can only be called by an account with the MINT_CALL_OPTIONS_ROLE.
  /// @param name The name of the call option.
  /// @param symbol The symbol of the call option.
  /// @param sharesAmount The amount of shares to be minted to the call option contract.
  /// @param recipient The address of the recipient of the call options.
  /// @param asset The address of the underlying asset.
  /// @param assetAmount The amount of underlying asset to be transferred from the issuer to the call option contract.
  /// @param maturityTimestamp The timestamp at which the call options can be exercised.
  /// @return address The address of the newly minted call options contract.
  function issueCallOptions(
    string memory name,
    string memory symbol,
    uint256 sharesAmount,
    address recipient,
    address asset,
    uint256 assetAmount,
    uint256 maturityTimestamp
  ) public onlyRole(ISSUE_CALL_OPTIONS_ROLE) returns (address) {
    require(maturityTimestamp > block.timestamp, "Vault: Maturity must be in the future");
    require(_allowedAssets.contains(asset), "Vault: Asset not allowed");

    FlaixCallOption options = new FlaixCallOption(
      name,
      symbol,
      asset,
      recipient,
      address(this),
      sharesAmount,
      maturityTimestamp
    );
    IERC20(asset).safeTransferFrom(msg.sender, address(options), assetAmount);
    _mint(address(options), sharesAmount);

    emit IssueCallOptions(msg.sender, recipient, sharesAmount, asset, assetAmount, maturityTimestamp);
    return address(options);
  }

  /// @notice Mints FLAIX put options to the recipient. A put option is a token which can be swapped
  ///         for underlying assets from the vault at a certain time in the future.
  ///         The put option is minted with a certain amount of underlying assets in exchange
  ///         for a certain amount of vault shares. On minting the vault shares are transferred
  ///         from the issuer to the options contract and the
  ///         vault matches this with a given amount of underlying assets transferring them into the
  ///         options contract. After that, the put option contract should own both the underlying assets from
  ///         the vault and the shares from the issuer. The recipient receives all of the put options tokens
  ///         in return for her shares.
  ///         This function can only be called by an account with the MINT_PUT_OPTIONS_ROLE.
  /// @param name The name of the put option.
  /// @param symbol The symbol of the put option.
  /// @param sharesAmount The amount of shares to be transferred from the issuer to the contract.
  /// @param recipient The address of the recipient of the put options.
  /// @param asset The address of the underlying asset.
  /// @param assetAmount The amount of underlying asset to be transferred from the vault to the contract.
  /// @param maturityTimestamp The timestamp at which the put option can be exercised.
  /// @return address The address of the newly minted put option contract.
  function issuePutOption(
    string memory name,
    string memory symbol,
    uint256 sharesAmount,
    address recipient,
    address asset,
    uint256 assetAmount,
    uint maturityTimestamp
  ) public onlyRole(ISSUE_PUT_OPTIONS_ROLE) returns (address) {
    require(maturityTimestamp > block.timestamp, "Vault: Maturity must be in the future");
    require(_allowedAssets.contains(asset), "Vault: Asset not allowed");

    FlaixPutOption options = new FlaixPutOption(
      name,
      symbol,
      asset,
      recipient,
      address(this),
      sharesAmount,
      maturityTimestamp
    );
    IERC20(this).safeTransferFrom(msg.sender, address(options), sharesAmount);
    IERC20(asset).safeTransfer(address(options), assetAmount);
    return address(options);
  }
}
