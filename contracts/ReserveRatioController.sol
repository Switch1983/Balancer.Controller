// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./base/BaseController.sol";

contract ReserveRatioController is BaseController {

    constructor(uint _defaultMinRatio) BaseController(_defaultMinRatio) {}

    // Checks if the ratio is breached and transfers as necessary
    function runCheck(address _poolToCheck) public view restricted returns(uint)
    {
        // Retrieve balance for pool
        // Get bpt balance from vault
        // Calculate reserve requirement as deposits * rr
        // If this is higher than reserve, transfer difference
        return 1;
    }
}
