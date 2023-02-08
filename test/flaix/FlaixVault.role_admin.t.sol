// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import "../../src/flaix/FlaixVault.sol";

contract FlaixVaultRoleAdminTest is Test {
  FlaixVault vault;

  address manager = makeAddr("manager");
  address alice = makeAddr("alice");

  function setUp() public {
    vm.prank(manager);
    vault = new FlaixVault();
  }

  function test_change_role_manager() public {
    assertEq(vault.roleManager(), manager, "contract deployer should be role manager");
    assertTrue(vault.hasRole(vault.DEFAULT_ADMIN_ROLE(), manager), "contract deployer should have default admin role");
    vm.prank(manager);
    vault.setRoleManager(alice);
    assertEq(vault.roleManager(), alice, "role manager should be alice");
    assertTrue(vault.hasRole(vault.DEFAULT_ADMIN_ROLE(), alice), "alice should have default admin role");
    assertFalse(
      vault.hasRole(vault.DEFAULT_ADMIN_ROLE(), manager),
      "manager should not have default admin role anymore"
    );
  }
}
