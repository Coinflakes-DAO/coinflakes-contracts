// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "forge-std/Script.sol";
import "@src/flaix/FlaixVault.sol";
import "@src/flaix/FlaixCallOption.sol";
import "@src/flaix/FlaixPutOption.sol";
import "@src/flaix/FlaixOptionFactory.sol";
import "@src/flaix/FlaixTestGov.sol";
import "@test/mocks/MockERC20.sol";

contract FlaixDeploySepolia is Script {
  function run() public {
    uint deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    address mockErc20 = address(new MockERC20("Alpha AI", "alphaAI", 18));
    console.log("Alpha AI deployed at: ", mockErc20);
    mockErc20 = address(new MockERC20("Beta AI", "betaAI", 18));
    console.log("Beta AI deployed at: ", mockErc20);
    mockErc20 = address(new MockERC20("Gamma AI", "gammaAI", 18));
    console.log("Gamma AI deployed at: ", mockErc20);

    FlaixCallOption callOption = new FlaixCallOption();
    FlaixPutOption putOption = new FlaixPutOption();
    FlaixOptionFactory optionFactory = new FlaixOptionFactory(address(callOption), address(putOption));

    FlaixVault vault = new FlaixVault(address(optionFactory));
    console.log("FlaixVault deployed at: ", address(vault));

    FlaixTestGov gov = new FlaixTestGov(address(vault));
    console.log("FlaixTestGov deployed at: ", address(gov));
    vault.changeAdmin(address(gov));

    vm.stopBroadcast();
  }
}
