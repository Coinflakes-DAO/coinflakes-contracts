// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IRewardTracker {
  function depositBalances(address _account, address _depositToken) external view returns (uint256);

  function claimable(address _account) external view returns (uint256);
}
