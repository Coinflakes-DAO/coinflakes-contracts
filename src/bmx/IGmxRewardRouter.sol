// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IGmxRewardRouter {
  function signalTransfer(address _receiver) external;

  function acceptTransfer(address _sender) external;
}
