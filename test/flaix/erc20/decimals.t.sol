// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../FlaixVault.t.sol";

contract DecimalsTest is FlaixVaultTest {
  function test_decimals() public {
    assertEq(vault.decimals(), 18);
  }
}
