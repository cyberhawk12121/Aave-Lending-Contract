const { assert } = require('chai');

const MyContract= artifacts.require('MyContract');

require('chai')
    .use(require('chai-as-promised'))
    .should()

function tokens(n) {
    return web3.utils.toWei(n, 'ether');
}

contract("MyContract", (accounts)=>{
    let myContract
    before(async ()=>{
        myContract= await MyContract.deployed();
    })

    describe('deployment', async ()=>{
        it('deployed successfully', async()=>{
            const address= myContract.address
            assert.notEqual(address, 0x0)
            assert.notEqual(address, '')
            assert.notEqual(address,null)
            assert.notEqual(address, undefined)
        })
    })

    describe('Withdraw', async ()=>{
        it('returns some amount', async ()=>{
            const address= myContract.address
            const result= await myContract.withdraw(tokens("1"))
            assert.isAbove(result, 0, "The withdrawal amount should be greater than 0")
            assert.notEqual(address, null)
            assert.notEqual(address, undefined)
        })
    })

    // Other tests can be:
    // 1. Depositing amount is not 0
    // 2. Or function to check the mappings
    // etc.
})