const BondingCurveController = artifacts.require("BondingCurveController");

module.exports = function(deployer) {
  deployer.deploy(BondingCurveController, '0xba100000625a3754423978a60c9317c58a424e3D');
};
