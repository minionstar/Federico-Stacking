// SPDX-License-Identifier: GPL-3.0-only
// by louislee

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IQNVToken {
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (uint256);

    function burn(address burnAddress, uint256 amount) external;
    function mint(address mintAddress, uint256 amount) external;
}

contract StakeQNV is Pausable, Ownable, ReentrancyGuard {
    IQNVToken qnvToken;
    IERC20 stableToken;

    // 7 Days (7 * 24 * 60 * 60)
    uint256 public weekPlanDuration = 604800;

    // 30 Days (30 * 24 * 60 * 60)
    uint256 public monthPlanDuration = 2592000;

    uint8 public interestRatePerWeek = 5;
    uint8 public interestRatePerMonth = 20;
    uint256 public planExpired;
    uint8 public totalStakers;

    struct StakeInfo {
        uint256 startTS;
        uint256 endTS;
        uint256 amount;
        uint256 claimed;
        uint256 interestRate;
    }

    event Staked(address indexed from, uint256 amount);
    event Claimed(address indexed from, uint256 amount);

    mapping(address => StakeInfo) public stakeInfos;
    mapping(address => bool) public addressStaked;

    constructor(IQNVToken _tokenAddress, IERC20 _stableTokenAddress) {
        require(
            address(_tokenAddress) != address(0),
            "Token Address cannot be address 0"
        );
        qnvToken = _tokenAddress;
        stableToken = _stableTokenAddress;
        totalStakers = 0;
    }

    function claimReward() external returns (bool) {
        require(
            addressStaked[_msgSender()] == true,
            "You are not participated"
        );
        require(
            stakeInfos[_msgSender()].endTS < block.timestamp,
            "Stake Time is not over yet"
        );
        require(stakeInfos[_msgSender()].claimed == 0, "Already claimed");

        uint256 stakeAmount = stakeInfos[_msgSender()].amount;
        uint256 totalTokens = stakeAmount +
            ((stakeAmount * stakeInfos[_msgSender()].interestRate) / 100);
        stakeInfos[_msgSender()].claimed = totalTokens;

        // transfer stable token to the staker
        stableToken.transfer(_msgSender(), totalTokens);
        // burn QNV token
        qnvToken.burn(_msgSender(), totalTokens);

        emit Claimed(_msgSender(), totalTokens);

        return true;
    }

    function getTokenExpiry() external view returns (uint256) {
        require(
            addressStaked[_msgSender()] == true,
            "You are not participated"
        );
        return stakeInfos[_msgSender()].endTS;
    }

    function stakeToken(
        uint256 stakeAmount,
        uint8 stakeType
    ) external payable whenNotPaused {
        require(stakeAmount > 0, "Stake amount should be correct");
        require(
            addressStaked[_msgSender()] == false,
            "You already participated"
        );
        require(
            qnvToken.balanceOf(_msgSender()) >= stakeAmount,
            "Insufficient Balance"
        );

        stakeInfos[_msgSender()] = StakeInfo({
            startTS: block.timestamp,
            endTS: block.timestamp + stakeType == 1
                ? weekPlanDuration
                : monthPlanDuration,
            amount: stakeAmount,
            claimed: 0,
            interestRate: stakeType == 1
                ? interestRatePerWeek
                : interestRatePerMonth
        });

        // send stable token from user to the treasury
        stableToken.transferFrom(_msgSender(), address(this), stakeAmount);

        // mint QNV token to user according to the staked stable token amount
        uint256 mintQNVAmount = stakeAmount +
            ((stakeAmount * stakeInfos[_msgSender()].interestRate) / 100);
        qnvToken.transfer(_msgSender(), mintQNVAmount);
        
        totalStakers++;
        addressStaked[_msgSender()] = true;

        emit Staked(_msgSender(), stakeAmount);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

}
