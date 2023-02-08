// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../interfaces/IFlaixCallOption.sol";
import "../interfaces/IFlaixVault.sol";
import "../interfaces/IFlaixVotes.sol";

contract FlaixCallOption is ERC20, IFlaixCallOption {
  using SafeERC20 for IERC20;

  address public immutable vault;
  address public immutable treasury;

  address public immutable voteToken;
  uint256 private immutable voteEmissionsBegin;

  address public asset;
  uint256 public strikePrice;
  uint8 private assetDecimals;

  uint256 public maxTotalSupply;

  uint public maturityTimestamp;

  constructor(
    string memory name,
    string memory symbol,
    address vault_,
    address asset_,
    uint256 maxTotalSupply_,
    uint256 strikePrice_,
    uint maturityTimestamp_
  ) ERC20(name, symbol) {
    asset = asset_;
    assetDecimals = IERC20Metadata(asset_).decimals();
    maxTotalSupply = maxTotalSupply_;
    strikePrice = strikePrice_;
    maturityTimestamp = maturityTimestamp_;
    vault = vault_;
    treasury = IFlaixVault(vault_).treasury();
    voteToken = IFlaixVault(vault_).voteToken();
    voteEmissionsBegin = IFlaixVault(vault_).voteEmissionsBegin();
  }

  function mint(address recipient, uint256 amount) external {
    _mint(recipient, amount);
    IFlaixVotes(voteToken).mint(treasury, amount);
  }

  function mintWithVotes(address recipient, uint256 amount) external {
    uint256 assetsToPay = (amount * pricePerVote()) / 10**assetDecimals;
    IERC20(asset).safeTransferFrom(msg.sender, treasury, assetsToPay);
    IFlaixVotes(voteToken).mint(recipient, amount);
  }

  function _mint(address recipient, uint256 amount) internal override {
    require(block.timestamp < maturityTimestamp, "FlaixCallOption: expired");
    require(totalSupply() + amount <= maxTotalSupply, "FlaixCallOption: max total supply exceeded");
    uint256 assetAmount = (amount * strikePrice) / 10**assetDecimals;
    IERC20(asset).safeTransferFrom(msg.sender, address(this), assetAmount);
    ERC20._mint(recipient, amount);
  }

  function previewMint(uint256 shares, bool buyVotes) external view returns (uint256) {
    uint256 assetAmount = (shares * strikePrice) / 10**assetDecimals;
    if (buyVotes) {
      assetAmount += (shares * pricePerVote()) / 10**assetDecimals;
    }
    return assetAmount;
  }

  function maxMintable() public view returns (uint256) {
    return maxTotalSupply - totalSupply();
  }

  function exercise(address recipient) public {
    require(block.timestamp >= maturityTimestamp, "FlaixCallOption: not matured");
    uint256 amount = balanceOf(msg.sender);
    _burn(msg.sender, amount);
    IFlaixVault(vault).mint(recipient, amount);
    IERC20(asset).safeTransfer(msg.sender, amount);
  }

  function pricePerVote() public view virtual returns (uint256) {
    uint256 emissionBegin = voteEmissionsBegin;
    if (emissionBegin == 0 || block.timestamp < emissionBegin) {
      return 2e18;
    }
    uint256 timeSinceEmissionsBegin = block.timestamp - emissionBegin;
    if (timeSinceEmissionsBegin >= 365 days) {
      return 0;
    }
    // not precise, but good enough ;-)
    return 2e18 - (2011 * (timeSinceEmissionsBegin**2));
  }
}
