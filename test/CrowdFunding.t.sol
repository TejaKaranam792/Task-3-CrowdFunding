// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {CrowdFunding} from "../src/CrowdFunding.sol";

contract CrowdFundingTest is Test {
    CrowdFunding public crowdFunding;

    address public creator = address(1);
    address public Teja = address(2);
    address public Sam = address(3);

    function setUp() public {
        vm.startPrank(creator);
        crowdFunding = new CrowdFunding(1000, 3600);
        vm.stopPrank();
    }

    function testContribute() public {
        vm.deal(Teja, 5000);
        vm.prank(Teja);
        crowdFunding.contribute{value: 500}();

        assertEq(crowdFunding.totalRaised(), 500);
        assertEq(crowdFunding.contributions(Teja), 500);
    }

    function testContributeRevert() public {
        vm.deal(Teja, 100);
        vm.prank(Teja);
        vm.expectRevert();
        crowdFunding.contribute{value: 0}();
    }

    function testFinalizeSuccess() public {
        vm.deal(Sam, 1000);
        vm.prank(Sam);
        crowdFunding.contribute{value: 1000}();

        vm.warp(block.timestamp + 3601);
        crowdFunding.finalize();

        assertEq(uint(crowdFunding.state()), 2);
    }

    function testContributeAfterDeadlineRevert() public {
        vm.deal(Teja, 500);
        vm.warp(block.timestamp + 3601);

        vm.prank(Teja);
        vm.expectRevert();
        crowdFunding.contribute{value: 500}();
    }

    function testFinalizeFailed() public {
        vm.deal(Teja, 1000);
        vm.prank(Teja);
        crowdFunding.contribute{value: 500}();

        vm.warp(block.timestamp + 3601);
        crowdFunding.finalize();

        assertEq(uint(crowdFunding.state()), 1); // Failed
    }

    function testFinalizeBeforeDeadlineRevert() public {
        vm.deal(Teja, 1000);
        vm.prank(Teja);
        crowdFunding.contribute{value: 500}();

        vm.warp(block.timestamp + 3500);
        vm.expectRevert();
        crowdFunding.finalize();
    }

    function testWithdrawRevert() public {
        vm.prank(Teja);
        vm.expectRevert();
        crowdFunding.withdraw();
    }

    function testWithdrawSuccess() public {
        vm.deal(Sam, 1000);
        vm.prank(Sam);
        crowdFunding.contribute{value: 1000}();

        vm.warp(block.timestamp + 3601);
        crowdFunding.finalize();

        vm.prank(creator);
        crowdFunding.withdraw();

        assertEq(address(crowdFunding).balance, 0);
    }

    function testRefund() public {
        vm.deal(Sam, 100);
        vm.prank(Sam);
        crowdFunding.contribute{value: 100}();

        vm.warp(block.timestamp + 3601);
        crowdFunding.finalize();

        vm.prank(Sam);
        crowdFunding.refund();

        assertEq(address(crowdFunding).balance, 0);
        assertEq(crowdFunding.contributions(Sam), 0);
    }

    function testContributeRevertWhenNotActive() public {
        vm.deal(Sam, 1000);
        vm.prank(Sam);
        crowdFunding.contribute{value: 1000}();

        vm.warp(block.timestamp + 3601);
        crowdFunding.finalize(); // now successful

        vm.deal(Teja, 100);
        vm.prank(Teja);
        vm.expectRevert("Not active");
        crowdFunding.contribute{value: 100}();
    }

    function testContributeRevertAfterDeadline() public {
        vm.deal(Teja, 100);
        vm.warp(block.timestamp + 3601);

        vm.prank(Teja);
        vm.expectRevert("Deadline passed");
        crowdFunding.contribute{value: 100}();
    }

    function testFinalizeRevertWhenNotActive() public {
        vm.deal(Sam, 1000);
        vm.prank(Sam);
        crowdFunding.contribute{value: 1000}();

        vm.warp(block.timestamp + 3601);
        crowdFunding.finalize();

        vm.expectRevert("Not active");
        crowdFunding.finalize();
    }

    function testWithdrawRevertNotCreator() public {
        vm.deal(Sam, 1000);
        vm.prank(Sam);
        crowdFunding.contribute{value: 1000}();

        vm.warp(block.timestamp + 3601);
        crowdFunding.finalize();

        vm.prank(Teja);
        vm.expectRevert("Only creator allowed");
        crowdFunding.withdraw();
    }

    function testWithdrawRevertAlreadyWithdrawn() public {
        vm.deal(Sam, 1000);
        vm.prank(Sam);
        crowdFunding.contribute{value: 1000}();

        vm.warp(block.timestamp + 3601);
        crowdFunding.finalize();

        vm.prank(creator);
        crowdFunding.withdraw();

        vm.prank(creator);
        vm.expectRevert("already withdrawal done");
        crowdFunding.withdraw();
    }

    function testRefundRevertWhenNotFailed() public {
        vm.deal(Sam, 1000);
        vm.prank(Sam);
        crowdFunding.contribute{value: 1000}();

        vm.warp(block.timestamp + 3601);
        crowdFunding.finalize(); // successful

        vm.prank(Sam);
        vm.expectRevert("Need to be failed");
        crowdFunding.refund();
    }

    function testRefundRevertNoContribution() public {
        vm.deal(Sam, 100);
        vm.prank(Sam);
        crowdFunding.contribute{value: 100}();

        vm.warp(block.timestamp + 3601);
        crowdFunding.finalize(); // failed

        vm.prank(Teja);
        vm.expectRevert("nothing to withdraw");
        crowdFunding.refund();
    }
}
