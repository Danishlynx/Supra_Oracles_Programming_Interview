// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { console2 } from "forge-std/src/console2.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";

import { MyTokenSale } from "../src/MyTokenSale.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

/// @dev If this is your first time with Forge, read this tutorial in the Foundry Book:
/// https://book.getfoundry.sh/forge/writing-tests
contract MyTokenSaleTest is PRBTest, StdCheats {
     MyTokenSale tokenSale;
    address owner;
    address payable user1;
    address payable user2;

    function setUp() public {
        owner = address(this);  // Test contract is the owner
        user1 = payable(address(0x1));
        user2 = payable(address(0x2));
        tokenSale = new MyTokenSale(1, 10); // Initialize with min and max contributions
    }

    function testPresaleInitialization() public {
        assertEq(tokenSale.owner(), owner, "Owner should be set correctly");
        assertEq(tokenSale.minContribution(), 1 ether, "Min contribution should be 1 ether");
        assertEq(tokenSale.maxContribution(), 10 ether, "Max contribution should be 10 ether");
    }

    function testStartPresale() public {
        uint256 maxCap = 100;
        uint256 duration = 1 days;
        vm.prank(owner);
        tokenSale.startPresale(maxCap, duration);

        assertEq(tokenSale.presaleMaxCap(), maxCap * 1 ether, "Presale max cap should be set correctly");
        assertEq(tokenSale.presaleStartTime(), block.timestamp, "Presale start time should be set to current timestamp");
        assertEq(tokenSale.presaleEndTime(), block.timestamp + duration, "Presale end time should be set correctly");
        assertTrue(tokenSale.presaleActive(), "Presale should be active");
    }

    function testBuyTokensDuringPresale() public {
        vm.prank(owner);
        tokenSale.startPresale(100, 1 days);

        uint256 amount = 2 ether;
        vm.deal(user1, amount);
        vm.prank(user1);
        tokenSale.buyTokens{value: amount}();

        assertEq(tokenSale.totalContributions(user1), amount, "User's total contribution should be recorded correctly");
        assertEq(tokenSale.balanceOf(user1), amount * 10, "Correct amount of tokens should be minted");
    }

    function testStartPublicSale() public {
        vm.prank(owner);
        tokenSale.startPresale(100, 1 days);
        vm.warp(block.timestamp + 2 days); // Forward time to end presale

        uint256 maxCap = 200;
        uint256 duration = 2 days;
        vm.prank(owner);
        tokenSale.startPublicSale(maxCap, duration);

        assertEq(tokenSale.publicSaleMaxCap(), maxCap * 1 ether, "Public sale max cap should be set correctly");
        assertEq(tokenSale.publicSaleStartTime(), block.timestamp, "Public sale start time should be set to current timestamp");
        assertEq(tokenSale.publicSaleEndTime(), block.timestamp + duration, "Public sale end time should be set correctly");
        assertTrue(tokenSale.publicSaleActive(), "Public sale should be active");
    }

    function testBuyTokensDuringPublicSale() public {
        testStartPublicSale(); // Ensure public sale is active

        uint256 amount = 3 ether;
        vm.deal(user2, amount);
        vm.prank(user2);
        tokenSale.buyTokens{value: amount}();

        assertEq(tokenSale.totalContributions(user2), amount, "User's total contribution should be recorded correctly during public sale");
        assertEq(tokenSale.balanceOf(user2), amount * 10, "Correct amount of tokens should be minted");
    }

    function testTokenDistributionByOwner() public {
        uint256 amount = 1000;
        vm.prank(owner);
        tokenSale.distributeTokens(user1, amount);

        assertEq(tokenSale.balanceOf(user1), amount, "Tokens should be distributed correctly by owner");
    }


    function testFailures() public {
        // Attempt to start a presale when one is already active
        vm.prank(owner);
        tokenSale.startPresale(100, 1 days);
        vm.expectRevert("Presale is already active");
        vm.prank(owner);
        tokenSale.startPresale(200, 2 days);

        // Attempt to buy tokens when no sale is active
        vm.warp(block.timestamp + 1 days + 1); // End presale
        vm.expectRevert("Sale is not active");
        vm.prank(user1);
        tokenSale.buyTokens{value: 1 ether}();

        // Attempt to distribute tokens as a non-owner
        vm.expectRevert("Only owner can call this function");
        vm.prank(user2);
        tokenSale.distributeTokens(user1, 1000);

        // Attempt to claim a refund when not eligible
        vm.prank(owner);
        tokenSale.startPublicSale(200, 2 days);
        vm.warp(block.timestamp + 2 days + 1); // End public sale
        vm.expectRevert("Sale is still active");
        vm.prank(user1);
        tokenSale.claimRefund();
    }

}