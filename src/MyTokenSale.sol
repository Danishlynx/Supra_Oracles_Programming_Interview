// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyTokenSale is ERC20 {
    address payable public immutable owner;

    

    uint256 public presaleMaxCap;
    uint256 public publicSaleMaxCap;
    uint256 public minContribution;
    uint256 public maxContribution;
    uint256 public presaleStartTime;
    uint256 public presaleEndTime;
    uint256 public publicSaleStartTime;
    uint256 public publicSaleEndTime;

    mapping(address => uint256) public contributions;
    mapping(address => uint256) public totalContributions;
    uint256 public totalRaisedEther;
    bool public presaleActive;
    bool public publicSaleActive;

    event PresaleContribution(address indexed contributor, uint256 amount);
    event PublicSaleContribution(address indexed contributor, uint256 amount);
    event TokenDistributed(address indexed recipient, uint256 amount);
    event RefundIssued(address indexed recipient, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor(uint256 _minContribution, uint256 _maxContribution) ERC20("MyToken", "MT") {
        owner = payable(msg.sender);
        minContribution = _minContribution * 1 ether;
        maxContribution = _maxContribution * 1 ether;
    }

    function startPresale(uint256 _maxCap, uint256 _duration) public onlyOwner {
        require(!presaleActive, "Presale is already active");
        presaleMaxCap = _maxCap * 1 ether;
        presaleStartTime = block.timestamp;
        presaleEndTime = block.timestamp + _duration;
        presaleActive = true;
    }

    function startPublicSale(uint256 _maxCap, uint256 _duration) public onlyOwner {
        require(!publicSaleActive, "Public sale is already active");
        require(presaleEndTime < block.timestamp, "Presale has not ended yet");
        publicSaleMaxCap = _maxCap * 1 ether;
        publicSaleStartTime = block.timestamp;
        publicSaleEndTime = block.timestamp + _duration;
        publicSaleActive = true;
    }

    function buyTokens() public payable {
        require((presaleActive && block.timestamp < presaleEndTime) || (publicSaleActive && block.timestamp < publicSaleEndTime), "Sale is not active");
        uint256 userTotalContribution = totalContributions[msg.sender] + msg.value;
        require(userTotalContribution >= minContribution && userTotalContribution <= maxContribution, "Contribution not within individual limits");
        uint256 newTotalRaised = totalRaisedEther + msg.value;
        require(newTotalRaised <= (presaleActive ? presaleMaxCap : publicSaleMaxCap), "Cap exceeded");

        uint256 tokensToMint = msg.value * 10;
        _mint(msg.sender, tokensToMint);
        contributions[msg.sender] += msg.value;
        totalContributions[msg.sender] = userTotalContribution;
        totalRaisedEther = newTotalRaised;

        if (presaleActive) {
            emit PresaleContribution(msg.sender, msg.value);
        } else {
            emit PublicSaleContribution(msg.sender, msg.value);
        }
    }

    function distributeTokens(address to, uint256 amount) public onlyOwner {
        require(to != address(0), "Invalid address");
        _mint(to, amount);
        emit TokenDistributed(to, amount);
    }

    function updateSaleStatus() internal {
        if (presaleActive && block.timestamp > presaleEndTime) {
            presaleActive = false;
        }
        if (publicSaleActive && block.timestamp > publicSaleEndTime) {
            publicSaleActive = false;
        }
    }

    function claimRefund() public {
        updateSaleStatus();
        require(!presaleActive && !publicSaleActive, "Sale is still active");
        require(totalRaisedEther < presaleMaxCap || totalRaisedEther < publicSaleMaxCap, "Minimum cap reached, no refunds");

        uint256 amount = contributions[msg.sender];
        require(amount > 0, "No contributions to refund");

        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        emit RefundIssued(msg.sender, amount);
    }
}
