// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin-upgradeable/contracts/proxy/utils/Initializable.sol";

import "./IGmxRewardRouter.sol";
import "../interfaces/IBmx.sol";

contract BmxEscrow is Initializable {
  uint256 public tokenId;
  IBmx public bmx;

  constructor() {
    tokenId = 0;
  }

  function initialize(address _bmx) public initializer {
    bmx = IBmx(_bmx);
  }

  function acceptTransfer(address _sender, uint256 _tokenId) external {
    require(msg.sender == address(bmx), "BmxAccountEscrow: Only BMX can call this function");
    tokenId = _tokenId;
    IGmxRewardRouter gmxRewardRouter = IGmxRewardRouter(bmx.gmxRewardRouter());
    IGmxRewardRouter(gmxRewardRouter).acceptTransfer(_sender);
  }
}
