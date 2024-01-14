# Voting Smart Contract

The **Voting** smart contract is designed to facilitate a secure and transparent voting process on the Ethereum blockchain. It provides a flexible and auditable platform for conducting elections, with features that enable administrators to add candidates and voters, manage the election lifecycle, and ensure the integrity of the voting process.

![Screenshot 2024-01-13 200551](https://github.com/Danishlynx/Supra_Oracles_Programming_Interview/assets/69537135/bbdcf558-45ed-49f6-8158-57b196e93c03)
![Screenshot 2024-01-13 200456](https://github.com/Danishlynx/Supra_Oracles_Programming_Interview/assets/69537135/2894f745-6225-4a75-aae1-674191ade7ec)


## Table of Contents

- [Features](#features)
- [Functions Summary](#functions-summary)
- [Modifiers](#modifiers)
- [Contract Variables](#contract-variables)
- [Detailed Function Descriptions](#detailed-function-descriptions)
- [Usage Examples](#usage-examples)
- [License](#license)

## Features

The **Voting** smart contract offers the following key features:

### 1. Election State Management

- The contract maintains the state of the election, with three possible states: NOT_STARTED, ONGOING, and ENDED.
- Only the admin can transition the election between these states, ensuring proper control over the voting process.

### 2. Candidates and Voters

- Administrators can add candidates, each with a name and proposal, allowing candidates to present their election platforms.
- Similarly, administrators can add voters with their names, providing transparency in the voter list.

### 3. Delegation of Voting Rights

- During an ongoing election, voters have the option to delegate their voting rights to another Ethereum address.
- This delegation allows for a flexible voting mechanism where individuals can vote on behalf of others, accommodating various use cases.

### 4. Casting Votes

- Voters can cast their votes for specific candidates.
- Each voter can only vote once, and their votes are counted toward the respective candidate's vote count.

### 5. Election End and Winner Determination

- Once the election ends, the admin can determine the winning candidate based on the highest vote count.
- The contract provides a function to display the winner's name, proposal, and the total number of votes received.

### 6. Voter Profile

- Voters can view their own profiles, including their name, the candidate they voted for, and whether they delegated their vote to another address.
- Additionally, administrators have the privilege of viewing voter profiles for administrative purposes.

### 7. Access Control

- The contract uses custom modifiers to ensure that only authorized individuals, such as the admin or voters who have not yet cast their votes during an ongoing election, can perform specific actions.
- These modifiers enhance the security and integrity of the voting process.

### 8. Event Emission

- Throughout the contract's lifecycle, events are emitted to provide transparency and traceability of actions. These events include contributions, candidate details, election results, and more.

## Functions Summary

Here is a summary of the contract's primary functions:

- `addCandidate`: Allows the admin to add a candidate with a name and proposal.
- `addVoter`: Allows the admin to add a voter with a name.
- `startElection`: Starts the election, transitioning it to the ongoing state.
- `displayCandidateDetails`: Displays details of a specific candidate.
- `showWinner`: Displays the winner of the election after it has ended.
- `delegateVotingRights`: Allows a voter to delegate their voting rights to another Ethereum address.
- `vote`: Allows a voter to cast their vote for a specific candidate.
- `endElection`: Ends the election, transitioning it to the ended state.
- `showElectionResults`: Displays the vote count for a specific candidate after the election has ended.
- `viewVoterProfile`: Allows a voter to view their own profile, including their name, voted candidate, and voting delegation status. The admin can also view voter profiles for administrative purposes.

## Modifiers

The contract uses custom modifiers to control access to specific functions. These modifiers include:

- `onlyAdmin`: Ensures that only the admin can perform certain actions.
- `onlyVoter`: Restricts functions to voters who have not yet voted and are not the admin.
- `onlyOngoingElection`: Allows functions to be executed only when the election is ongoing.

## Contract Variables

The contract defines several contract-level variables, including:

- `admin`: The Ethereum address of the contract's administrator.
- `voterIdCounter`: A counter to keep track of voter IDs.
- `candidateIdCounter`: A counter to keep track of candidate IDs.
- `voteCounter`: A counter to track the total number of votes cast.
- `electionState`: An enumeration representing the current state of the election.

## Detailed Function Descriptions

For detailed descriptions of each function and their parameters, please refer to the [Detailed Function Descriptions](#detailed-function-descriptions) section in the contract's source code.

## Usage Examples

Usage examples and code snippets demonstrating how to interact with the **Voting** smart contract can be found in the [Usage Examples](#usage-examples) section in the contract's source code.

## License

This smart contract is distributed under the [MIT License](LICENSE).

For more detailed information about the contract's functions, usage, and examples, please refer to the contract's source code.

---
**Note:** The contract's actual source code is required to execute these functions on the Ethereum blockchain. This document serves as a high-level overview and documentation guide for the contract.
