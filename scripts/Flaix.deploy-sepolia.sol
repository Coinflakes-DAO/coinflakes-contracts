// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "@src/flaix/FlaixVault.sol";
import "@src/flaix/FlaixCallOption.sol";
import "@src/flaix/FlaixPutOption.sol";
import "@src/flaix/FlaixOptionFactory.sol";
import "@src/utils/MockERC20.sol";

contract FlaixDeployLocal is Script {
  function run() public {
    uint deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);
    address mockErc20 = address(new MockERC20("Mock ERC20 Token", "MOCK", 18));
    console.log("MockERC20 deployed at: ", mockErc20);
    FlaixCallOption callOption = new FlaixCallOption();
    FlaixPutOption putOption = new FlaixPutOption();
    FlaixOptionFactory optionFactory = new FlaixOptionFactory(address(callOption), address(putOption));

    FlaixVault vault = new FlaixVault(address(optionFactory));
    console.log("FlaixVault deployed at: ", address(vault));
    vm.stopBroadcast();
  }
}
