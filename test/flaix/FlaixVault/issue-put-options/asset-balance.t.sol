// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@src/interfaces/IFlaixVault.sol";
import {IssuePutOptionsBase_Test} from "./IssuePutOptionsBase.t.sol";

contract AssetAllowList_Test is IssuePutOptionsBase_Test {
  function test_whenVaultHasNotEnoughAssets_revert()
    public
    whenDaiIsAllowed
    whenAdminHasShares(1000e18)
    whenAdminHasApprovedShares(1000e18)
    whenVaultHasDai(1000e18 - 1)
  {
    uint limit = vault.minimalOptionsMaturity();
    vm.prank(users.admin);
    vm.expectRevert("ERC20: transfer amount exceeds balance");
    vault.issuePutOptions(
      "FLAIX Put Options 2023-01-01",
      "putFLAIX-230101",
      1000e18,
      users.admin,
      address(tokens.dai),
      1000e18,
      block.timestamp + limit
    );
  }
}
