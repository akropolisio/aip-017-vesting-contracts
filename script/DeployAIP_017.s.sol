// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";

import {Vesting} from "../src/Vesting.sol";

contract DeployAIP_017Script is Script {
    address constant multisig1 = 0xae4Af0301AFE8f352D2b47cbAc54E79528Ad91AE;
    address constant multisig2 = 0xd5a26CA4a9367035c3f18eBc9eA58FC53e0EB2E9;

    uint64 constant teamStartTimestamp = 1751500800; // 2025-07-03T00:00:00.000Z
    uint64 constant teamDurationSeconds = 94694400; // 2028-07-03T00:00:00.000Z - 2025-07-03T00:00:00.000Z

    uint64 constant startTimestamp = 1719964800; // 2024-07-03T00:00:00.000Z
    uint64 constant durationSeconds = 126230400; // 2028-07-03T00:00:00.000Z - 2024-07-03T00:00:00.000Z

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        Vesting teamVestingMain = new Vesting(
            "",
            multisig1,
            teamStartTimestamp,
            teamDurationSeconds
        );
        Vesting teamVesting1 = new Vesting("kpi1", multisig2, startTimestamp, 1);
        Vesting teamVesting2 = new Vesting("kpi2", multisig2, startTimestamp, 1);

        Vesting foundationVesting = new Vesting(
            "",
            multisig1,
            startTimestamp,
            durationSeconds
        );

        Vesting ecosystemVestingMain = new Vesting(
            "",
            multisig1,
            startTimestamp,
            durationSeconds
        );
        Vesting ecosystemVesting1 = new Vesting("kpi1", multisig2, startTimestamp, 1);
        Vesting ecosystemVesting2 = new Vesting("kpi2", multisig2, startTimestamp, 1);

        vm.stopBroadcast();

        console.log("Team vesting main:       %s", address(teamVestingMain));
        console.log("Team vesting 1:          %s", address(teamVesting1));
        console.log("Team vesting 2:          %s", address(teamVesting2));
        console.log("Foundation vesting:      %s", address(foundationVesting));
        console.log("Ecosystem vesting main:  %s", address(ecosystemVestingMain));
        console.log("Ecosystem vesting 1:     %s", address(ecosystemVesting1));
        console.log("Ecosystem vesting 2:     %s", address(ecosystemVesting2));
    }
}
