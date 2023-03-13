// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@test/mocks/MockERC20.sol";

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@src/interfaces/gmx/core/IGlpManager.sol";

contract GlpManager is IGlpManager {
  using EnumerableSet for EnumerableSet.AddressSet;

  MockERC20 public glp;
  EnumerableSet.AddressSet private tokens;

  constructor(address glp_, address[] memory tokens_) {
    glp = MockERC20(glp_);
    for (uint256 i = 0; i < tokens_.length; i++) {
      tokens.add(tokens_[i]);
    }
  }

  function addLiquidityForAccount(
    address fundingAccount,
    address account,
    address token,
    uint256 amount,
    uint256,
    uint256
  ) external override returns (uint256) {
    require(tokens.contains(token), "GlpManager: invalid token");
    MockERC20(token).burn(fundingAccount, amount);
    glp.mint(account, amount);
    return amount;
  }

  function removeLiquidityForAccount(
    address account,
    address tokenOut,
    uint256 glpAmount,
    uint256,
    address receiver
  ) public override returns (uint256) {
    require(tokens.contains(tokenOut), "GlpManager: invalid token");
    glp.burn(account, glpAmount);
    MockERC20(tokenOut).mint(receiver, glpAmount);
    return glpAmount;
  }
}
