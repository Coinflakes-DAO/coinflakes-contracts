// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Base.t.sol";
import {FlaixVault} from "../../src/flaix/FlaixVault.sol";

contract FlaixVaultTest is BaseTest {
  FlaixVault public vault;

  function setUp() public override {
    BaseTest.setUp();
    vm.startPrank(users.deployer);
    vault = new FlaixVault();
  }
}
