//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange is ERC20 {
    address public tokenAddress;

    constructor(address token) ERC20("ETH TOKEN LP TOKEN", "lpETHTOKEN") {
        require(token != address(0), "Token address passed is a null address");
        tokenAddress = token;
    }

    function getReserve() public view returns(uint256) {
        return ERC20(tokenAddress).balanceOf(address(this));
    } 

    function addLiquiity(
        uint256 amountOfTokens
    ) public payable returns (uint256) {
        uint256 lpTokensToMint;
        uint256 ethReserveBalance = address(this).balance;
        uint256 tokenReserveBalance = getReserve();

        ERC20 token = ERC20(tokenAddress);

        if (tokenReserveBalance == 0) {
            token.transferFrom(msg.sender, address(this), amountOfTokens);

            lpTokensToMint = amountOfTokens;
            _mint(msg.sender, lpTokensToMint);

            return lpTokensToMint;
        }

        uint256 ethReservePriorToFuntionCall = ethReserveBalance - msg.value;
        uint256 tokenAmountRequired = (msg.value * tokenReserveBalance) / 
            ethReservePriorToFuntionCall;
        
        require(
            amountOfTokens == tokenAmountRequired,
            "Incorrect amount of tokens provided"
        );

        token.transferFrom(msg.sender, address(this), amountOfTokens);

        lpTokensToMint = (totalSupply() * msg.value) / 
            ethReservePriorToFuntionCall;
        _mint(msg.sender, lpTokensToMint);

        return lpTokensToMint;
    }

    function removeLiquidity (
        uint256 amountOfLPTokens
    ) public returns (uint256, uint256) {
        require(
            amountOfLPTokens > 0,
            "Amount of LP tokens to burn must be greater than zero"
        );

        uint256 ethReserveBalance = address(this).balance;
        uint256 lpTokenTotalSupply = totalSupply();

        uint256 ethToReturn = (ethReserveBalance * amountOfLPTokens) / 
            lpTokenTotalSupply;
        uint tokenToReturn = (getReserve() * amountOfLPTokens) / 
            lpTokenTotalSupply;

        _burn(msg.sender, amountOfLPTokens);
        payable(msg.sender).transfer(ethToReturn);
        ERC20(msg.sender).transfer(msg.sender, tokenToReturn);

        return (ethToReturn, tokenToReturn);
    }

    function getOutputAmountFromSwap(
        uint256 inputAmount,
        uint256 inputReserve,
        uint256 outputReserve
    ) public pure returns (uint256) {
    require(
        inputReserve > 0 && outputReserve > 0,
        "Reserves must be greater than 0"
    );

    uint256 inputAmountWithFee = inputAmount * 99;
    uint256 numerator = inputAmountWithFee * outputReserve;
    uint256 denominator = inputAmountWithFee + inputReserve * 100;

    return (numerator / denominator);
    }

    function ethToTokenSwap(uint256 minTokensToReceive) public payable {
        uint256 tokenReserveBalance = getReserve();
        uint256 tokensToReceive = getOutputAmountFromSwap(
            msg.value, 
            address(this).balance - msg.value, 
            tokenReserveBalance
        );

        require(
            tokensToReceive > minTokensToReceive,
            "Tokens received are less than the minimun tokens expected"
        );

        ERC20(tokenAddress).transfer(msg.sender, tokensToReceive);
    }

    function tokenToEthSwap(
        uint256 tokensToSwap,
        uint256 minEthToReceive
    ) public {
        uint256 tokenReserveBalance = getReserve();
        uint256 ethToReceive = getOutputAmountFromSwap(
            tokensToSwap, 
            tokenReserveBalance, 
            address(this).balance
        );

        require(
            ethToReceive > minEthToReceive,
            "Eth received is less than the minimun eth expected"
        );

        payable(msg.sender).transfer(ethToReceive);
    }

}