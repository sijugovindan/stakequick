const StakingToken = artifacts.require('StakingToken')
const StakingContract = artifacts.require('StakingContract')


module.exports = async function(deployer, network, accounts) {

  // Deploy StakingToken
  await deployer.deploy(StakingToken)
  const stakingToken = await StakingToken.deployed()

  // Deploy Staking Contract
  await deployer.deploy(StakingContract, stakingToken.address)
  const stakingContract = await StakingContract.deployed()

  // Transfer 1million reward tokens(STT itself) to StakingContract (1 million)
  await stakingToken.transfer(stakingContract.address, '1000000000000000000000000')

  // Transfer 100 STT tokens to a depositor
  await stakingToken.transfer(accounts[1], '100000000000000000000')


}
