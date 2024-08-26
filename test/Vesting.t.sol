// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Vesting} from "../src/Vesting.sol";
import {VestingCliff} from "../src/VestingCliff.sol";

import {IAkroToken} from "./IAkroToken.sol";

contract VestingTest is Test {
    Vesting public teamVestingMain;
    Vesting public teamVesting1;
    Vesting public teamVesting2;

    Vesting public foundationVesting;

    Vesting public ecosystemVestingMain;
    Vesting public ecosystemVesting1;
    Vesting public ecosystemVesting2;

    address constant oldMultisig = 0xC5aF91F7D10dDe118992ecf536Ed227f276EC60D;
    address constant multisig1 = 0xae4Af0301AFE8f352D2b47cbAc54E79528Ad91AE;
    address constant multisig2 = 0xd5a26CA4a9367035c3f18eBc9eA58FC53e0EB2E9;

    uint64 constant teamStartTimestamp = 1751500800; // 2025-07-03T00:00:00.000Z
    uint64 constant teamDurationSeconds = 94694400; // 2028-07-03T00:00:00.000Z - 2025-07-03T00:00:00.000Z

    uint64 constant startTimestamp = 1719964800; // 2024-07-03T00:00:00.000Z
    uint64 constant durationSeconds = 126230400; // 2028-07-03T00:00:00.000Z - 2024-07-03T00:00:00.000Z

    IAkroToken constant akroToken =
        IAkroToken(0x8Ab7404063Ec4DBcfd4598215992DC3F8EC853d7);

    function setUp() public {
        teamVestingMain = new Vesting(
            "",
            multisig1,
            teamStartTimestamp,
            teamDurationSeconds
        );
        teamVesting1 = new Vesting("kpi1", multisig2, startTimestamp, 1);
        teamVesting2 = new Vesting("kpi2", multisig2, startTimestamp, 1);

        foundationVesting = new Vesting(
            "",
            multisig1,
            startTimestamp,
            durationSeconds
        );

        ecosystemVestingMain = new Vesting(
            "",
            multisig1,
            startTimestamp,
            durationSeconds
        );
        ecosystemVesting1 = new Vesting("kpi1", multisig2, startTimestamp, 1);
        ecosystemVesting2 = new Vesting("kpi2", multisig2, startTimestamp, 1);
    }

    function test_contractsDeploy() public view {
        // Team Vesting Main
        assertEq(teamVestingMain.owner(), multisig1);
        assertEq(teamVestingMain.start(), teamStartTimestamp);
        assertEq(teamVestingMain.duration(), teamDurationSeconds);
        // Team Vesting 1
        assertEq(teamVesting1.owner(), multisig2);
        assertEq(teamVesting1.start(), startTimestamp);
        assertEq(teamVesting1.duration(), 1);
        // Team Vesting 2
        assertEq(teamVesting2.owner(), multisig2);
        assertEq(teamVesting2.start(), startTimestamp);
        assertEq(teamVesting2.duration(), 1);

        // Foundation Vesting
        assertEq(foundationVesting.owner(), multisig1);
        assertEq(foundationVesting.start(), startTimestamp);
        assertEq(foundationVesting.duration(), durationSeconds);

        // Ecosystem Vesting Main
        assertEq(ecosystemVestingMain.owner(), multisig1);
        assertEq(ecosystemVestingMain.start(), startTimestamp);
        assertEq(ecosystemVestingMain.duration(), durationSeconds);
        // Ecosystem Vesting 1
        assertEq(ecosystemVesting1.owner(), multisig2);
        assertEq(ecosystemVesting1.start(), startTimestamp);
        assertEq(ecosystemVesting1.duration(), 1);
        // Ecosystem Vesting 2
        assertEq(ecosystemVesting2.owner(), multisig2);
        assertEq(ecosystemVesting2.start(), startTimestamp);
        assertEq(ecosystemVesting2.duration(), 1);
    }

    function test_release() public {
        _logBalances();

        console.log("Mint inflation");
        _mintInflation();
        _logBalances();

        // After six months
        vm.warp(1735732800);
        console.log("Release after 6 months,  timestamp: %s", block.timestamp);
        _executeRelease();
        _logBalances();

        // After twelve months
        vm.warp(1751500800);
        console.log("Release after 12 months, timestamp: %s", block.timestamp);
        _executeRelease();
        _logBalances();

        // After two years
        vm.warp(1783036800);
        console.log("Release after 2 years, timestamp: %s", block.timestamp);
        _executeRelease();
        _logBalances();

        // After four years
        vm.warp(1846195200);
        console.log("Release after 4 years,   timestamp: %s", block.timestamp);
        _executeRelease();
        _logBalances();
    }

    function _mintInflation() internal {
        vm.startPrank(oldMultisig);
        akroToken.transferOwnership(multisig2);
        vm.stopPrank();

        vm.startPrank(multisig2);
        akroToken.claimOwnership();
        akroToken.mint(address(teamVestingMain), 1_500_000_000);
        akroToken.mint(address(teamVesting1), 250_000_000);
        akroToken.mint(address(teamVesting2), 250_000_000);
        akroToken.mint(address(foundationVesting), 900_000_000);
        akroToken.mint(address(ecosystemVestingMain), 5_100_000_000);
        akroToken.mint(address(ecosystemVesting1), 450_000_000);
        akroToken.mint(address(ecosystemVesting2), 450_000_000);
        akroToken.mint(multisig2, 100_000_000);
        akroToken.mint(multisig2, 500_000_000);
        akroToken.mint(multisig2, 500_000_000);
        vm.stopPrank();
    }

    function _executeRelease() internal {
        address _akro = address(akroToken);

        vm.startPrank(multisig2);
        teamVesting1.release(_akro);
        teamVesting2.release(_akro);
        ecosystemVesting1.release(_akro);
        ecosystemVesting2.release(_akro);
        vm.stopPrank();

        vm.startPrank(multisig1);
        teamVestingMain.release(_akro);
        foundationVesting.release(_akro, 50000000);
        foundationVesting.release(_akro);
        ecosystemVestingMain.release(_akro);
        vm.stopPrank();
    }

    function _logBalances() internal view {
        IERC20 akro = IERC20(address(akroToken));

        console.log("");
        console.log("Balances snapshot:");
        console.log("- Multisig #1:           %s", akro.balanceOf(multisig1));
        console.log("- Multisig #2:           %s", akro.balanceOf(multisig2));
        console.log(
            "- teamVestingMain:       %s",
            akro.balanceOf(address(teamVestingMain))
        );
        console.log(
            "- teamVesting1:          %s",
            akro.balanceOf(address(teamVesting1))
        );
        console.log(
            "- teamVesting2:          %s",
            akro.balanceOf(address(teamVesting2))
        );
        console.log(
            "- foundationVesting:     %s",
            akro.balanceOf(address(foundationVesting))
        );
        console.log(
            "- ecosystemVestingMain:  %s",
            akro.balanceOf(address(ecosystemVestingMain))
        );
        console.log(
            "- ecosystemVesting1:     %s",
            akro.balanceOf(address(ecosystemVesting1))
        );
        console.log(
            "- ecosystemVesting2:     %s",
            akro.balanceOf(address(ecosystemVesting2))
        );
        console.log("");
    }
}
