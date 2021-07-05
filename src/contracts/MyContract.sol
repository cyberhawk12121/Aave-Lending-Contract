// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;

import {ILendingPool} from "./AaveInterfaces/ILendingPool.sol";
import {ILendingPoolAddressesProvider} from "./AaveInterfaces/ILendingPoolAddressesProvider.sol";
import {IERC20} from "./IERC20.sol";

contract AaveDeposit{
  address owner;  // Owner of this contract
  address dai=address(0x6B175474E89094C44Da98b954EedeAC495271d0F);

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