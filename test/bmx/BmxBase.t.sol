// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@test/mocks/WETH.sol";

import "@src/interfaces/gmx/staking/IRewardRouterV2.sol";
import "@src/interfaces/gmx/staking/IRewardTracker.sol";

import "@test/mocks/gmx/staking/RewardTracker.sol";
import "@test/mocks/gmx/staking/RewardRouterV2.sol";
import "@test/mocks/gmx/staking/RewardDistributor.sol";
import "@test/mocks/gmx/staking/Vester.sol";

import "@src/bmx/Bmx.sol";
import "@src/bmx/BmxEscrow.sol";

import "../Base.t.sol";

contract BmxBase_Test is Base_Test {
  WETH public weth;
  MockERC20 public gmx;
  MockERC20 public esGmx;
  MockERC20 public bnGmx;
  MockERC20 public glp;

  RewardTracker public stakedGmxTracker;
  RewardTracker public bonusGmxTracker;
  RewardTracker public feeGmxTracker;
  RewardTracker public feeGlpTracker;
  RewardTracker public stakedGlpTracker;

  RewardDistributor public stakedGmxDistributor;
  RewardDistributor public bonusGmxDistributor;
  RewardDistributor public feeGmxDistributor;
  RewardDistributor public feeGlpDistributor;
  RewardDistributor public stakedGlpDistributor;

  Vester public gmxVester;
  Vester public glpVester;

  IRewardRouterV2 public rewardRouter;

  BMX public bmx;

  function setUp() public virtual override {
    super.setUp();
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
    setUp_GmxTokens();
    setUp_GmxRewardTrackers();
    setUp_GmxVesters();
    setUp_GmxRewardRouter();
  }

  function setUp_GmxRewardRouter() public virtual {
    vm.startPrank(users.admin);
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
      address(gmxVester),
      address(glpVester)
    );

    stakedGmxTracker.setHandler(address(rewardRouter), true);
    bonusGmxTracker.setHandler(address(rewardRouter), true);
    feeGmxTracker.setHandler(address(rewardRouter), true);
    feeGlpTracker.setHandler(address(rewardRouter), true);
    stakedGlpTracker.setHandler(address(rewardRouter), true);
    gmxVester.setHandler(address(rewardRouter), true);
    glpVester.setHandler(address(rewardRouter), true);

    vm.stopPrank();
  }

  function setUp_GmxTokens() public {
    vm.startPrank(users.admin);
    gmx = new MockERC20("GMX (GMX)", "GMX", 18);
    esGmx = new MockERC20("Escrowed GMX (esGMX)", "esGM", 18);
    bnGmx = new MockERC20("Bonus GMX (bnGMX)", "bnGM", 18);
    glp = new MockERC20("GMX LP (GLP)", "GLP", 18);
    vm.stopPrank();
  }

  function setUp_GmxRewardTrackers() public {
    vm.startPrank(users.admin);
    address[] memory depositTokens = new address[](2);

    stakedGmxTracker = new RewardTracker("Staked GMX (sGMX)", "sGMX");
    depositTokens[0] = address(gmx);
    depositTokens[1] = address(esGmx);

    bonusGmxTracker = new RewardTracker("Staked + Bonus GMX (sbGMX)", "sbGMX");
    depositTokens = new address[](1);
    depositTokens[0] = address(stakedGmxTracker);

    feeGmxTracker = new RewardTracker("Staked + Bonus - Fee GMX (sbfGMX)", "sbfGMX");
    depositTokens = new address[](2);
    depositTokens[0] = address(bonusGmxTracker);
    depositTokens[1] = address(bnGmx);

    feeGlpTracker = new RewardTracker("Fee GLP (fGLP)", "fGLP");
    depositTokens = new address[](1);
    depositTokens[0] = address(glp);

    stakedGlpTracker = new RewardTracker("Fee + Staked GLP (fsGLP)", "fsGLP");
    depositTokens = new address[](1);
    depositTokens[0] = address(feeGlpTracker);
    vm.stopPrank();

    setUp_GmxRewardDistributors();

    vm.startPrank(users.admin);
    stakedGmxTracker.initialize(depositTokens, address(stakedGmxDistributor));
    bonusGmxTracker.initialize(depositTokens, address(bonusGmxDistributor));
    feeGmxTracker.initialize(depositTokens, address(feeGmxDistributor));
    feeGlpTracker.initialize(depositTokens, address(feeGlpDistributor));
    stakedGlpTracker.initialize(depositTokens, address(stakedGlpDistributor));

    vm.stopPrank();
  }

  function setUp_GmxRewardDistributors() public virtual {
    vm.startPrank(users.admin);
    stakedGmxDistributor = new RewardDistributor(address(esGmx), address(stakedGmxTracker));
    stakedGmxDistributor.updateLastDistributionTime();
    bonusGmxDistributor = new RewardDistributor(address(bnGmx), address(bonusGmxTracker));
    bonusGmxDistributor.updateLastDistributionTime();
    feeGmxDistributor = new RewardDistributor(address(weth), address(feeGmxTracker));
    feeGmxDistributor.updateLastDistributionTime();
    feeGlpDistributor = new RewardDistributor(address(weth), address(feeGlpTracker));
    feeGlpDistributor.updateLastDistributionTime();
    stakedGlpDistributor = new RewardDistributor(address(esGmx), address(stakedGlpTracker));
    stakedGlpDistributor.updateLastDistributionTime();
    vm.stopPrank();
  }

  function setUp_GmxVesters() public {
    vm.startPrank(users.admin);
    gmxVester = new Vester(
      "Vested GMX",
      "vGMX",
      365 days,
      address(esGmx),
      address(feeGmxTracker),
      address(gmx),
      address(stakedGmxTracker)
    );

    glpVester = new Vester(
      "Vested GLP",
      "vGLP",
      365 days,
      address(esGmx),
      address(stakedGlpTracker),
      address(gmx),
      address(stakedGlpTracker)
    );
    vm.stopPrank();
  }

  function setUp_GmxUsers() public {
    gmx.mint(users.alice, 200 ether);
    esGmx.mint(users.alice, 100 ether);
    bnGmx.mint(users.alice, 2 ether);
  }

  function setUp_Bmx() public virtual {
    address escrowImpl = address(new BmxEscrow());
    bmx = new BMX(address(rewardRouter), escrowImpl);
  }
}
