// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IController {
   function runCheck(address _poolToCheck) external view returns(uint);
}

abstract contract BaseController is IController {
    address public manager;

    constructor() {
        manager = msg.sender;
    }
    
    function transferManagement(address _newManager) public restricted {
        manager = _newManager;
    }
    
    modifier restricted() {
        require(msg.sender == manager);
        _;
    }
}