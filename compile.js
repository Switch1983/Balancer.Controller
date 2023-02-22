const path = require('path');
const fs = require('fs');
const solc = require('solc');

const basePath = path.resolve(__dirname, 'contracts/base', 'BaseController.sol');
const baseSource = fs.readFileSync(basePath, 'utf8');

const bondingCurveControllerPath = path.resolve(__dirname, 'contracts', 'BondingCurveController.sol');
const bondingCurveControllerSource = fs.readFileSync(bondingCurveControllerPath, 'utf8');

const input = {
  language: 'Solidity',
  sources: {
    'base/BaseController.sol': {
      content: baseSource,
    },
    'BondingCurveController.sol': {
      content: bondingCurveControllerSource,
    }
  },
  settings: {
    outputSelection: {
      '*': {
        '*': ['*'],
      },
    },
  },
};
 
module.exports = JSON.parse(solc.compile(JSON.stringify(input))).contracts[
  'BaseController.sol', 'BondingCurveController.sol'
].BondingCurveController;