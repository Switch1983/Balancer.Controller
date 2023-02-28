const BondingCurveController = artifacts.require("BondingCurveController");

module.exports = function(deployer) {
  deployer.deploy(BondingCurveController, '0xA18808989E7EB0FcF0932fd00D007F3C118B78E7', '0xA18808989E7EB0FcF0932fd00D007F3C118B78E7');
};
