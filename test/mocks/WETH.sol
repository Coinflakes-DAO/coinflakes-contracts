// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import "@test/mocks/MockERC20.sol";

contract WETH is MockERC20, Test {
  event Deposit(address indexed dst, uint wad);
  event Withdrawal(address indexed src, uint wad);

  constructor() MockERC20("Wrapped Ether", "WETH", 18) {}

  receive() external payable {
    deposit();
  }

  function deposit() public payable {
    _mint(msg.sender, msg.value);
    emit Deposit(msg.sender, msg.value);
  }

  function withdraw(uint wad) public {
    _burn(msg.sender, wad);
    payable(msg.sender).transfer(wad);
    emit Withdrawal(msg.sender, wad);
  }

  function mint(address account, uint256 amount) public virtual override {
    super.mint(account, amount);
    vm.deal(address(this), address(this).balance + amount);
  }

  function burn(address account, uint256 amount) public virtual override {
    super.burn(account, amount);
    vm.deal(account, account.balance + amount);
  }
}
