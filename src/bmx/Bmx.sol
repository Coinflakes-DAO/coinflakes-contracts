// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

import "@src/interfaces/IBmx.sol";
import "@src/interfaces/IBmxEscrow.sol";

contract BMX is IBmx, ERC721, Ownable {
  using Clones for address;
  using Counters for Counters.Counter;

  address public gmxRewardRouter = 0xA906F338CB21815cBc4Bc87ace9e68c87eF8d8F1;
  address public immutable bmxEscrowImplementation;

  mapping(address => IBmxEscrow) private _pendingEscrows;

  mapping(uint256 => IBmxEscrow) private _escrows;

  Counters.Counter private _tokenIds;

  event CreateEscrow(address indexed escrow, address indexed owner);

  constructor(address _escrowImpl) ERC721("BMX Token (esGMX Wrapper)", "BMX") {
    bmxEscrowImplementation = _escrowImpl;
  }

  function mint(address to) public {
    require(address(_pendingEscrows[msg.sender]) != address(0), "BMX: sender does not have a pending escrow");
    IBmxEscrow _escrow = IBmxEscrow(_pendingEscrows[msg.sender]);
    _tokenIds.increment();
    uint256 tokenId = _tokenIds.current();
    _escrow.acceptTransfer(msg.sender, tokenId);
    delete _pendingEscrows[msg.sender];
    _mint(to, tokenId);
  }

  function createEscrow() public returns (address) {
    require(address(_pendingEscrows[msg.sender]) == address(0), "BMX: sender already has a pending escrow");
    IBmxEscrow _escrow = IBmxEscrow(bmxEscrowImplementation.clone());
    _escrow.initialize(address(this));
    _pendingEscrows[msg.sender] = _escrow;
    emit CreateEscrow(address(_escrow), msg.sender);
    return address(_escrow);
  }

  function getPendingEscrow(address sender) public view returns (address) {
    return address(_pendingEscrows[sender]);
  }

  function setGmxRewardRouter(address _gmxRewardRouter) public onlyOwner {
    gmxRewardRouter = _gmxRewardRouter;
  }

  function escrow(uint256 tokenId) public view returns (address) {
    return address(_escrowOf(tokenId));
  }

  function _escrowOf(uint256 tokenId) internal view returns (IBmxEscrow) {
    return _escrows[tokenId];
  }
}
