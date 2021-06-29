pragma solidity ^0.6.0;

import { ILendingPoolAddressesProvider } from "https://github.com/aave/protocol-v2/blob/ice/mainnet-deployment-03-12-2020/contracts/interfaces/ILendingPoolAddressesProvider.sol";
import { ILendingPool } from "https://github.com/aave/protocol-v2/blob/ice/mainnet-deployment-03-12-2020/contracts/interfaces/ILendingPool.sol";
import "https://github.com/aave/aave-protocol/blob/master/contracts/flashloan/base/FlashLoanReceiverBase.sol";

import "@openzeppelin-solidity/contracts/math/SafeMath.sol";
import "@openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

/* 
    1. Letting the depositor deposity the amount, and we put it directly in Aave Lending pool not in the contract
    2. The depositor gets the aToken from Aave
    3. Meanwhile we do keep checks of Depositors in the mapping
    4. The depositor can take the money out as well whenever they wish, and we keep the interest.
*/

contract MyContract is FlashLoanReceiverBase {
    uint256 referral = 0;
    address public owner;
    address daiAddress = address(0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa); // Kovan DAI
    string public name= "Dapp Bank";

    ILendingPoolAddressesProvider provider = LendingPoolAddressesProvider(address(0x24a42fD28C976A61Df5D00D0599C34c4f90748c8));
    ILendingPool lendingPool = LendingPool(provider.getLendingPool());
    // Map to take note of the flow of money in the contract
    mapping(address=>uint) public   depositedAmt;
    mapping(address=>bool)  public Hasdeposited; // If the user has deposited
    address[] public depositers;// account of all who have deposited

    // Get reference of Dapp and Dai token on the network
    constructor(DappToken _dappToken, DaiToken _daiToken)public{
        owner= msg.sender;
    }

    receive() external payable {}
    function() external payable{}
    
    function depositToken() public payable{
        uint amt= msg.value;
        address depositer;
        require(amt>0, "Amount cannot be smaller than 0"); 
        lendingPool.deposit(daiAddress, amt, msg.sender, 0);
        // IERC20(daiAddress).transferFrom(msg.sender, address(this), amt);  // takes (sender, receiver, amount)
        depositedAmt[depositer] += amt;    
        // To prevent double counting of depositers we'll use the map and if their name is present in it we'll not add them in the depositors list (Cuz then we might issue them tokens multiple times)
        if(!Hasdeposited[depositer]){
            depositers.push(depositer);
        }
        Hasdeposited[depositer]= true;
    }   // end deposit()

//  Custom issueToken is not needed as the aToken from Aave directly reaches the depositer
    // function issueTokens() public{
    //     require(msg.sender==owner, "caller must be the owner" );
    //     for(uint i=0; i<depositers.length; i++){
    //         address recipient=depositers[i];
    //         uint balance= depositedAmt[recipient];
    //         // Reward them as much Dapp tokens as the number of Dai tokens they've deposited 
    //         if(balance>0){
    //             dappToken.transfer(recipient, balance);
    //         }
    //     }
    // }   // end issueTokens()

    function withdraw(uint256 amt) public returns (uint256){
        uint balance= depositedAmt[msg.sender];
        require(balance<amt, "Deposited amount cannot be less than withdrawing amount");
        uint256 drawn= lendingPool.withdraw(daiAddress, amt, msg.sender);  // Returns with the added interest
        uint netInterest= drawn-amt;
        
        // IMP: I COULD ALSO CALL THE DEPOSIT AND WITHDRAW FROM THIS CONTRACT ITSELF AND SO, I'D RECEIVE THE AMOUNT THEN I KEEP PORTION OF THE INTEREST (Like 10%) then transfer remaining to the user
        
        // if(netInterest>0){
        //     transferFrom(msg.sender, address(this), netInterest);
        // }

        // Update the depositors the status if he took out everything
        if(depositerAmt[msg.sender]==0){
            Hasdeposited[msg.sender]=false;
        }
        depositedAmt[msg.sender]-= amt;
        
        return netInterest;
    }   // end withdraw

}   // end contract