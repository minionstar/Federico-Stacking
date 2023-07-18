// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract ImmeStaking is Ownable {

    IERC20 public immeToken;
    IERC20 public busdToken;
    address public UNISWAP_V2_ROUTER;

    address immeOwner;

    uint256 constant sTime1 = 7 days;
    uint256 constant sTime2 = 14 days;
    uint256 constant sTime3 = 30 days;
    uint256 constant sTime4 = 60 days;
    uint256 constant sTime5 = 90 days;
    uint256 constant sTime6 = 180 days;
    uint256 constant sTime7 = 360 days;
    uint256 constant sTime8 = 720 days;

    uint256 public totalStaked = 0;
    uint256 public totalUsers = 0;
    uint256 public totalRewards = 0;

    struct Staker {
        uint256 balance;
        uint256 startTime;
    }
    
    mapping(address => Staker) public stakers;
    
    function addLiquidity(
        address _tokenA,
        address _tokenB,
        uint _amountA,
        uint _amountB
    ) internal {

        IERC20(_tokenA).approve(UNISWAP_V2_ROUTER, _amountA);
        IERC20(_tokenB).approve(UNISWAP_V2_ROUTER, _amountB);

        IPancakeRouter02(UNISWAP_V2_ROUTER)
            .addLiquidity(
                _tokenA,
                _tokenB,
                _amountA,
                _amountB,
                0,
                0,
                immeOwner,
                block.timestamp
            );
    }
    constructor(IERC20 _immeToken, IERC20 _busdToken, address _router) {
        
        immeToken = _immeToken;
        busdToken = _busdToken;

        UNISWAP_V2_ROUTER = _router;
        immeOwner = msg.sender;
        
        console.log("Deploying staking contract");

    }

    function getUserBalance(address user) public view returns(uint256) {
        Staker memory staker =  stakers[user];
        return staker.balance;
    }

    function getClaimable(address user) public view returns(uint256) {
        return reward(user);
    }

    function staking(uint256 _amount) public {
        require(_amount > 0, "There isn't enough your balance");
        busdToken.transferFrom(msg.sender, address(this), _amount);
        address[] memory path;
        path = new address[](2);
        path[0] = address(busdToken);
        path[1] = address(immeToken);
        uint256[] memory out;
        out = IPancakeRouter02(UNISWAP_V2_ROUTER).getAmountsOut(_amount, path);
        
        stakers[msg.sender].startTime = block.timestamp;
        stakers[msg.sender].balance = out[1];
        totalStaked += stakers[msg.sender].balance;
        totalUsers ++;

        addLiquidity(address(busdToken), address(immeToken), _amount, stakers[msg.sender].balance);

    }

    function unstake() public {
        require(stakers[msg.sender].balance > 0, "Insufficient balance!");
        uint256 rewardAmount = reward(msg.sender); 

        totalRewards += rewardAmount;
        totalStaked -= stakers[msg.sender].balance;

        uint256 amount = stakers[msg.sender].balance + rewardAmount;
        
        stakers[msg.sender].balance = 0;

        immeToken.transfer(msg.sender, amount);
    }

    function reward(address _address) private view returns (uint256 reamount) {

        uint256 stime = block.timestamp - stakers[_address].startTime;

        uint256 amount = 0;

        if(stime >= sTime8) {
            amount = stakers[_address].balance * 5;
        }
        else if(stime >= sTime7) {
            amount = stakers[_address].balance * 2;
        }
        else if(stime >= sTime6) {
            amount = stakers[_address].balance * 75 / 100;
        }
        else if(stime >= sTime5) {
            amount = stakers[_address].balance * 25 / 100;
        }
        else if(stime >= sTime4) {
            amount = stakers[_address].balance * 16 / 100;
        }
        else if(stime >= sTime3) {
            amount = stakers[_address].balance * 75 / 1000;
        }
        else if(stime >= sTime2) {
            amount = stakers[_address].balance * 35 / 1000;
        }
        else if(stime >= sTime1){
            amount = stakers[_address].balance * 15 / 1000;
        }
        return amount;
    }
}