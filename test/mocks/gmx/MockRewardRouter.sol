// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@test/mocks/MockERC20.sol";

import "@src/bmx/gmx/IRewardRouter.sol";
import "./MockRewardTracker.sol";

contract MockRewardRouter is IRewardRouter {
  address public immutable override weth = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
  address public immutable override gmx = address(new MockERC20("GMX", "GMX", 18));
  address public immutable override esGmx = address(new MockERC20("esGMX", "esGM", 18));
  address public immutable bnGmx = address(new MockERC20("bnGMX", "bnGM", 18));

  address public immutable override stakedGmxTracker;
  address public immutable override bonusGmxTracker;
  address public immutable override feeGmxTracker;

  constructor() {
    address[] memory depositTokens = new address[](2);

    depositTokens[0] = gmx;
    depositTokens[1] = esGmx;
    stakedGmxTracker = address(new MockRewardTracker("Staked GMX", "sGMX", esGmx, depositTokens));

    depositTokens[0] = stakedGmxTracker;
    bonusGmxTracker = address(new MockRewardTracker("Staked + Bonus GMX", "sbGMX", bnGmx, depositTokens));

    depositTokens[0] = bonusGmxTracker;
    depositTokens[1] = bnGmx;
    feeGmxTracker = address(new MockRewardTracker("Staked + Bonus + Fee GMX", "sbfGMX", esGmx, depositTokens));
  }

  function signalTransfer(address _receiver) external {}

  function acceptTransfer(address _sender) external {}
}
