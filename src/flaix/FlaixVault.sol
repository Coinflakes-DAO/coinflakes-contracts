// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../interfaces/IFlaixMintable.sol";
import "../interfaces/IFlaixBurnable.sol";
import "./FlaixCallOption.sol";
import "./FlaixVotes.sol";

/// @title FlaixVault
/// @author Ned Albo
/// @notice This contract describes the FlaixVault contract which is a
///         vehicle for investing in AI tokens. The contract holds tokens
///         which hopefully will appreciate in value over time.
///         Shares of the vault are represented by the FLAIX token which are
///         a pro rata share of the vault's token holdings.
/// @dev This contract is based on the OpenZeppelin ERC20 contract.

contract FlaixVault is ERC20, IFlaixMintable, IFlaixBurnable, AccessControl {
  using EnumerableSet for EnumerableSet.AddressSet;

  EnumerableSet.AddressSet private _allowedAssets;

  /// @notice The address of the FlaixVotes contract which is used to represent votes.
  address public voteToken;
  /// @notice The timestamp when the emission of votes begins. Votes can be purchased when options are minted.
  ///         The initial price of 1 vote is 2x the price of 1 FLAIX token. The price of 1 vote decreases quadratically
  ///         over time until the price reaches 0 at the end of the first year. A vote price of 0 means that each FLAIX
  ///         token comes with a free vote token.
  uint256 public voteEmissionsBegin = 0;

  /// @notice The address of the public treasury. The public treasury is a single account which can receive funds from the vault like
  ///         fees or taxes.
  address public treasury;

  /// @notice The address of the role manager. The role manager is a single account which can grant and revoke roles an the contract.
  address public roleManager;

  /// @notice The role which allows an account to mint FLAIX tokens.
  bytes32 public constant MINT_ROLE = keccak256("MINT_ROLE");
  /// @notice The role which allows an account to burn FLAIX tokens.
  bytes32 public constant BURN_ROLE = keccak256("BURN_ROLE");

  /// @notice The role which allows an account to add or remove assets from the vault.
  bytes32 public constant ADD_REMOVE_ASSET_ROLE = keccak256("ADD_REMOVE_ASSET_ROLE");

  /// @notice The role which allows an account to mint votes.
  bytes32 public constant MINT_VOTES_ROLE = keccak256("MINT_VOTES_ROLE");
  /// @notice The role which allows an account to burn votes.
  bytes32 public constant BURN_VOTES_ROLE = keccak256("BURN_VOTES_ROLE");

  /// @notice The role which allows an account to mint call options.
  bytes32 public constant MINT_CALL_OPTIONS_ROLE = keccak256("MINT_OPTIONS_ROLE");
  /// @notice The role which allows an account to burn call options.
  bytes32 public constant BURN_CALL_OPTIONS_ROLE = keccak256("BURN_OPTIONS_ROLE");

  /// @dev Constructor
  constructor(address treasury_) ERC20("Coinflakes AI Vault", "FLAIX") {
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    roleManager = _msgSender();
    voteToken = address(new FlaixVotes(address(this)));
    treasury = treasury_;
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

  /// @notice Mints vault vote tokens to an account, increasing the account's voting power.
  ///         This function can only be called by an account with the MINT_VOTES_ROLE.
  /// @param account The account to mint the tokens to.
  /// @param amount The amount of tokens to mint.
  function mintVotes(address account, uint256 amount) public onlyRole(MINT_VOTES_ROLE) {
    IFlaixMintable(voteToken).mint(account, amount);
  }

  /// @notice Burns vault vote tokens from an account, decreasing the account's voting power.
  ///         This function can only be called by an account with the BURN_VOTES_ROLE.
  /// @param account The account to burn the tokens from.
  /// @param amount The amount of tokens to burn.
  function burnVotes(address account, uint256 amount) public onlyRole(BURN_VOTES_ROLE) {
    IFlaixBurnable(voteToken).burn(account, amount);
  }

  /// @notice Mints FLAIX tokens to an account.
  ///         This function can only be called by an account with the MINT_ROLE.
  /// @param account The account to mint the tokens to.
  /// @param amount The amount of tokens to mint.
  function mint(address account, uint256 amount) public onlyRole(MINT_ROLE) {
    _mint(account, amount);
    emit Mint(account, amount);
  }

  /// @notice Burns FLAIX tokens from an account.
  ///         This function can only be called by an account with the BURN_ROLE.
  /// @param account The account to burn the tokens from.
  /// @param amount The amount of tokens to burn.
  function burn(address account, uint256 amount) public onlyRole(BURN_ROLE) {
    _burn(account, amount);
    emit Burn(account, amount);
  }

  function issueCallOptions(
    string memory name,
    string memory symbol,
    address asset,
    uint256 amount,
    uint256 strikePrice,
    uint256 maturityTimestamp
  ) public onlyRole(MINT_CALL_OPTIONS_ROLE) returns (address) {
    require(maturityTimestamp > block.timestamp, "Vault: Maturity must be in the future");
    if (voteEmissionsBegin == 0) {
      voteEmissionsBegin = block.timestamp;
    }
    FlaixCallOption options = new FlaixCallOption(
      name,
      symbol,
      address(this),
      asset,
      amount,
      strikePrice,
      maturityTimestamp
    );
    grantRole(MINT_ROLE, address(options));
    grantRole(MINT_VOTES_ROLE, address(options));
    return address(options);
  }
}
