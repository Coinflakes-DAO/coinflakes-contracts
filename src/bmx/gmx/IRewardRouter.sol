// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IRewardRouter {
  function weth() external view returns (address);

  function gmx() external view returns (address);

  function esGmx() external view returns (address);

  function bnGmx() external view returns (address);

  function stakedGmxTracker() external view returns (address);

  function bonusGmxTracker() external view returns (address);

  function feeGmxTracker() external view returns (address);

  function signalTransfer(address _receiver) external;

  function acceptTransfer(address _sender) external;
}
