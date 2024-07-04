// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Vesting} from "../src/Vesting.sol";
import {VestingCliff} from "../src/VestingCliff.sol";

import {IAkroToken} from "./IAkroToken.sol";

contract VestingTest is Test {
    VestingCliff public teamVesting;
    Vesting public foundationVesting;
    Vesting public ecosystemVesting;

    address constant multisig = 0xC5aF91F7D10dDe118992ecf536Ed227f276EC60D;
    address constant beneficiary = 0xC5aF91F7D10dDe118992ecf536Ed227f276EC60D;
    uint64 constant startTimestamp = 1719964800;
    uint64 constant durationSeconds = 126230400;
    uint64 constant cliffSeconds = 31536000;

    uint256 constant teamVestingAmount = 2000000000;
    uint256 constant foundationVestingAmount = 900000000;
    uint256 constant ecosystemVestingAmount = 6000000000;

    IAkroToken constant akroToken =
        IAkroToken(0x8Ab7404063Ec4DBcfd4598215992DC3F8EC853d7);

    function setUp() public {
        teamVesting = new VestingCliff(
            beneficiary, startTimestamp, durationSeconds, cliffSeconds
        );
        foundationVesting =
            new Vesting(beneficiary, startTimestamp, durationSeconds);

        ecosystemVesting =
            new Vesting(beneficiary, startTimestamp, durationSeconds);

        vm.startPrank(multisig);
        akroToken.mint(address(teamVesting), teamVestingAmount);
        akroToken.mint(address(foundationVesting), foundationVestingAmount);
        akroToken.mint(address(ecosystemVesting), ecosystemVestingAmount);
        vm.stopPrank();
    }

    function test_contractsDeploy() public view {
        // Vesting cliff
        assertEq(teamVesting.owner(), beneficiary);
        assertEq(teamVesting.start(), startTimestamp);
        assertEq(teamVesting.duration(), durationSeconds);
        assertEq(teamVesting.cliff(), startTimestamp + cliffSeconds);

        // Vesting #1
        assertEq(foundationVesting.owner(), beneficiary);
        assertEq(foundationVesting.start(), startTimestamp);
        assertEq(foundationVesting.duration(), durationSeconds);

        // Vesting #2
        assertEq(ecosystemVesting.owner(), beneficiary);
        assertEq(ecosystemVesting.start(), startTimestamp);
        assertEq(ecosystemVesting.duration(), durationSeconds);
    }

    function test_release() public {
        address _akro = address(akroToken);

        _log_deploy_params();

        // After six months
        vm.warp(1735732800);
        console.log("Release after 6 months,  timestamp: %s", block.timestamp);
        _executeRelease(_akro);

        // After twelve months
        vm.warp(1751500800);
        console.log("Release after 12 months, timestamp: %s", block.timestamp);
        _executeRelease(_akro);

        // After four years
        vm.warp(1846195200);
        console.log("Release after 4 years,   timestamp: %s", block.timestamp);
        _executeRelease(_akro);
    }

    function _executeRelease(address _akro) internal {
        _log_release(_akro);

        teamVesting.release(_akro);
        foundationVesting.release(_akro);
        ecosystemVesting.release(_akro);
    }

    function _log_deploy_params() internal pure {
        console.log("");
        console.log("Vesting params:");
        console.log("  - beneficiary:      %s", beneficiary);
        console.log("  - vesting start:    %s", startTimestamp);
        console.log("  - vesting duration: %s", durationSeconds);
        console.log("  - cliff duration:   %s", cliffSeconds);
        console.log("");
        console.log("Mint amounts:");
        console.log("  - Team:       %s", teamVestingAmount);
        console.log("  - Foundation: %s", foundationVestingAmount);
        console.log("  - Ecosystem:  %s", ecosystemVestingAmount);
        console.log("");
    }

    function _log_release(address _akro) internal view {
        uint256 teamReleseable = teamVesting.releasable(_akro);
        uint256 foundationReleseable = foundationVesting.releasable(_akro);
        uint256 ecosystemReleseable = ecosystemVesting.releasable(_akro);

        console.log("  - Team:       %s", teamReleseable);
        console.log("  - Foundation: %s", foundationReleseable);
        console.log("  - Ecosystem:  %s", ecosystemReleseable);
        console.log("");
    }
}
