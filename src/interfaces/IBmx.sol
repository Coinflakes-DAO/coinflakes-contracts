// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IBmx {
  function gmxRewardRouter() external view returns (address);

  function mint(address to) external;
}
