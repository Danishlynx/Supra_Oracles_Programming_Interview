// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import { MyTokenSale } from "../src/MyTokenSale.sol";

import { BaseScript } from "./Base.s.sol";

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract Deploy is BaseScript {
    function run() public broadcast returns (MyTokenSale mytokensale) {
        mytokensale = new MyTokenSale(1, 10);
    }
}
