//@Author: Sarah Al Yahyaei
//@Date 20 Feb 2021
//Aim: This smart contract to manage a design sketch token


pragma solidity ^0.5.0;

import  "@openzeppelin/contracts/token/ERC721/ERC721Full.sol";

import  "@openzeppelin/contracts/ownership/ownable.sol";

contract Design is ERC721Full, Ownable {

using SafeMath for uint256;

//Data Structucre to represent a design sketch
  struct DesignSketch{
    //A name for the design sketch
    string design;
    //The image hash that are stored in the IPFS database
    string ipfsHash;
    uint price;
  }

//Store address of all designers
//An array to store designs hashes stored in this contract
DesignSketch[] public designs;
mapping(uint => address) _creators;
//map every designer address to their design
mapping(address => uint256) _ownerOfDesignsCount;
//Map an owner to a design sketch
mapping(address => DesignSketch) _designData;
// Code source: https://medium.com/quiknode/erc-721-token-ea80c7195102

//every token ID for a design sketch mapped to an owner
mapping(uint256 => address) _tokenOwner;
//used to transfer behalf of the owner
mapping (uint256 => address) private _tokenApprovals;
//to count no. of
//tokens for an address
mapping(address => mapping(address => bool)) private _operatorApprovals;
//To store a design sketch image hash and use it to check for uniquness for other design sketchs.
mapping(string => bool) _designExists;

//Contractor
constructor () ERC721Full("Design","DESIGN") public{
}

/* A mint function to create a new token
  the underscor idenfifes a local variable
  reistric the method to owner only
  It should check the design hash */
function mint(string memory _design, string memory _ipfsHash, uint256 _price) public {
  //require unique design, if false wont executre code
  require(!_designExists[_ipfsHash]);
  //To create new tokens
  //_id is the token id
  DesignSketch memory _designSketch = DesignSketch( {
    design:_design,
    ipfsHash: _ipfsHash,
     price: _price
    });

  uint _id = designs.push(_designSketch);
    _mint(msg.sender, _id);
  //  _designData[msg.sender] = _designSketch;
    _ownerOfDesignsCount[msg.sender] = _id;
  _designExists[_ipfsHash] = true;
  _creators[_id] = msg.sender;
  _ownerOfDesignsCount[msg.sender]++;
}



//Return variables
function getDesignsStruct(uint index) public view returns(string memory, string memory, uint){
  DesignSketch memory designSketch = designs[index];
  return(designSketch.design, designSketch.ipfsHash, designSketch.price);
}


function getDesignName(uint index) public view returns(string memory){
  DesignSketch memory designSketch = designs[index];
  return designSketch.design;
}
function getPrice(uint index) public view returns(uint){
  DesignSketch memory designSketch = designs[index];
  return designSketch.price;
}
//Get ipfs hash
function getURI(uint index) public view returns(string memory){
  DesignSketch memory designSketch = designs[index];
  return designSketch.ipfsHash;
}

/*  *************************************
    TO DELETE A TOKEN FROM THE BLOCKCHAIN
    *************************************
 */
function destroyToken (uint256 tokenId) public {
  //Check if the one who calls the contract is the owner of the token that
  // want to delete from the blockchain
  require(msg.sender == ownerOf(tokenId));
  _burn(tokenId);
}

//How to return an array of design sketchs??
//To get all the tokens that owns by an address
/* function getTokens(address owner) public returns (uint256){

} */

/*  **********************************
        TO TRADE A DESIGN SKETCH
    **********************************
 */
//To transfware ownership of a design to another address
function transferOwnership(address to, uint _tokenId) public {
  require(msg.sender != ownerOf(_tokenId));
  transferFrom(ownerOf(_tokenId), to , _tokenId);
}

//Code source for the following functions: https://medium.com/quiknode/erc-721-token-ea80c7195102
function balanceOf(address owner) public view returns(uint256){
  require(owner != address(0));
  return _ownerOfDesignsCount[owner];
}

function ownerOfToken(uint256 tokenId) public view returns (address){
  require(owner != address(0));
  address owner = _tokenOwner [tokenId];
  return owner;
}

//Code source for this section : https://github.com/zeeshanh/suum/blob/master/contracts/Collectible.sol

function _transfer(address _from, address _to, uint256 _tokenId) private {
  _ownerOfDesignsCount[_to] = _ownerOfDesignsCount[_to].add(1);
  _ownerOfDesignsCount[_from] = _ownerOfDesignsCount[msg.sender].sub(1);
  _tokenOwner[_tokenId] = _to;
  emit Transfer(_from, _to, _tokenId);
}

function transfer(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
    _transfer(msg.sender, _to, _tokenId);
  }
  function approve(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
   _tokenApprovals[_tokenId] = _to;
   emit Approval(msg.sender, _to, _tokenId);
 }

 function takeOwnership(uint256 _tokenId) public {
   require(_tokenApprovals[_tokenId] == msg.sender);
   address owner = ownerOfToken(_tokenId);
   _transfer(owner, msg.sender, _tokenId);
 }

 function buyCollectible(uint256 _tokenId) public payable returns (bool){
    require(msg.value >= designs[_tokenId].price);
    address oldOwner = ownerOfToken(_tokenId);
    _transfer(oldOwner, msg.sender, _tokenId);
    oldOwner.transfer(msg.value/10*8);
    creators[_tokenId].transfer(msg.value/10);
    return true;
  }
