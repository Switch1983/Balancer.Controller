// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./base/BaseController.sol";

contract BondingCurveController is BaseController {

    constructor(uint _defaultMinRatio) BaseController() {}

    // As liquidity is added/removed, pool tokens are minted/burned and a price calculated for the pool tokens
    // according to the bonding curve formula. 
    function runCheck(address _poolToCheck) public view restricted returns(uint)
    {
        // Retrieve balance for pool
        // Calculate reserve requirement as deposits * rr
        // If this is higher than reserve, transfer difference
        return 1;
    }
}
