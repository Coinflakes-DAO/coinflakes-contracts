// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../FlaixVault.t.sol";

contract NameTest is FlaixVaultTest {
  function test_name() public {
    assertEq(vault.name(), "Coinflakes AI Vault");
  }
}
