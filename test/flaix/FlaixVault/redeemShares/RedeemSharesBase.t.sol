// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {FlaixVault_Test} from "../../FlaixVault.t.sol";

contract RedeemSharesBase_Test is FlaixVault_Test {
  modifier whenVaultHoldsDaiAndUsdc() {
    vm.startPrank(users.admin);
    vault.allowAsset(address(tokens.dai));
    vault.allowAsset(address(tokens.usdc));
    vm.stopPrank();
    deal(address(tokens.dai), address(vault), 1000e18, true);
    deal(address(tokens.usdc), address(vault), 2000e6, true);
    _;
  }

  modifier whenAliceIsOnlyShareholder() {
    deal(address(vault), users.alice, 1000e18, true);
    _;
  }

  modifier whenAliceAndBobAreShareholders() {
    deal(address(vault), users.alice, 1000e18, true);
    deal(address(vault), users.bob, 2000e18, true);
    _;
  }
}
