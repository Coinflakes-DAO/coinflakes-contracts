// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../FlaixVault.t.sol";

contract SymbolTest is FlaixVaultTest {
  function test_symbol() public {
    assertEq(vault.symbol(), "FLAIX");
  }
}
