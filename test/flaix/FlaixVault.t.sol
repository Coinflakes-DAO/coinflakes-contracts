// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Base_Test} from "../Base.t.sol";
import {FlaixVault} from "../../src/flaix/FlaixVault.sol";

contract FlaixVault_Test is Base_Test {
  FlaixVault public vault;

  function setUp() public override {
    Base_Test.setUp();
    vm.startPrank(users.deployer);
    vault = new FlaixVault();
  }
}
