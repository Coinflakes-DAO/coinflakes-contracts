// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {RedeemSharesBase_Test} from "./RedeemSharesBase.t.sol";

contract RedeemShares_Test is RedeemSharesBase_Test {
  function test_whenUserHasShares_redeemShares_transfersAssetsToRecipient()
    public
    whenAliceIsOnlyShareholder
    whenVaultHoldsDaiAndUsdc
  {
    vm.prank(users.alice);
    vault.redeemShares(1000e18, users.alice);
    assertEq(tokens.dai.balanceOf(users.alice), 1000e18);
    assertEq(tokens.usdc.balanceOf(users.alice), 2000e6);
  }
}
