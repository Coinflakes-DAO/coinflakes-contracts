// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IBmxEscrow {
  function initialize(address _bmx) external;

  function acceptTransfer(address sender, uint256 _tokenId) external;
}
