// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { TokenABC } from "../src/TokenABC.sol";

contract TokenABCTest is PRBTest, StdCheats {
    TokenABC private tokenABC;
    uint256 private initialTokenPrice = 1 ether;

    function setUp() public {
        tokenABC = new TokenABC(1000000, initialTokenPrice);
    }

    function testInitialSupplyAndPrice() public {
        assertEq(tokenABC.totalSupply(), 1000000 * 10 ** tokenABC.decimals());
        assertEq(tokenABC.tokenPrice(), initialTokenPrice);
    }

    function testBuyTokensSuccess() public {
        uint256 buyAmount = 100;
        vm.deal(address(this), 100 ether);
        tokenABC.buyTokens{value: buyAmount * initialTokenPrice}(buyAmount);
        assertEq(tokenABC.balanceOf(address(this)), buyAmount);
        assertEq(tokenABC.tokensSold(), buyAmount);
    }

    function testFailBuyTokensInsufficientETH() public {
        uint256 buyAmount = 100;
        vm.expectRevert("Insufficient ETH sent");
        tokenABC.buyTokens{value: (buyAmount / 2) * initialTokenPrice}(buyAmount);
    }

    function testFailBuyTokensOverflow() public {
        vm.expectRevert("Overflow");
        tokenABC.buyTokens{value: 1 ether}(2**256 - 1);
    }
}