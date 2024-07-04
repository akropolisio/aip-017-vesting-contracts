// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";

import {VestingCliff} from "../src/VestingCliff.sol";
import {Vesting} from "../src/Vesting.sol";

contract DeployAIP_017Script is Script {
    address constant beneficiary = 0xC5aF91F7D10dDe118992ecf536Ed227f276EC60D;
    uint64 constant startTimestamp = 1719964800;
    uint64 constant durationSeconds = 126230400;
    uint64 constant cliffSeconds = 31536000;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy Team vesting
        VestingCliff teamVesting = new VestingCliff(
            beneficiary, startTimestamp, durationSeconds, cliffSeconds
        );

        // 2. Deploy Foundation vesting
        Vesting foundationVesting =
            new Vesting(beneficiary, startTimestamp, durationSeconds);

        // 2. Deploy Ecosystem vesting
        Vesting ecosystemVesting =
            new Vesting(beneficiary, startTimestamp, durationSeconds);

        vm.stopBroadcast();

        console.log("Team vesting:       %s", address(teamVesting));
        console.log("Foundation vesting: %s", address(foundationVesting));
        console.log("Ecosystem vesting:  %s", address(ecosystemVesting));
    }
}
