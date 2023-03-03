// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./FlaixCallOption.sol";
import "./FlaixPutOption.sol";

/// @title FlaixVault
/// @author Ned Albo
/// @notice This contract pertains to the FlaixVault contract, which
///         serves as a means of investing in AI tokens. The contract
///         is designed to hold tokens that are expected to increase in
///         value over time. Ownership of the vault is represented by
///         the FLAIX token, which is a proportional share of the tokens
///         held by the vault.
/// @dev This contract is based on the OpenZeppelin ERC20 contract.
contract FlaixVault is ERC20, IFlaixVault, ReentrancyGuard {
  using EnumerableSet for EnumerableSet.AddressSet;
  using SafeERC20 for IERC20;
  using SafeMath for uint256;
  using Math for uint256;

  EnumerableSet.AddressSet private _allowedAssets;

  /// @notice The address of the admin account. The admin account should be replaced
  ///         by a multisig contract or even better a DAO in the future.
  address public admin;

  /// @notice When an option is issued, the issuer selects a maturity value, which is the
  /// point in time when the option can be exercised. The maturity period must be a
  /// minimum of three days, but the admin account has the ability to adjust the
  /// minimum maturity period.
  uint public minimalOptionsMaturity = 3 days;

  /// @notice The minting budget for each account which is allowed to mint tokens.
  mapping(address => uint) public minters;

  modifier onlyAdmin() {
    if (_msgSender() != admin) revert IFlaixVault.OnlyAllowedForAdmin();
    _;
  }

  /// @dev Constructor
  constructor() ERC20("Coinflakes AI Vault", "FLAIX") {
    admin = _msgSender();
    emit AdminChanged(admin, address(0));
  }

  /// @notice Changes the admin account of the vault. This function can only be called by
  ///         the previous admin account.
  /// @param newAdmin The new admin account.
  function changeAdmin(address newAdmin) public onlyAdmin {
    if (newAdmin == address(0)) revert IFlaixVault.AdminCannotBeNull();
    emit AdminChanged(newAdmin, admin);
    admin = newAdmin;
  }

  /// @notice Changes the minimal options maturity. The minimal options maturity is the minimal maturity of options
  ///         that can be issued by the vault.
  /// @param newMaturity The new minimal options maturity.
  function changeMinimalOptionsMaturity(uint newMaturity) public onlyAdmin {
    if (newMaturity < 3 days) revert IFlaixVault.MaturityChangeBelowLimit();
    minimalOptionsMaturity = newMaturity;
  }

  /// @notice Adds an asset to the allowed asset list of the vault
  /// @param assetAddress The address of the asset to add to the allowed asset list.
  function allowAsset(address assetAddress) public onlyAdmin {
    if (assetAddress == address(0)) revert IFlaixVault.AssetCannotBeNull();
    if (!_allowedAssets.add(assetAddress)) revert AssetAlreadyOnAllowList();
    emit AssetAllowed(assetAddress);
  }

  /// @notice This function removes an asset from the vault's list of allowed assets. It is
  ///         important to note that this action only prevents new assets from being added
  ///         to the vault, and does not remove any existing assets or the right to
  ///         withdraw existing assets.
  /// @param assetAddress  The address of the asset to remove from the allowed asset list.
  function disallowAsset(address assetAddress) public onlyAdmin {
    if (!_allowedAssets.remove(assetAddress)) revert AssetNotOnAllowList();
    emit AssetDisallowed(assetAddress);
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
    if (index >= _allowedAssets.length()) revert IFlaixVault.AssetIndexOutOfBounds();
    return _allowedAssets.at(index);
  }

  /// @notice This function pertains to the minting budget of an account, and only allows
  ///         CallOptions or PutOptions to mint shares. The minting budget represents the
  ///         maximum number of shares that can be minted by the account, and is reduced by
  ///         the amount of shares that the account has already minted.
  function minterBudgetOf(address minter) public view returns (uint) {
    return minters[minter];
  }

  /// @notice This function burns shares from the sender and in exchange, sends the
  ///         recipient a proportional amount of each vault asset.
  /// @param amount The amount of shares to burn.
  /// @param recipient The address to send the vault assets to.
  function redeemShares(uint256 amount, address recipient) public nonReentrant {
    if (amount == 0) return;
    if (totalSupply() == 0) return;
    if (recipient == address(0)) revert IFlaixVault.RecipientCannotBeNullAddress();
    for (uint256 i = 0; i < _allowedAssets.length(); i++) {
      address asset = _allowedAssets.at(i);
      //slither-disable-next-line calls-loop
      uint256 assetBalance = IERC20(asset).balanceOf(address(this));
      uint256 assetAmount = assetBalance.mulDiv(amount, totalSupply(), Math.Rounding.Down);
      //slither-disable-next-line calls-loop
      IERC20(asset).safeTransfer(recipient, assetAmount);
    }
    _burn(msg.sender, amount);
  }

  /// @notice Burns shares from the sender.
  /// @param amount The amount of shares to burn.
  function burn(uint256 amount) public {
    _burn(msg.sender, amount);
  }

  /// @notice Mints shares to the recipient. Minting shares is only possible
  ///         if the sender has a minting budget which is equal or greater than the amount.
  function mint(uint amount, address recipient) public {
    if (minters[msg.sender] < amount) revert IFlaixVault.MinterBudgetExceeded();
    _mint(recipient, amount);
  }

  function _mint(address account, uint256 amount) internal override {
    minters[msg.sender] = minters[msg.sender].sub(amount);
    super._mint(account, amount);
  }

  /// @notice This function mints FLAIX call options to the recipient. A call option
  /// is a token that can be exchanged for shares of the vault at a specified
  /// time in the future. The call option is minted by exchanging a certain
  /// amount of shares for a specific amount of an underlying asset. Upon
  /// minting, the backing asset is transferred from the minter to the options
  /// contract, and the options contract is granted the right to mint an equal
  /// amount of vault shares. Subsequently, the call option contract should
  /// own the underlying assets and be prepared to mint shares. The recipient
  /// will receive all of the call option tokens in exchange for their assets.
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
  ) public onlyAdmin nonReentrant returns (address) {
    //slither-disable-next-line timestamp
    if (maturityTimestamp < block.timestamp + minimalOptionsMaturity) revert IFlaixVault.MaturityTooLow();
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
    minters[address(options)] = sharesAmount;

    emit IssueCallOptions(
      address(options),
      recipient,
      name,
      symbol,
      sharesAmount,
      asset,
      assetAmount,
      maturityTimestamp
    );
    IERC20(asset).safeTransferFrom(msg.sender, address(options), assetAmount);

    return address(options);
  }

  /// @notice This function mints FLAIX put options to the recipient. A put option
  /// is a token that can be exchanged for underlying assets from the vault
  /// at a specified time in the future. The put option is minted by exchanging
  /// a certain amount of underlying assets for a specific amount of vault shares.
  /// Upon minting, the vault shares are burned from the issuer, and the vault matches
  /// this by transferring a certain amount of underlying assets into the options
  /// contract. Subsequently, the put option contract should own the underlying assets
  /// from the vault and have the right to mint back the burned shares in case the
  /// options are revoked. The recipient will receive all of the put option tokens in
  /// exchange for their shares.
  /// @param name The name of the put option.
  /// @param symbol The symbol of the put option.
  /// @param sharesAmount The amount of shares to be transferred from the issuer to the contract.
  /// @param recipient The address of the recipient of the put options.
  /// @param asset The address of the underlying asset.
  /// @param assetAmount The amount of underlying asset to be transferred from the vault to the contract.
  /// @param maturityTimestamp The timestamp at which the put option can be exercised.
  /// @return address The address of the newly minted put option contract.
  function issuePutOptions(
    string memory name,
    string memory symbol,
    uint256 sharesAmount,
    address recipient,
    address asset,
    uint256 assetAmount,
    uint maturityTimestamp
  ) public onlyAdmin nonReentrant returns (address) {
    //slither-disable-next-line timestamp
    if (maturityTimestamp < block.timestamp + minimalOptionsMaturity) revert IFlaixVault.MaturityTooLow();
    if (!_allowedAssets.contains(asset)) revert IFlaixVault.AssetNotOnAllowList();

    FlaixPutOption options = new FlaixPutOption(
      name,
      symbol,
      asset,
      recipient,
      address(this),
      sharesAmount,
      maturityTimestamp
    );
    emit IssuePutOptions(
      address(options),
      recipient,
      name,
      symbol,
      sharesAmount,
      asset,
      assetAmount,
      maturityTimestamp
    );
    IERC20(this).safeTransferFrom(msg.sender, address(options), sharesAmount);
    _burn(address(options), sharesAmount);
    minters[address(options)] = sharesAmount;
    IERC20(asset).safeTransfer(address(options), assetAmount);
    return address(options);
  }
}
