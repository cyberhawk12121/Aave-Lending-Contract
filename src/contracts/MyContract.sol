pragma solidity 0.6.12;

import {LendingPool} from "https://github.com/aave/protocol-v2/blob/ice/mainnet-deployment-03-12-2020/contracts/protocol/lendingpool/LendingPool.sol";
import {LendingPoolAddressesProvider} from "https://github.com/aave/protocol-v2/blob/ice/mainnet-deployment-03-12-2020/contracts/protocol/configuration/LendingPoolAddressesProvider.sol";
import {ERC20} from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/token/ERC20/ERC20.sol";

contract MyContract {
    uint256 referral = 0;
    address public owner;
    address daiAddress = address(0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa); // Kovan DAI
    
    mapping(address=>uint) public   depositedAmt;
    mapping(address=>bool)  public Hasdeposited; // If the user has deposited
    address[] public depositers;// account of all who have deposited

    LendingPoolAddressesProvider provider = LendingPoolAddressesProvider(address(0x506B0B2CF20FAA8f38a4E2B524EE43e1f4458Cc5)); // Kovan address, for other addresses: https://docs.aave.com/developers/deployed-contracts/deployed-contract-instances 
    LendingPool lendingPool = LendingPool(provider.getLendingPool());
        
    constructor() public{
        owner= msg.sender;
    }

    receive() external payable {}
    
    function depositToken() public payable{
        uint amt= msg.value;
        address depositer= msg.sender;
        require(amt>0, "Amount cannot be smaller than 0"); 
        lendingPool.deposit(daiAddress, amt, msg.sender, 0);
        // ERC20(daiAddress).transferFrom(msg.sender, address(this), amt);  // takes (sender, receiver, amount)
        depositedAmt[depositer] += amt;    
        // To prevent double counting of depositers we'll use the map and if their name is present in it we'll not add them in the depositors list (Cuz then we might issue them tokens multiple times)
        if(!Hasdeposited[depositer]){
            depositers.push(depositer);
        }
        Hasdeposited[depositer]= true;
    } 

    function withdraw(uint256 amt) public{
        uint balance= depositedAmt[msg.sender];
        require(balance<amt, "Deposited amount cannot be less than withdrawing amount");
        uint256 drawn= lendingPool.withdraw(daiAddress, amt, msg.sender);  // Returns with the added interest
        uint netInterest= drawn-amt;

        // Update the depositors the status
        if(depositedAmt[msg.sender]==0){
            Hasdeposited[msg.sender]=false;
        }
        depositedAmt[msg.sender]-= amt;
    }

}