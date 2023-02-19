// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {FlaixVault_Test} from "../../FlaixVault.t.sol";

contract Name_Test is FlaixVault_Test {
  function test_name() public {
    assertEq(vault.name(), "Coinflakes AI Vault");
  }
}
