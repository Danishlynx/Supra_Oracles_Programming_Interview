// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./TokenABC.sol";
import "./TokenXYZ.sol";

contract TokenSwap {
    address payable admin;
    uint256 public ratioAX;
    uint256 public fees;
    TokenABC public tokenABC;
    TokenXYZ public tokenXYZ;

    event RatioChanged(uint256 newRatio);
    event FeesChanged(uint256 newFees);
    event TokensSwapped(address indexed user, uint256 amountIn, uint256 amountOut, string tokenIn, string tokenOut);

    constructor(address _tokenABC, address _tokenXYZ) {
        admin = payable(msg.sender);
        tokenABC = TokenABC(_tokenABC);
        tokenXYZ = TokenXYZ(_tokenXYZ);
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this");
        _;
    }

    function setRatio(uint256 _ratio) public onlyAdmin {
        require(_ratio > 0, "Ratio must be greater than zero");
        ratioAX = _ratio;
        emit RatioChanged(_ratio);
    }

    function setFees(uint256 _fees) public onlyAdmin {
        require(_fees < 100, "Fees must be less than 100%");
        fees = _fees;
        emit FeesChanged(_fees);
    }

    function swapTKA(uint256 amountTKA) public {
        require(tokenABC.allowance(msg.sender, address(this)) >= amountTKA, "Insufficient TokenABC allowance");
        require(tokenABC.balanceOf(msg.sender) >= amountTKA, "Insufficient TokenABC balance");
        uint256 feeAmount = (amountTKA * fees) / 100;
        uint256 exchangeAmount = (amountTKA * ratioAX) - feeAmount;
        require(exchangeAmount > 0, "Exchange amount must be greater than zero");
        require(tokenXYZ.balanceOf(address(this)) >= exchangeAmount, "Insufficient TokenXYZ balance in contract");

        tokenABC.transferFrom(msg.sender, address(this), amountTKA);
        tokenXYZ.transfer(msg.sender, exchangeAmount);

        emit TokensSwapped(msg.sender, amountTKA, exchangeAmount, "ABC", "XYZ");
    }

    function swapTKX(uint256 amountTKX) public {
        require(tokenXYZ.allowance(msg.sender, address(this)) >= amountTKX, "Insufficient TokenXYZ allowance");
        require(tokenXYZ.balanceOf(msg.sender) >= amountTKX, "Insufficient TokenXYZ balance");
        uint256 exchangeAmount = (amountTKX / ratioAX) - ((amountTKX * fees) / 100);
        require(exchangeAmount > 0, "Exchange amount must be greater than zero");
        require(tokenABC.balanceOf(address(this)) >= exchangeAmount, "Insufficient TokenABC balance in contract");

        tokenXYZ.transferFrom(msg.sender, address(this), amountTKX);
        tokenABC.transfer(msg.sender, exchangeAmount);

        emit TokensSwapped(msg.sender, amountTKX, exchangeAmount, "XYZ", "ABC");
    }

    function getTokenBalances(address user) public view returns (uint256 balanceABC, uint256 balanceXYZ) {
        balanceABC = tokenABC.balanceOf(user);
        balanceXYZ = tokenXYZ.balanceOf(user);
    }

   
    function buyTokensABC(uint256 amount) public payable {
        tokenABC.buyTokens{value: msg.value}(amount);
    }


    function buyTokensXYZ(uint256 amount) public payable {
        tokenXYZ.buyTokens{value: msg.value}(amount);
    }
}