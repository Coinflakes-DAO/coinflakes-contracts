// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin-upgradeable/contracts/proxy/utils/Initializable.sol";

import "@src/interfaces/gmx/staking/IRewardRouterV2.sol";

import "../interfaces/IBmx.sol";
import "../interfaces/IBmxEscrow.sol";

contract BmxEscrow is IBmxEscrow, Initializable {
  uint256 public tokenId;
  IBmx public bmx;

  constructor() {
    tokenId = 0;
  }

  function initialize(address bmxToken) public initializer {
    bmx = IBmx(bmxToken);
  }

  function acceptTransfer(address sender, uint256 tokenId_) external {
    require(msg.sender == address(bmx), "BmxAccountEscrow: Only BMX can call this function");
    tokenId = tokenId_;
    _rewardRouter().acceptTransfer(sender);
  }

  function _rewardRouter() internal view returns (IRewardRouterV2) {
    return IRewardRouterV2(bmx.gmxRewardRouter());
  }
}
