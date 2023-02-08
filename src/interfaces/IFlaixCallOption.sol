// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IFlaixCallOption is IERC20Metadata {
  function asset() external view returns (address);

  function maxTotalSupply() external view returns (uint256);

  function strikePrice() external view returns (uint256);

  function pricePerVote() external view returns (uint256);

  function maturityTimestamp() external view returns (uint);
}
