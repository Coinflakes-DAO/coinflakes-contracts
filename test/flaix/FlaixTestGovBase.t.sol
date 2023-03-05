// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./FlaixVault.t.sol";
import "@src/flaix/FlaixTestGov.sol";

contract FlaixTestGovBase_Test is FlaixVault_Test {
  address public govAddr;
  address public govTester;

  FlaixTestGov public flaixTestGov;

  function setUp() public virtual override {
    FlaixVault_Test.setUp();
    // Create users.
    govTester = makeAddr("govTester");

    // Deploy FlaixTestGov contract.
    vm.prank(users.admin);
    flaixTestGov = new FlaixTestGov(address(vault));
    govAddr = address(flaixTestGov);

    // Setup user roles.
    vm.startPrank(users.admin);
    flaixTestGov.addTester(users.admin);
    flaixTestGov.addTester(govTester);
    vault.changeAdmin(govAddr);
    vm.stopPrank();
  }

  modifier whenUserIsTester(address user) {
    vm.prank(users.admin);
    flaixTestGov.addTester(user);
    _;
  }

  modifier whenAssetIsAllowed(IERC20 asset) {
    if (flaixTestGov.isAssetAllowed(address(asset))) return;
    vm.prank(users.admin);
    flaixTestGov.allowAsset(address(asset));
    _;
  }
}
