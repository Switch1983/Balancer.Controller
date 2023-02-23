// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./base/BaseController.sol";

contract ReserveRatioController is BaseController {

    // Minimum reserve ratio
    uint defaultMinRatio;
    
    constructor(uint _defaultMinRatio) BaseController()
    {
        defaultMinRatio = _defaultMinRatio;
    }

    // Managed Pools
    mapping(address => uint) public reserveRatio; // MP Address and its Reserve Ratio


    // Checks if the ratio is breached and transfers as necessary
    function runCheck(address _poolToCheck) public view restricted returns(uint)
    {
        // Retrieve balance for pool
        // Get bpt balance from vault
        // Calculate reserve requirement as deposits * rr
        // If this is higher than reserve, transfer difference
        return 1;
    }

    function setReserveRatio(address _poolAddress, uint _ratio) public restricted {
        reserveRatio[_poolAddress] = _ratio;
    }

    function getManagedPoolRatio(address _poolAddress) public view returns (uint) {
        return reserveRatio[_poolAddress];
    }
}
