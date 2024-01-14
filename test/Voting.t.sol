// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.23 <0.9.0;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { console2 } from "forge-std/src/console2.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";

import { Voting } from "../src/Voting.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

/// @dev If this is your first time with Forge, read this tutorial in the Foundry Book:
/// https://book.getfoundry.sh/forge/writing-tests
contract VotingTest is PRBTest, StdCheats  {
    Voting private voting;
    address private admin;

    function setUp() public {
        admin = address(this); // Set the test contract as the admin
        voting = new Voting();
    }

    function testAdminInitialization() public {
        assertEq(voting.admin(), admin, "Admin should be initialized correctly");
    }

    function testAddCandidate() public {
        voting.addCandidate("Alice", "Proposal A");
        (, string memory name, ) = voting.displayCandidateDetails(0);
        assertEq(name, "Alice", "Candidate should be added correctly");
    }

    function testStartAndEndElection() public {
        voting.startElection();
        assertEq(uint(voting.electionState()), 1, "Election should be ongoing");
        voting.endElection();
        assertEq(uint(voting.electionState()), 2, "Election should be ended");
    }

    function testAddVoter() public {
        address voterAddress = address(0x1);
        voting.addVoter(voterAddress, "Bob");
        (string memory name,,) = voting.viewVoterProfile(voterAddress);
        assertEq(name, "Bob", "Voter should be added correctly");
    }

    function testVoting() public {
        // Step 1: Set up a candidate and a voter
        address voterAddress = address(0x1);
        voting.addCandidate("Eve", "Proposal E");
        voting.addVoter(voterAddress, "Dave");

        // Step 2: Start the election
        voting.startElection();

        // Step 3: Cast a vote
        vm.prank(voterAddress);
        voting.Vote(0, voterAddress);

        // Step 4: End the election
        voting.endElection();

        // Step 6: Check the vote count for the candidate
        (,,uint256 voteCount) = voting.showElectionResults(0);
        assertEq(voteCount, 1, "Vote count should be 1 for the candidate");
    }

    function testDelegateVotingRights() public {
        address voterAddress = address(0x3);
        address delegateAddress = address(0x4);
        voting.addVoter(voterAddress, "Henry");
        voting.addVoter(delegateAddress, "Ivy");
        voting.startElection();
        vm.prank(voterAddress);
        voting.delegateVotingRights(delegateAddress, voterAddress);
        (,,bool delegated) = voting.viewVoterProfile(voterAddress);
        assertEq(delegated, true, "Voting rights should be delegated");
    }

    function testShowElectionResults() public {
        voting.addCandidate("Larry", "Proposal L");
        voting.addVoter(address(0x7), "Mike");
        voting.startElection();
        vm.prank(address(0x7));
        voting.Vote(0, address(0x7));
        voting.endElection();
        (uint256 candidateId, string memory name, uint256 voteCount) = voting.showElectionResults(0);
        assertEq(candidateId, 0, "Candidate ID should be 0");
        assertEq(name, "Larry", "Correct candidate should win");
        assertEq(voteCount, 1, "Correct vote count should be shown");
    }

   
}
