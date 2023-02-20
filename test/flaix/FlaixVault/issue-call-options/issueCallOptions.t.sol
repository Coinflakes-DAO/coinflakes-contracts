// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IssueCallOptionsBase.t.sol";

contract IssueCallOptions_Test is IssueCallOptionsBase_Test {
  function test_whenCalledWithValidParameters_returnsAddress()
    public
    whenDaiIsAllowed
    whenAdminHasDai(1000e18)
    whenAdminHasApprovedDai(1000e18)
  {
    uint limit = vault.minimalOptionsMaturity();
    vm.prank(users.admin);
    address options = vault.issueCallOptions(
      "FLAIX Call Options 2023-01-01",
      "callFLAIX-230101",
      1000e18,
      users.admin,
      address(tokens.dai),
      1000e18,
      block.timestamp + limit
    );
    assertFalse(options == address(0));
  }

  event IssueCallOptions(
    address indexed options,
    address indexed recipient,
    string name,
    string symbol,
    uint256 amount,
    address indexed asset,
    uint256 assetAmount,
    uint256 maturity
  );

  function test_whenCalledWithValidParameters_emitsEvent()
    public
    whenDaiIsAllowed
    whenAdminHasDai(1000e18)
    whenAdminHasApprovedDai(1000e18)
  {
    uint limit = vault.minimalOptionsMaturity();
    vm.prank(users.admin);
    vm.expectEmit(false, false, false, false);
    emit IssueCallOptions(
      address(0),
      users.admin,
      "FLAIX Call Options 2023-01-01",
      "callFLAIX-230101",
      1000e18,
      address(tokens.dai),
      1000e18,
      block.timestamp + limit
    );
    vault.issueCallOptions(
      "FLAIX Call Options 2023-01-01",
      "callFLAIX-230101",
      1000e18,
      users.admin,
      address(tokens.dai),
      1000e18,
      block.timestamp + limit
    );
  }

  function test_whenCalledWithValidParameters_mintsShares()
    public
    whenDaiIsAllowed
    whenAdminHasDai(1000e18)
    whenAdminHasApprovedDai(1000e18)
  {
    uint limit = vault.minimalOptionsMaturity();
    vm.prank(users.admin);
    address options = vault.issueCallOptions(
      "FLAIX Call Options 2023-01-01",
      "callFLAIX-230101",
      1000e18,
      users.admin,
      address(tokens.dai),
      1000e18,
      block.timestamp + limit
    );
    assertEq(vault.balanceOf(options), 1000e18);
    assertEq(vault.totalSupply(), 1000e18);
  }

  function test_whenCalledWithValidParameters_transfersAssetsToOptions()
    public
    whenDaiIsAllowed
    whenAdminHasDai(1000e18)
    whenAdminHasApprovedDai(1000e18)
  {
    uint limit = vault.minimalOptionsMaturity();
    vm.prank(users.admin);
    address options = vault.issueCallOptions(
      "FLAIX Call Options 2023-01-01",
      "callFLAIX-230101",
      1000e18,
      users.admin,
      address(tokens.dai),
      1000e18,
      block.timestamp + limit
    );
    assertEq(tokens.dai.balanceOf(users.admin), 0);
    assertEq(tokens.dai.balanceOf(options), 1000e18);
  }
}
