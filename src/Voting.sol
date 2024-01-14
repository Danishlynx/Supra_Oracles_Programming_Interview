// SPDX-License-Identifier: MIT
pragma solidity >=0.8.23 <0.9.0;


contract Voting {
    address public admin;
    uint256 public voterIdCounter;
    uint256 public candidateIdCounter;
    uint256 public voteCounter;

    enum ElectionState { NOT_STARTED, ONGOING, ENDED }
    ElectionState public electionState;

    struct Voter {
        string name;
        bool hasVoted;
        bool voteDelegated;
        address delegate;
        uint256 votedFor;
    }

    struct Candidate {
        string name;
        string proposal;
        uint256 voteCount;
    }
    // Use address as the key for voters mapping
    mapping(address => Voter) public voters; // Use address as the key
    mapping(uint256 => Candidate) public candidates;

    constructor() {
        admin = msg.sender;
        electionState = ElectionState.NOT_STARTED;
        voterIdCounter = 0;
        candidateIdCounter = 0;
        voteCounter = 0;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can perform this action.");
        _;
    }

    modifier onlyVoter() {
        require(!voters[msg.sender].hasVoted, "You have already voted.");
        require(msg.sender != admin, "Admin cannot vote");
        _;
    }

    modifier onlyOngoingElection() {
        require(electionState == ElectionState.ONGOING, "Election is not ongoing.");
        _;
    }

    function addCandidate(string memory _name, string memory _proposal) public onlyAdmin {
    candidates[candidateIdCounter] = Candidate(_name, _proposal, 0);
    candidateIdCounter++;
    }

    function addVoter(address _voterAddress, string memory _name) public onlyAdmin {
    voters[_voterAddress] = Voter(_name, false, false, address(0), 0);
    voterIdCounter++;
}



    function startElection() public onlyAdmin {
    electionState = ElectionState.ONGOING;
    }

    function displayCandidateDetails(uint256 _candidateId) public view returns (uint256, string memory, string memory) {
        require(_candidateId < candidateIdCounter, "Invalid candidate ID.");
        Candidate memory candidate = candidates[_candidateId];
        return (_candidateId, candidate.name, candidate.proposal);
    }

    function showWinner() public view onlyAdmin returns (string memory, string memory, uint256) {
    require(electionState == ElectionState.ENDED, "Election has not ended yet.");
    Candidate memory winner;
    uint256 winningVotes = 0;
    uint256 winningCandidateId;

    for (uint256 i = 0; i < candidateIdCounter; i++) {
        if (candidates[i].voteCount > winningVotes) {
            winner = candidates[i];
            winningVotes = candidates[i].voteCount;
            winningCandidateId = i;
        }
    }

    return (winner.name, winner.proposal, winningVotes);
    }

    function delegateVotingRights(address _delegate, address _voterAddress) public onlyOngoingElection onlyVoter {
    voters[_voterAddress].voteDelegated = true;
    voters[_voterAddress].delegate = _delegate;
    }


    function Vote(uint256 _candidateId, address _voterAddress) public onlyOngoingElection onlyVoter {
    require(_candidateId < candidateIdCounter, "Invalid candidate ID.");
    require(!voters[_voterAddress].voteDelegated, "You have delegated your vote.");

    voters[_voterAddress].hasVoted = true;
    voters[_voterAddress].votedFor = _candidateId;
    candidates[_candidateId].voteCount++;
    voteCounter++;
    }

    function endElection() public onlyAdmin {
    electionState = ElectionState.ENDED;
    }

    function showElectionResults(uint256 _candidateId) public view onlyAdmin returns (uint256, string memory, uint256) {
        require(electionState == ElectionState.ENDED, "Election has not ended yet.");
        require(_candidateId < candidateIdCounter, "Invalid candidate ID.");
        
        Candidate memory candidate = candidates[_candidateId];
        return (_candidateId, candidate.name, candidate.voteCount);
    }

    function viewVoterProfile(address _voterAddress) public view returns (string memory, uint256, bool) {
        require(msg.sender == admin || msg.sender == _voterAddress, "You do not have permission to view this profile.");
        Voter memory voter = voters[_voterAddress];
        return (voter.name, voter.votedFor, voter.voteDelegated);
    }
}