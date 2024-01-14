// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import { TokenABC } from "../src/TokenABC.sol";
import { TokenXYZ } from "../src/TokenXYZ.sol";
import { TokenSwap } from "../src/TokenSwap.sol";


import { BaseScript } from "./Base.s.sol";

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract Deploy is BaseScript {
    function run() public broadcast returns (TokenABC tokenABC, TokenXYZ tokenXYZ, TokenSwap tokenSwap) {
        // Deploy TokenABC contract with an initial supply and token price
        uint256 initialSupplyABC = 1000000; // Adjust the initial supply as needed
        uint256 tokenPriceABC = 1000; // Adjust the token price as needed
        tokenABC = new TokenABC(initialSupplyABC, tokenPriceABC);

        // Deploy TokenXYZ contract with an initial supply and token price
        uint256 initialSupplyXYZ = 1000000; // Adjust the initial supply as needed
        uint256 tokenPriceXYZ = 10000; // Adjust the token price as needed
        tokenXYZ = new TokenXYZ(initialSupplyXYZ, tokenPriceXYZ);

        // Deploy TokenSwap contract and provide the addresses of TokenABC and TokenXYZ
        tokenSwap = new TokenSwap(address(tokenABC), address(tokenXYZ));
    }

}
