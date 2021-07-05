// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;

/*
    Import: 
    1. ERC20 
    2. LendingPool
    3. LendingPoolReceiverAddress
*/  

import "https://github.com/aave/protocol-v2/blob/ice/mainnet-deployment-03-12-2020/contracts/interfaces/ILendingPool.sol";
import "https://github.com/aave/protocol-v2/blob/ice/mainnet-deployment-03-12-2020/contracts/interfaces/ILendingPoolAddressesProvider.sol";
import "./IERC20.sol";

contract AaveDeposit{
  uint256 amt;    // Amount to deposited
  address owner;  // Owner of this contract
  address dai=address(0x6b175474e89094c44da98b954eedeac495271d0f);

  mapping(address=>bool) isDepositing;//  When the client has deposited any amount: DEFAULT=0
  mapping(address=>uint) amtDeposited;//  The amount client has deposited: DEFAULT= false

  address[] depositers;// Record of all the depositers

  ILendingPoolAddressesProvider provider;
  ILendingPool pool;

  modifier onlyOwner{
    require(msg.sender==owner, "Only owner can call");
    _;
  }

  constructor(address _provider) public{
    owner= msg.sender;
    provider= ILendingPoolAddressesProvider(_provider);
  }
  
  function depositToAave() public payable{
    require(msg.value>0,"Depositing amount cannot be 0");
    pool= ILendingPool(provider.getLendingPool());
    pool.deposit(dai,msg.value, address(this), 0);
    // recording
    amtDeposited[msg.sender]+= msg.value; // amtDeposited is the total deposited amount i.e., the balance
    if(isDepositing[msg.sender]==false){
      isDepositing[msg.sender]=true;
      depositers.push(msg.sender);
    }
  }//depositToAave
  
  function withdrawFromAave(uint amt) public returns (uint){
    address caller= msg.sender;
    pool= ILendingPool(provider.getLendingPool());
    uint drawn= pool.withdraw(dai, amt, caller);

    // Update record
    amtDeposited[caller]-= drawn;
    if(amtDeposited[caller]<0){
      isDepositing[caller]=false;
    }//if
  }// withdrawFromAave
}// Contract