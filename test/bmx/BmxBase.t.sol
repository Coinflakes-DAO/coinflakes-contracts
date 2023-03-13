// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@test/mocks/WETH.sol";

import "@src/interfaces/gmx/staking/IRewardRouterV2.sol";
import "@src/interfaces/gmx/staking/IRewardTracker.sol";

import "@test/mocks/gmx/staking/RewardTracker.sol";
import "@test/mocks/gmx/staking/RewardRouterV2.sol";

import "@src/bmx/Bmx.sol";
import "@src/bmx/BmxEscrow.sol";

import "../Base.t.sol";

contract BmxBase_Test is Base_Test {
  address public immutable gmxUser1 = 0x0A7577e60e4dF5d060FD267194cF6116f38350eC;
  address public immutable gmxUser2 = 0x5A22b08D884DAAb9E9B8c36A86AA2cF6cDa7f899;

  WETH public weth;
  MockERC20 public gmx;
  MockERC20 public esGmx;
  MockERC20 public bnGmx;
  MockERC20 public glp;

  IRewardRouterV2 public rewardRouter;

  BMX public bmx;

  function setUp() public virtual override {
    super.setUp();
    string memory url = vm.envString("ARBITRUM_FORK_URL");
    vm.createSelectFork(url);
    setUp_users();
    setUp_Weth();
    setUp_Gmx();
    setUp_Bmx();
  }

  function setUp_users() public virtual override {
    super.setUp_users();
  }

  function setUp_Weth() public virtual {
    weth = new WETH();
  }

  function setUp_Gmx() public virtual {
    vm.startPrank(users.admin);
    gmx = new MockERC20("GMX (GMX)", "GMX", 18);
    esGmx = new MockERC20("Escrowed GMX (esGMX)", "esGM", 18);
    bnGmx = new MockERC20("Bonus GMX (bnGMX)", "bnGM", 18);
    glp = new MockERC20("GMX LP (GLP)", "GLP", 18);
    address[] memory depositTokens = new address[](2);

    RewardTracker stakedGmxTracker = new RewardTracker("Staked GMX (sGMX)", "sGMX");
    depositTokens[0] = address(gmx);
    depositTokens[1] = address(esGmx);
    stakedGmxTracker.initialize(depositTokens, address(0));

    RewardTracker bonusGmxTracker = new RewardTracker("Staked + Bonus GMX (sbGMX)", "sbGMX");
    depositTokens = new address[](1);
    depositTokens[0] = address(stakedGmxTracker);
    bonusGmxTracker.initialize(depositTokens, address(0));

    RewardTracker feeGmxTracker = new RewardTracker("Staked + Bonus - Fee GMX (sbfGMX)", "sbfGMX");
    depositTokens = new address[](2);
    depositTokens[0] = address(bonusGmxTracker);
    depositTokens[1] = address(bnGmx);
    feeGmxTracker.initialize(depositTokens, address(0));

    RewardTracker feeGlpTracker = new RewardTracker("Fee GLP (fGLP)", "fGLP");
    depositTokens = new address[](1);
    depositTokens[0] = address(glp);
    feeGlpTracker.initialize(depositTokens, address(0));

    RewardTracker stakedGlpTracker = new RewardTracker("Fee + Staked GLP (fsGLP)", "fsGLP");
    depositTokens = new address[](1);
    depositTokens[0] = address(feeGlpTracker);
    stakedGlpTracker.initialize(depositTokens, address(0));

    rewardRouter = new RewardRouterV2();
    RewardRouterV2(payable(address(rewardRouter))).initialize(
      address(weth),
      address(gmx),
      address(esGmx),
      address(bnGmx),
      address(glp),
      address(stakedGmxTracker),
      address(bonusGmxTracker),
      address(feeGmxTracker),
      address(feeGlpTracker),
      address(stakedGlpTracker),
      address(0),
      address(0),
      address(0)
    );

    vm.stopPrank();
  }

  function setUp_Bmx() public virtual {
    address escrowImpl = address(new BmxEscrow());
    bmx = new BMX(escrowImpl);
  }
}
