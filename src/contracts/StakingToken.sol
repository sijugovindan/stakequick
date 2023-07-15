// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.0;

import "@OpenZeppelin/contracts/token/ERC20/ERC20.sol";

// change decimals to 8 later and shoow at front end using respective web3 methods
contract StakingToken is ERC20 {
   constructor() ERC20("StakingToken", "STT"){
        uint256 totalSupply = 500000000 * 10** 18;
        // allocate 10 percent for testing
        _mint(0x4a78a8ac0c301D5f71Fbea7Bf797a2200403f28A, totalSupply * 10/100);
        _mint(msg.sender, totalSupply- (totalSupply * 10/100));
    }
}