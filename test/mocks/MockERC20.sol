// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
  //slither-disable-next-line naming-convention
  uint8 immutable _decimals;

  constructor(string memory tokenName, string memory tokenSymbol, uint8 tokenDecimals) ERC20(tokenName, tokenSymbol) {
    require(tokenDecimals > 0, "decimals can't be zero");
    _decimals = tokenDecimals;
  }

  function decimals() public view virtual override returns (uint8) {
    return _decimals;
  }

  function mint(address to, uint256 amount) public virtual {
    _mint(to, amount);
  }

  function burn(address from, uint256 amount) public virtual {
    _burn(from, amount);
  }
}
