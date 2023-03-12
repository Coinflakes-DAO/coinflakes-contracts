// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "@src/bmx/Bmx.sol";
import "@src/bmx/BmxEscrow.sol";

import "../Base.t.sol";

contract BmxBase_Test is Base_Test {
  address public immutable gmxUser1 = 0x0A7577e60e4dF5d060FD267194cF6116f38350eC;
  address public immutable gmxUser2 = 0x5A22b08D884DAAb9E9B8c36A86AA2cF6cDa7f899;

  BMX public bmx;

  function setUp() public virtual override {
    super.setUp();
    string memory url = vm.envString("ARBITRUM_FORK_URL");
    vm.createSelectFork(url);
    setUp_users();
    setUp_Bmx();
  }

  function setUp_users() public virtual override {
    super.setUp_users();
  }

  function setUp_Bmx() public virtual {
    address escrowImpl = address(new BmxEscrow());
    bmx = new BMX(escrowImpl);
  }
}
