// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import { MultiSigWallet } from "../src/MultiSigWallet.sol";

import { BaseScript } from "./Base.s.sol";

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract Deploy is BaseScript {
    function run() public broadcast returns (MultiSigWallet multisigwallet) {
        address[] memory owners = new address[](2);
        owners[0] = 0x1a915c49fd620D9CB23b90c4eCF0aF8ed3CDb272;
        owners[1] = 0x5943e8b0F25bEAf63302124dD6d1F8b3589EB35D;

        multisigwallet = new MultiSigWallet(owners, 2);
    }
}