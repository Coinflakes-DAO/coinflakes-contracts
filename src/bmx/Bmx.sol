// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

import "@src/interfaces/IBmx.sol";
import "@src/interfaces/IBmxEscrow.sol";

import "@src/bmx/gmx/IRewardRouter.sol";
import "@src/bmx/gmx/IRewardTracker.sol";

contract BMX is IBmx, ERC721, Ownable {
  using Clones for address;
  using Counters for Counters.Counter;

  IRewardRouter public gmxRewardRouter = IRewardRouter(0xA906F338CB21815cBc4Bc87ace9e68c87eF8d8F1);
  address public immutable bmxEscrowImplementation;

  mapping(address => IBmxEscrow) private _pendingEscrows;

  mapping(uint256 => address) public escrows;

  Counters.Counter private _tokenIds;

  event CreateEscrow(address indexed escrow, address indexed owner);

  modifier onlyHolder(uint256 tokenId) {
    require(ownerOf(tokenId) == msg.sender, "BMX: caller is not the token holder");
    _;
  }

  constructor(address _escrowImpl) ERC721("BMX Token (esGMX Wrapper)", "BMX") {
    bmxEscrowImplementation = _escrowImpl;
  }

  function mint(address to) public {
    require(address(_pendingEscrows[msg.sender]) != address(0), "BMX: sender does not have a pending escrow");
    IBmxEscrow escrow = IBmxEscrow(_pendingEscrows[msg.sender]);
    _tokenIds.increment();
    uint256 tokenId = _tokenIds.current();
    escrow.acceptTransfer(msg.sender, tokenId);
    delete _pendingEscrows[msg.sender];
    escrows[tokenId] = address(escrow);
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
    gmxRewardRouter = IRewardRouter(_gmxRewardRouter);
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

  function compound(uint256 tokenId) public onlyOwner {
    IBmxEscrow(escrows[tokenId]).compound();
  }
}
