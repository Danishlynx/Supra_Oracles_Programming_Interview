// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";
import { TokenABC } from "../src/TokenABC.sol";
import { TokenXYZ } from "../src/TokenXYZ.sol";
import { TokenSwap } from "../src/TokenSwap.sol";
import { console2 } from "forge-std/src/console2.sol";

contract TokenSwapTest is PRBTest, StdCheats {
    TokenABC private tokenABC;
    TokenXYZ private tokenXYZ;
    TokenSwap private tokenSwap;

    // Test accounts
    address private owner;
    address private user;

    function setUp() public {
        console2.log("Deploying TokenABC");
        tokenABC = new TokenABC(1000000 * 10 ** 18, 1 ether);
        console2.log("TokenABC deployed at:", address(tokenABC));

        console2.log("Deploying TokenXYZ");
        tokenXYZ = new TokenXYZ(1000000 * 10 ** 18, 1 ether);
        console2.log("TokenXYZ deployed at:", address(tokenXYZ));

        console2.log("Deploying TokenSwap");
        tokenSwap = new TokenSwap(address(tokenABC), address(tokenXYZ));
        console2.log("TokenSwap deployed at:", address(tokenSwap));

        owner = address(this); // Contract deployer is the owner
        user = address(0x123); // Another user

        console2.log("Setting ratio and fees in TokenSwap");
        tokenSwap.setRatio(2); // 1 ABC = 2 XYZ
        tokenSwap.setFees(10); // 10% fee

        console2.log("Approving and transferring tokens to TokenSwap contract");
        tokenABC.approve(address(tokenSwap), type(uint256).max);
        tokenXYZ.approve(address(tokenSwap), type(uint256).max);
        tokenABC.transfer(address(tokenSwap), 500000 * 10 ** 18); // Transfer 500K ABC tokens
        tokenXYZ.transfer(address(tokenSwap), 500000 * 10 ** 18); // Transfer 500K XYZ tokens

        console2.log("Providing tokens to user for testing");
        tokenABC.transfer(user, 1000 * 10 ** 18);
        tokenXYZ.transfer(user, 1000 * 10 ** 18);
        console2.log("User setup complete");
    }

    function testSwapTKAToTKX() public {
        console2.log("Testing swapTKA to TKX");
        uint256 userInitialABC = tokenABC.balanceOf(user);
        uint256 userInitialXYZ = tokenXYZ.balanceOf(user);

        console2.log("User initial ABC balance:", userInitialABC);
        console2.log("User initial XYZ balance:", userInitialXYZ);

        vm.prank(user);
        tokenABC.approveMax(address(tokenSwap));

        uint256 swapAmount = 100 * 10 ** 18;
        vm.prank(user);
       
        tokenSwap.swapTKA(swapAmount);


        uint256 userFinalABC = tokenABC.balanceOf(user);
        uint256 userFinalXYZ = tokenXYZ.balanceOf(user);

        console2.log("User final ABC balance:", userFinalABC);
        console2.log("User final XYZ balance:", userFinalXYZ);

        uint256 expectedABC = userInitialABC - swapAmount;
        uint256 expectedXYZ = userInitialXYZ + (swapAmount * 2) - ((swapAmount * 2 * 10) / 100);

        assertEq(userFinalABC, expectedABC, "User should have the correct amount of ABC after swap");
        assertEq(userFinalXYZ, expectedXYZ, "User should have the correct amount of XYZ after swap");
    }

    function testSwapTKXToTKA() public {
        console2.log("Testing swapTKX to TKA");
        uint256 userInitialABC = tokenABC.balanceOf(user);
        uint256 userInitialXYZ = tokenXYZ.balanceOf(user);

        console2.log("User initial ABC balance:", userInitialABC);
        console2.log("User initial XYZ balance:", userInitialXYZ);

        vm.prank(user);
        tokenXYZ.approveMax(address(tokenSwap));

        uint256 swapAmount = 100 * 10 ** 18;
        vm.prank(user);
        tokenSwap.swapTKX(swapAmount);

        uint256 userFinalABC = tokenABC.balanceOf(user);
        uint256 userFinalXYZ = tokenXYZ.balanceOf(user);

        console2.log("User final ABC balance:", userFinalABC);
        console2.log("User final XYZ balance:", userFinalXYZ);

        uint256 expectedABC = userInitialABC + (swapAmount / 2) - ((swapAmount / 2 * 10) / 100);
        uint256 expectedXYZ = userInitialXYZ - swapAmount;

        assertEq(userFinalABC, expectedABC, "User should have the correct amount of ABC after swap");
        assertEq(userFinalXYZ, expectedXYZ, "User should have the correct amount of XYZ after swap");
    }
}