// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract StakingContract {
    using SafeMath for uint256;

    /// @dev Events of the contract -later

    IERC20 public stakingToken;

    /// @dev depositer and his deposit info
    mapping(address => Staker) public stakers;

    struct Staker {
        uint256 stakedAmount;
        uint256 lastBlockChecked;
        uint256 unclaimedRewards;
    }

    uint256 public constant BLOCKS_PER_REWARD = 10;
    uint256 public constant INTEREST_RATE = 2; // 2% interest

    event Staked(address indexed staker, uint256 amount);
    event Withdrawn(address indexed staker, uint256 amount);
    event RewardClaimed(address indexed staker, uint256 amount);

    /// @notice Contract constructor
    constructor(address _stakingToken) {
        stakingToken = IERC20(_stakingToken);
    }

    /**
     @notice Allows a depositor to stake his tokens 
     @param amount deposit amount
    */
    function depositTokens(uint256 amount) external {
        require(amount > 0, "Invalid amount");

        stakingToken.transferFrom(msg.sender, address(this), amount);

        Staker storage staker = stakers[msg.sender];
        staker.stakedAmount = staker.stakedAmount.add(amount);
        staker.lastBlockChecked = block.number;

        emit Staked(msg.sender, amount);
    }

   /**
     @notice Allows a depositor to unstake tokens
     @param amount deposit to be withdrawn
     */

    function unstakeTokens(uint256 amount) external {
        require(amount > 0, "Invalid amount");

        Staker storage staker = stakers[msg.sender];
        require(staker.stakedAmount >= amount, "Insufficient staked amount");

        uint256 reward = calculateReward(msg.sender);
        uint256 totalAmount = amount.add(reward);

        staker.stakedAmount = staker.stakedAmount.sub(amount);
        staker.lastBlockChecked = block.number;
        staker.unclaimedRewards = 0;

        stakingToken.transfer(msg.sender, totalAmount);

        emit Withdrawn(msg.sender, amount);
        emit RewardClaimed(msg.sender, reward);
    }

   
   /**
     @notice Withraw rewwards
    */
    function claimReward() external {
        uint256 reward = calculateReward(msg.sender);
        require(reward > 0, "No available rewards");

        Staker storage staker = stakers[msg.sender];
        staker.lastBlockChecked = block.number;
        staker.unclaimedRewards = 0;

        stakingToken.transfer(msg.sender, reward);

        emit RewardClaimed(msg.sender, reward);
    }
   
   
   /**
     @notice internal fucntion to calculate rewards based on compound interest. 
     Applies the interest rate to the staked amount for each reward block, 
     adding the interest to the total rewards and increasing the staked amount accordingly.
     @param stakerAddress address of the depositor
    */
   
    function calculateReward(address stakerAddress) public returns (uint256) {
        Staker storage staker = stakers[stakerAddress];
        uint256 blocksSinceLastCheck = block.number.sub(staker.lastBlockChecked);
        uint256 rewardBlocks = blocksSinceLastCheck.div(BLOCKS_PER_REWARD);

        if (rewardBlocks == 0) {
            return 0;
        }

        uint256 stakedAmount = staker.stakedAmount;
        uint256 totalRewards = staker.unclaimedRewards;
        uint256 interestRate = INTEREST_RATE.mul(10**18); // Convert to 18 decimals

        for (uint256 i = 0; i < rewardBlocks; i++) {
            totalRewards = totalRewards.add(stakedAmount.mul(interestRate).div(100));
            stakedAmount = stakedAmount.add(stakedAmount.mul(interestRate).div(100));
        }

        staker.unclaimedRewards = totalRewards;
        return totalRewards;
    }

    /**
     @notice Approximates APY based on the assumption of 15 seconds per block
     @param stakeAmount  Amount that can be staked
     @param periodYears  Staking duration
    */

    function calculateAPY(uint256 stakeAmount, uint256 periodYears) public pure returns (uint256) 
    {
        uint256 interestRate = INTEREST_RATE.mul(10**18); // Convert to 18 decimals for precision
        uint256 blocksPerYear = uint256(365).mul(24).mul(60).mul(60).div(15); // Assuming 15 seconds per block
        uint256 totalCompounds = blocksPerYear.mul(periodYears);

        uint256 compoundMultiplier = interestRate.add(10**18).div(10**18); // Add 1 to the interest rate and convert to 18 decimals
        uint256 apyExponent = totalCompounds.mul(10**18).div(blocksPerYear);
        uint256 apy = compoundMultiplier**apyExponent.sub(10**18);

        return apy.sub(10**18).mul(stakeAmount).div(10**18);
    }

}