// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@src/interfaces/gmx/staking/IRewardRouterV2.sol";
import "@src/interfaces/gmx/staking/IRewardTracker.sol";
import "../BmxBase.t.sol";

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract BmxToken_Test is BmxBase_Test {
  function setUp() public virtual override {
    super.setUp();
  }

  function test_firstTry() public {
    IRewardRouterV2 gmxRewardRouter = IRewardRouterV2(bmx.gmxRewardRouter());

    address gmx = gmxRewardRouter.gmx();
    address esGmx = gmxRewardRouter.esGmx();
    address bnGmx = gmxRewardRouter.bnGmx();

    IRewardTracker stakedTracker = IRewardTracker(gmxRewardRouter.stakedGmxTracker());
    log_RewardTracker(stakedTracker, gmxUser1, gmx);
    log_RewardTracker(stakedTracker, gmxUser1, esGmx);

    IRewardTracker bonusTracker = IRewardTracker(gmxRewardRouter.bonusGmxTracker());
    log_RewardTracker(bonusTracker, gmxUser1, address(stakedTracker));

    IRewardTracker feeTracker = IRewardTracker(gmxRewardRouter.feeGmxTracker());
    log_RewardTracker(feeTracker, gmxUser1, address(bonusTracker));
    log_RewardTracker(feeTracker, gmxUser1, address(bnGmx));

    vm.startPrank(gmxUser1);
    address escrow = bmx.createEscrow();
    gmxRewardRouter.signalTransfer(escrow);
    bmx.mint(gmxUser1);
    vm.stopPrank();
    assertEq(bmx.balanceOf(gmxUser1), 1);
    assertEq(bmx.escrows(1), escrow);

    emit log("----");
    emit log_named_decimal_uint("bmx.stakedGmxBalance()", bmx.stakedGmxBalance(1), 18);
    emit log_named_decimal_uint("bmx.stakedEsGmxBalance()", bmx.stakedEsGmxBalance(1), 18);
    emit log_named_decimal_uint("bmx.stakedBonusGmxBalance()", bmx.stakedBonusGmxBalance(1), 18);

    emit log("----");
    emit log_named_decimal_uint("bmx.claimableEsGmx()", bmx.claimableEsGmx(1), 18);
    emit log_named_decimal_uint("bmx.claimableBonusGmx()", bmx.claimableBonusGmx(1), 18);
    emit log_named_decimal_uint("bmx.claimableEth()", bmx.claimableEth(1), 18);
  }

  function log_RewardTracker(IRewardTracker tracker, address account, address asset) public {
    emit log("----");
    emit log_named_string("name(): ", IERC20Metadata(address(tracker)).name());
    emit log_named_string("symbol(): ", IERC20Metadata(address(tracker)).symbol());
    emit log_named_string("asset: ", IERC20Metadata(address(asset)).symbol());
    emit log_named_decimal_uint("depositedBalances(): ", tracker.depositBalances(account, asset), 18);
    emit log_named_decimal_uint("claimable(): ", tracker.claimable(account), 18);
  }
}
