// var EOwnership = artifacts.require("./EOwnership.sol");
var EOwnership = artifacts.require("./EOwnership.sol");
var SafeMath = artifacts.require("./SafeMath.sol");

module.exports = function(deployer) {
  // deployer.deploy(EOwnership);
  deployer.deploy(SafeMath);
  deployer.link(SafeMath, EOwnership)
  deployer.deploy(EOwnership);
};