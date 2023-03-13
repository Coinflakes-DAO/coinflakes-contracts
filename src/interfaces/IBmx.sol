// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@src/interfaces/gmx/staking/IRewardRouterV2.sol";

interface IBmx is IERC721 {
  function gmxRewardRouter() external view returns (IRewardRouterV2);

  function mint(address to) external;

  function stakedGmxBalance(uint256 tokenId) external view returns (uint256);

  function stakedEsGmxBalance(uint256 tokenId) external view returns (uint256);

  function stakedBonusGmxBalance(uint256 tokenId) external view returns (uint256);
}
