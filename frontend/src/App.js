import './App.css';
import React, {Component} from 'react';
import Web3 from 'web3';
import Design from './contracts/Design.json';
import { BrowserRouter as Router, Route, Switch } from "react-router-dom";
import { Navigation, About, Home} from "./components/";
//Code:
class App extends React.Component{
  async componentWillMount() {
   await this.loadWeb3()
   await this.loadBlockchainData()
 }

 async loadWeb3() {
   if (window.ethereum) {
     window.web3 = new Web3(window.ethereum)
     await window.ethereum.enable()
   }
   else if (window.web3) {
     window.web3 = new Web3(window.web3.currentProvider)
   }
   else {
     window.alert('Non-Ethereum browser detected. You should consider trying MetaMask!')
   }
 }

 async loadBlockchainData() {
   const web3 = window.web3
   // Load account
   const accounts = await web3.eth.getAccounts()
   this.setState({ account: accounts[0] })

   const networkId = await web3.eth.net.getId()
   const networkData = Design.networks[networkId]
   if(networkData) {
     const abi = Design.abi
     const address = networkData.address
     const contract = new web3.eth.Contract(abi, address)
     this.setState({ contract })
     const totalSupply = await contract.methods.totalSupply().call()
     this.setState({ totalSupply })
    // Load Designs
     for (var i = 1; i <= totalSupply; i++) {
       const design = await contract.methods.getDesignName(i - 1).call()
       const uri = await contract.methods.getURI(i - 1).call()
       const price =await contract.methods.getPrice(i - 1).call()

       this.setState({
         designs: [...this.state.designs, design, uri, price]
       })
     }
   } else {
     window.alert('Smart contract not deployed to detected network.')
   }
 }

 mint = (design, uri, price) => {
   if(this.state.contract)
   //this.state.contract.methods.mint(design,tokenURI, price)
   this.state.contract.methods.mint(design, uri, price).send({ from: this.state.account })
   .once('receipt', (receipt) => {
     this.setState({
       designs: [...this.state.desings,design(design, uri, price)]
     })
   })
 }
 constructor(props) {
     super(props);
     this.state = {
       account: '',
       contract: null,
       buffer:'',
       web3: null,
       myDesigns: [],
       totalSupply: 0,
       designs: []
     }
   }
   captureFile = (event) =>{
     event.preverntDefault()
     const file = event.target.files[0]
     const reader = new window.FileReader()
     reader.readAsArrayBuffer(file)
     reader.onloadend = () => {
       this.convertToBuffer(reader)
      }
     console.log('file captured ..')
   }

   convertToBuffer = async (reader) => {
     const buffer = await Buffer.from(reader.result);
     this.setState({buffer});
   }

   //the user interface content
  render() {
  return (
    <div className="App">
      <Router>
       <Navigation />
       <Switch>
            <Route path="/home" exact component={() => <home />} />
         <Route path="/about" exact component={() => <About />} />
       </Switch>
     </Router>
     <p id = "account"> Hello world!</p>
      {this.state.account}
     <div className="container-fluid mt-5">
         <div className="row">
           <main role="main" className="col-lg-12 d-flex text-center">
             <div className="content mr-auto ml-auto">
               <h1>Create Fashion Design Sketch</h1>
               <form onSubmit={(event) => {
                 event.preventDefault()
                 const design = this.design.value
                 const price = this.price.value
                 const tokenURI = this.tokenURI.value
                 this.mint(design,tokenURI, price)
                 //this.mint(design)
               }}>
                 <input
                   type='text'
                   className='form-control mb-1'
                   placeholder='e.g. name'
                   ref={(input) => { this.design = input }}
                 />
                 <input
                   type='file'
                   className='form-control mb-1'
                   placeholder='e.g. #uri'
                   onChange = {this.captureFile}
                   ref={(input2) => { this.tokenURI = input2 }}
                 />
                 <input
                   type='text'
                   className='form-control mb-1'
                   placeholder='e.g. #price'
                   ref={(input1) => { this.price = input1 }}
                 />

                 <input
                   type='submit'
                   className='btn btn-block btn-primary'
                   value='Mint'
                 />
               </form>
             </div>
           </main>
         </div>
         </div>
     <div className = "row text-centre">
     { this.state.designs.map((design, key) => {
     return(
       <div key={key} className="col-md-4 mb-4">
                 <div className="token"></div>
                 <div>{design}</div>
                 //form
                   <input
                     type = 'submit'
                     value = 'Buy now'
                     />
               </div>
     )})}
     </div>
   </div>

  );
}
}

export default App;
