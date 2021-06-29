const MyContract= artifacts.require('MyContract');

module.exports= async function(deployer, network, accounts){
    deployer.deploy(MyContract);
}