// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/vote.sol";

contract DeployVote is Script {
    function run() public {
        // Get the private key from the environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the contract
        AnonymousVoting voting = new AnonymousVoting();

        vm.stopBroadcast();

        // Log the deployed contract address
        console.log("AnonymousVoting deployed at:", address(voting));
    }
} 