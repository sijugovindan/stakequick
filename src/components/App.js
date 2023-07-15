import React, {Component} from 'react'
import './App.css'
import Navbar from './Navbar.js'
import Web3 from 'web3'
import StakingToken from '../abis/StakingToken.json'
import StakingContract from '../abis/StakingContract.json'
import Info from './Info.js'

class App extends Component{

    //load to beginning
    async componentWillMount() {
        await this.loadWeb3()
        await this.loadBlockchainData()
      }

    // detect metamask
    async loadWeb3() {
        if(window.ethereum) {
            window.web3 = new Web3(window.ethereum)
            await window.ethereum.enable()
        }
        else if (window.web3) {
            window.web3 = new Web3(window.web3.currentProvider)
        }
        else {
            window.alert('Non ethereum browser detected. You should consider Metamask!')
        }
    }

    // get ABIS and contract 
    async loadBlockchainData() {
        const web3 = window.web3
        const accounts = await web3.eth.getAccounts()
        console.log(accounts)
        this.setState({account: accounts[0]})
        const networkId = await web3.eth.net.getId()
        console.log(networkId);

        
        //LOAD  TOKEN
        const stakingTokenData = StakingToken.networks[networkId]
        if(stakingTokenData) {
            const stakingToken = new web3.eth.Contract(StakingToken.abi, stakingTokenData.address)
            this.setState({stakingToken})
            let stakingTokenBalance = await stakingToken.methods.balanceOf(this.state.account).call()
            this.setState({ stakingTokenBalance: stakingTokenBalance.toString()})
            let rwdTokenBalance = await rwd.methods.calculateReward(this.state.account).call()
            this.setState({ rwdTokenBalance: rwdTokenBalance.toString()})
            console.log(rwdTokenBalance)
            console.log(stakingTokenBalance)
        } else {
            window.alert("StakingToken contract not deployed to detect network")
        }

        //Load StakingContract
        const stakingContractData = StakingContract.networks[networkId]
        if(stakingContractData) {
        const stakingContract = new web3.eth.Contract(StakingContract.abi, stakingContractData.address)
        this.setState({stakingContract})
        let stakingBalance = await stakingContract.methods.stakingBalance(this.state.account).call()
        this.setState({ stakingBalance: stakingBalance.toString()})
        console.log(stakingBalance)
        } else {
        window.alert("StakingContract  not deployed to detect network")
        }

        
        this.setState({loading: false})

    }
    

    constructor(props) {
        super(props)
        this.state = {
            account: '0x0',
            stakingToken: {},
            stakingContract: {},
            stakingTokenBalance: '0',
            rwdTokenBalance: '0',
            stakingBalance: '0',
            loading: true
        }
    }

    stakeTokens = (amount) => {
        this.setState({loading: true })
        this.state.stakingToken.methods.approve(this.state.stakingContract._address, amount).send({from: this.state.account}).on('transactionHash', (hash) => {
          this.state.stakingContract.methods.depositTokens(amount).send({from: this.state.account}).on('transactionHash', (hash) => {
            this.setState({loading:false})
          })
        }) 
      }
    
      unstakeTokens = () => {
        this.setState({loading: true })
        this.state.stakingContract.methods.unstakeTokens().send({from: this.state.account}).on('transactionHash', (hash) => {
          this.setState({loading:false})
        }) 
      }


    render() 
    {
        let content
        
        {
            this.state.loading ? content = <p id="loader" className='text-center' style={{color:'white', margin:'30px'}}>LOADING PLEASE...</p> : content = 
        
            <Info
            stakingTokenBalance={this.state.stakingTokenBalance}
            rwdBalance={this.state.rwdTokenBalance}
            stakingBalance={this.state.stakingBalance}
            stakeTokens={this.stakeTokens}
            unstakeTokens={this.unstakeTokens}
            stakingContract={this.stakingContract}
            />
        }
        
        return (
            
            <div  className="App" style={{ position: 'relative'}}>
            <div style={{ position: 'absolute'}}>
            </div>
            <Navbar account={this.state.account} />
            <div className="container-fluid mt-5">
                <div className="row">
                <main role="main" className="col-lg-12 ml-auto mr-auto" style={{ maxWidth: '600px'}} style={{ minHeight: '100vm'}}>
                    <div>
                    {content}
                    </div>
                </main>
            </div>
            </div>
            </div>
        );
    }
}
        
export default App;