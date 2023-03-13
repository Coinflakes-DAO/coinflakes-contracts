// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

import "@src/interfaces/IBmx.sol";
import "@src/interfaces/IBmxEscrow.sol";

import "@src/interfaces/gmx/staking/IRewardTracker.sol";
import "@src/interfaces/gmx/staking/IRewardRouterV2.sol";

contract BMX is IBmx, ERC721, Ownable {
  using Clones for address;
  using Counters for Counters.Counter;

  IRewardRouterV2 public gmxRewardRouter = IRewardRouterV2(0xA906F338CB21815cBc4Bc87ace9e68c87eF8d8F1);
  address public immutable bmxEscrowImplementation;

  mapping(address => IBmxEscrow) public pendingEscrows;

  mapping(uint256 => address) public escrows;

  Counters.Counter private tokenIds;

  event CreateEscrow(address indexed escrow, address indexed owner);

  modifier onlyHolder(uint256 tokenId) {
    require(ownerOf(tokenId) == msg.sender, "BMX: caller is not the token holder");
    _;
  }

  constructor(address gmxRewardRouter_, address escrowImpl) ERC721("BMX Token (esGMX Wrapper)", "BMX") {
    require(escrowImpl != address(0), "BMX: escrow implementation cannot be zero address");
    gmxRewardRouter = IRewardRouterV2(gmxRewardRouter_);
    bmxEscrowImplementation = escrowImpl;
  }

  function mint(address to) public {
    require(address(pendingEscrows[msg.sender]) != address(0), "BMX: sender does not have a pending escrow");
    IBmxEscrow escrow = IBmxEscrow(pendingEscrows[msg.sender]);
    delete pendingEscrows[msg.sender];
    tokenIds.increment();
    uint256 tokenId = tokenIds.current();
    escrows[tokenId] = address(escrow);
    escrow.acceptTransfer(msg.sender, tokenId);
    _mint(to, tokenId);
  }

  function createEscrow() public returns (address) {
    require(address(pendingEscrows[msg.sender]) == address(0), "BMX: sender already has a pending escrow");
    IBmxEscrow escrow = IBmxEscrow(bmxEscrowImplementation.clone());
    pendingEscrows[msg.sender] = escrow;
    emit CreateEscrow(address(escrow), msg.sender);
    escrow.initialize(address(this));
    return address(escrow);
  }

  function setGmxRewardRouter(address gmxRewardRouter_) public onlyOwner {
    gmxRewardRouter = IRewardRouterV2(gmxRewardRouter_);
  }

  function stakedGmxBalance(uint256 tokenId) public view returns (uint256) {
    require(_exists(tokenId), "BMX: nonexistent token");
    address gmx = gmxRewardRouter.gmx();
    IRewardTracker stakedGmxTracker = IRewardTracker(gmxRewardRouter.stakedGmxTracker());
    return stakedGmxTracker.depositBalances(escrows[tokenId], gmx);
  }

  function stakedEsGmxBalance(uint256 tokenId) public view returns (uint256) {
    require(_exists(tokenId), "BMX: nonexistent token");
    address esGmx = gmxRewardRouter.esGmx();
    IRewardTracker stakedGmxTracker = IRewardTracker(gmxRewardRouter.stakedGmxTracker());
    return stakedGmxTracker.depositBalances(escrows[tokenId], esGmx);
  }

  function stakedBonusGmxBalance(uint256 tokenId) public view returns (uint256) {
    require(_exists(tokenId), "BMX: nonexistent token");
    address bnGmx = gmxRewardRouter.bnGmx();
    IRewardTracker feeGmxTracker = IRewardTracker(gmxRewardRouter.feeGmxTracker());
    return feeGmxTracker.depositBalances(escrows[tokenId], bnGmx);
  }

  function totalStakedGmxBalance(uint256 tokenId) public view returns (uint256) {
    return stakedGmxBalance(tokenId) + stakedEsGmxBalance(tokenId) + stakedBonusGmxBalance(tokenId);
  }

  function claimableEsGmx(uint256 tokenId) public view returns (uint256) {
    require(_exists(tokenId), "BMX: nonexistent token");
    IRewardTracker stakedGmxTracker = IRewardTracker(gmxRewardRouter.stakedGmxTracker());
    return stakedGmxTracker.claimable(escrows[tokenId]);
  }

  function claimableBonusGmx(uint256 tokenId) public view returns (uint256) {
    require(_exists(tokenId), "BMX: nonexistent token");
    IRewardTracker bonusGmxTracker = IRewardTracker(gmxRewardRouter.bonusGmxTracker());
    return bonusGmxTracker.claimable(escrows[tokenId]);
  }

  function claimableEth(uint256 tokenId) public view returns (uint256) {
    require(_exists(tokenId), "BMX: nonexistent token");
    IRewardTracker feeGmxTracker = IRewardTracker(gmxRewardRouter.feeGmxTracker());
    return feeGmxTracker.claimable(escrows[tokenId]);
  }
}
