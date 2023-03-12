// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "@test/mocks/MockERC20.sol";
import "@src/bmx/gmx/IRewardTracker.sol";

contract MockRewardTracker is IRewardTracker {
  using SafeMath for uint256;
  using EnumerableSet for EnumerableSet.AddressSet;
  uint8 public constant decimals = 18;

  string public name;
  string public symbol;

  mapping(address => mapping(address => uint256)) public override depositBalances;
  mapping(address => uint256) public override claimable;

  address private rewardToken;
  EnumerableSet.AddressSet private depositTokens;

  function setDepositBalance(address account, address depositToken, uint256 balance) external {
    require(depositTokens.contains(depositToken), "deposit token not supported");
    MockERC20(address(depositToken)).mint(address(this), balance);
    depositBalances[account][depositToken] = balance;
  }

  function addClaimable(address account, uint256 amount) external {
    MockERC20(address(rewardToken)).mint(address(this), amount);
    claimable[account] = claimable[account].add(amount);
  }

  function removeClaimable(address account, uint256 amount) external {
    MockERC20(address(rewardToken)).burn(address(this), amount);
    claimable[account] = claimable[account].sub(amount);
  }

  constructor(string memory name_, string memory symbol_, address rewardToken_, address[] memory depositTokens_) {
    name = name_;
    symbol = symbol_;
    rewardToken = rewardToken_;
    for (uint256 i = 0; i < depositTokens_.length; i++) {
      depositTokens.add(depositTokens_[i]);
    }
  }
}
