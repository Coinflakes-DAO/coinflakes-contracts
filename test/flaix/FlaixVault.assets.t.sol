// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import "../../src/flaix/FlaixVault.sol";
import "../mocks/MockERC20.sol";

contract FlaixVaultAssetManagementTest is Test {
  ERC20 allowedAsset;
  ERC20 disallowedAsset;
  FlaixVault vault;

  address manager = makeAddr("manager");
  address alice = makeAddr("alice");
  address treasury = makeAddr("treasury");

  function setUp() public {
    vm.startPrank(manager);
    vault = new FlaixVault(treasury);
    allowedAsset = new MockERC20("Allowed Mock ERC20", "ALLOWED");
    disallowedAsset = new MockERC20("Disallowed Mock ERC20", "DISALLOWED");
    vm.stopPrank();
  }

  function test_access_roles() public {
    assertFalse(vault.hasRole(vault.ADD_REMOVE_ASSET_ROLE(), alice), "alice should not have add/remove asset role");
    vm.prank(manager);
    vault.grantAddRemoveAssetRole(alice);
    assertTrue(vault.hasRole(vault.ADD_REMOVE_ASSET_ROLE(), alice), "alice should have add/remove asset role");
    vm.prank(manager);
    vault.revokeAddRemoveAssetRole(alice);
    assertFalse(
      vault.hasRole(vault.ADD_REMOVE_ASSET_ROLE(), alice),
      "alice should not have add/remove asset role after it has been revoked"
    );
  }

  function test_add_and_remove_asset() public {
    assertFalse(vault.isAssetAllowed(address(disallowedAsset)), "asset should not be allowed at first");
    vm.prank(manager);
    vault.grantAddRemoveAssetRole(alice);
    vm.prank(alice);
    vault.allowAsset(address(disallowedAsset));
    assertTrue(vault.isAssetAllowed(address(disallowedAsset)), "asset should be allowed after it has been added");
    vm.prank(alice);
    vault.disallowAsset(address(disallowedAsset));
    assertFalse(
      vault.isAssetAllowed(address(disallowedAsset)),
      "asset should not be allowed after it has been removed"
    );
  }
}
