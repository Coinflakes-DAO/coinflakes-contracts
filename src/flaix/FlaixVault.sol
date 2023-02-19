// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

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

contract FlaixVault is ERC20, IFlaixVault {
  using EnumerableSet for EnumerableSet.AddressSet;
  using SafeERC20 for IERC20;

  EnumerableSet.AddressSet private _allowedAssets;

  /// @notice The address of the admin account.
  address public admin;

  /// @notice The minimal maturity of options that can be issued by the vault.
  uint public minimalOptionsMaturity = 5 days;

  modifier onlyAdmin() {
    if (_msgSender() != admin) revert IFlaixVault.OnlyAllowedForAdmin();
    _;
  }

  /// @dev Constructor
  constructor() ERC20("Coinflakes AI Vault", "FLAIX") {
    admin = _msgSender();
    emit AdminChanged(admin, address(0));
  }

  function changeAdmin(address newAdmin) public onlyAdmin {
    emit AdminChanged(newAdmin, admin);
    admin = newAdmin;
  }

  /// @notice Changes the minimal options maturity. The minimal options maturity is the minimal maturity of options
  ///         that can be issued by the vault.
  ///         This function can only be called by an account with the CHANGE_MINIMAL_OPTIONS_MATURITY_ROLE.
  /// @param newMaturity The new minimal options maturity.
  function changeMinimalOptionsMaturity(uint newMaturity) public onlyAdmin {
    if (newMaturity < 3 days) revert IFlaixVault.MinimalOptionsMaturityBelowLimit({limit: 3 days});
    minimalOptionsMaturity = newMaturity;
  }

  /// @notice Adds an asset to the allowed asset list of the vault
  ///         This function can only be called by an account with the ADD_REMOVE_ASSET_ROLE.
  /// @param assetAddress The address of the asset to add to the allowed asset list.
  function allowAsset(address assetAddress) public onlyAdmin {
    require(!_allowedAssets.contains(assetAddress), "Vault: Asset already on allow list");
    _allowedAssets.add(assetAddress);
  }

  /// @notice Removes an asset from the allowed asset list of the vault. Note that this
  ///         only prevents new assets from being added to the vault. It does not remove
  ///         existing assets nor does it remove the right to withdraw existing assets.
  ///         This function can only be called by an account with the ADD_REMOVE_ASSET_ROLE.
  /// @param assetAddress  The address of the asset to remove from the allowed asset list.

  function disallowAsset(address assetAddress) public onlyAdmin {
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

  /// @notice Burns shares from the sender and sends the pro rata amount
  ///         of each vault asset to the recipient in return.
  /// @param amount The amount of shares to burn.
  /// @param recipient The address to send the vault assets to.
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

  /// @notice Burns shares from the sender.
  /// @param amount The amount of shares to burn.
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
  ) public onlyAdmin returns (address) {
    if (maturityTimestamp < block.timestamp + minimalOptionsMaturity) revert IFlaixVault.OptionsMaturityTooLow();
    if (!_allowedAssets.contains(asset)) revert IFlaixVault.AssetNotOnAllowList();

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
  ) public onlyAdmin returns (address) {
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
