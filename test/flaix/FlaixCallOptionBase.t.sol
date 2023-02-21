// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Base_Test} from "../Base.t.sol";
import {FlaixVault} from "@src/flaix/FlaixVault.sol";
import {FlaixCallOption} from "@src/flaix/FlaixCallOption.sol";

contract FlaixCallOptionBase_Test is Base_Test {
  FlaixVault public vault;
  FlaixCallOption public options;

  function setUp() public override {
    super.setUp();
    setUp_vault();
    setUp_issueCallOptions();
  }

  function setUp_vault() public {
    vault = new FlaixVault();
    vm.prank(vault.admin());
    vault.changeAdmin(users.admin);
  }

  function setUp_issueCallOptions() public {
    deal(address(tokens.dai), users.admin, 1000e18, true);
    vm.startPrank(users.admin);
    tokens.dai.approve(address(vault), 1000e18);
    vault.allowAsset(address(tokens.dai));
    options = FlaixCallOption(
      vault.issueCallOptions(
        "Flaix Options",
        "optFLAIX",
        1000e18,
        users.admin,
        address(tokens.dai),
        1000e18,
        block.timestamp + 3 days
      )
    );
    vm.stopPrank();
  }

  modifier whenOptionIsNotMatured() {
    vm.warp(options.maturityTimestamp() - 1 seconds);
    _;
  }

  modifier whenOptionIsMatured() {
    vm.warp(options.maturityTimestamp() + 1 seconds);
    _;
  }
}
