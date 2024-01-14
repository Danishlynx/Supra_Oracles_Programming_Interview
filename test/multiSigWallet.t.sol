// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { console2 } from "forge-std/src/console2.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";

import { MultiSigWallet } from "../src/MultiSigWallet.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

/// @dev If this is your first time with Forge, read this tutorial in the Foundry Book:
/// https://book.getfoundry.sh/forge/writing-tests
contract MultiSigWalletTest is PRBTest, StdCheats  {
    
    MultiSigWallet public multiSigWallet;

    event ConfirmTransaction(address indexed owner, uint indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint indexed txIndex);
    event SubmitTransaction(
        address indexed owner,
        uint indexed txIndex,
        address indexed to,
        uint value,
        bytes data
    );

    function setUp() public {
        address[] memory owners = new address[](2);
        owners[0] = address(1);
        owners[1] = address(2);
        uint256 totalConfirmation = 2;

        multiSigWallet = new MultiSigWallet(owners, totalConfirmation);
    }

    function test_executeTransaction() public {
        address ownerOne = address(1);
        address ownerTwo = address(2);
        uint256 txIndex = 0;

        vm.prank(ownerOne);
        multiSigWallet.submitTransaction(address(3), 0, "");

        vm.prank(ownerOne);
        multiSigWallet.confirmTransaction(txIndex);
        vm.prank(ownerTwo);
        multiSigWallet.confirmTransaction(txIndex);

        vm.expectEmit(true, true, true, true);
        emit ExecuteTransaction(ownerOne, txIndex);
        vm.prank(ownerOne);
        multiSigWallet.executeTransaction(txIndex);
    }

    function test_executeTransactionExpectRevertCannotExecute() public {
        address ownerOne = address(1);
        uint256 txIndex = 0;

        vm.prank(ownerOne);
        multiSigWallet.submitTransaction(address(3), 0, "");

        vm.prank(ownerOne);
        multiSigWallet.confirmTransaction(txIndex);

        vm.expectRevert(bytes("cannot execute tx"));
        vm.prank(ownerOne);
        multiSigWallet.executeTransaction(txIndex);
    }

    function test_executeTransactionExpectRevertTxFailed() public {
        address ownerOne = address(1);
        address ownerTwo = address(2);
        uint256 txIndex = 0;

        vm.prank(ownerOne);
        multiSigWallet.submitTransaction(address(3), 10, "");

        vm.prank(ownerOne);
        multiSigWallet.confirmTransaction(txIndex);
        vm.prank(ownerTwo);
        multiSigWallet.confirmTransaction(txIndex);

        vm.expectRevert(bytes("tx failed"));
        vm.prank(ownerOne);
        multiSigWallet.executeTransaction(txIndex);
    }

    function test_revokeConfirmation() public {
        address ownerOne = address(1);
        uint256 txIndex = 0;

        vm.prank(ownerOne);
        multiSigWallet.submitTransaction(address(3), 0, "");

        vm.prank(ownerOne);
        multiSigWallet.confirmTransaction(txIndex);

        vm.prank(ownerOne);
        multiSigWallet.revokeConfirmation(txIndex);
    }

    function test_revokeConfirmationExpectRevertTxNotConfirmed() public {
        address ownerOne = address(1);
        uint256 txIndex = 0;

        vm.prank(ownerOne);
        multiSigWallet.submitTransaction(address(3), 0, "");

        vm.expectRevert(bytes("tx not confirmed"));
        vm.prank(ownerOne);
        multiSigWallet.revokeConfirmation(txIndex);
    }

    function test_getOwners() public {
        address[] memory owners = multiSigWallet.getOwners();

        assertEq(owners[0], address(1));
        assertEq(owners[1], address(2));
    }

    function test_getTransactionCount() public {
        vm.prank(address(1));
        multiSigWallet.submitTransaction(address(3), 0, "");
        uint txCount = multiSigWallet.getTransactionCount();

        assertEq(txCount, 1);
    }

    function test_getTransaction() public {
        address ownerOne = address(1);
        address to = address(3);
        uint value = 10;
        bytes memory data = "";

        vm.prank(ownerOne);
        multiSigWallet.submitTransaction(to, value, data);

        (
            address txTo,
            uint txValue,
            bytes memory txData,
            bool txExecuted,
            uint txNumConfirmations
        ) = multiSigWallet.getTransaction(0);

        assertEq(to, txTo);
        assertEq(value, txValue);
        assertEq(data, txData);
        assertEq(txExecuted, false);
        assertEq(txNumConfirmations, 0);
    }
}
