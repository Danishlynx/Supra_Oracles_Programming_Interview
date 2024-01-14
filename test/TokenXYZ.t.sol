// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { TokenXYZ } from "../src/TokenXYZ.sol";

contract TokenXYZTest is PRBTest, StdCheats {
    TokenXYZ private tokenXYZ;
    uint256 private initialTokenPrice = 1 ether;

    function setUp() public {
        tokenXYZ = new TokenXYZ(1000000, initialTokenPrice);
    }

    function testInitialSupplyAndPrice() public {
        assertEq(tokenXYZ.totalSupply(), 1000000 * 10 ** tokenXYZ.decimals());
        assertEq(tokenXYZ.tokenPrice(), initialTokenPrice);
    }

    function testBuyTokensSuccess() public {
        uint256 buyAmount = 100;
        vm.deal(address(this), 100 ether);
        tokenXYZ.buyTokens{value: buyAmount * initialTokenPrice}(buyAmount);
        assertEq(tokenXYZ.balanceOf(address(this)), buyAmount);
        assertEq(tokenXYZ.tokensSold(), buyAmount);
    }

    function testFailBuyTokensInsufficientETH() public {
        uint256 buyAmount = 100;
        vm.expectRevert("Insufficient ETH sent");
        tokenXYZ.buyTokens{value:
        (buyAmount / 2) * initialTokenPrice}(buyAmount);
    }
}