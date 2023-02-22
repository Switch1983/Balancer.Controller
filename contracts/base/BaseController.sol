// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IController {
   function runCheck(address _poolToCheck) external view returns(uint);
}

abstract contract BaseController is IController {
    address public manager;

    // Managed Pools
    mapping(address => uint) public reserveRatio; // MP Address and its Reserve Ratio

    // Minimum reserve ratio
    uint defaultMinRatio;

    constructor(uint _defaultMinRatio) {
        defaultMinRatio = _defaultMinRatio;
        manager = msg.sender;
    }
    
    function transferManagement(address _newManager) public restricted {
        manager = _newManager;
    }

    function setReserveRatio(address _poolAddress, uint _ratio) public restricted {
        reserveRatio[_poolAddress] = _ratio;
    }
    
    modifier restricted() {
        require(msg.sender == manager);
        _;
    }
    
    function getManagedPoolRatio(address _poolAddress) public view returns (uint) {
        return reserveRatio[_poolAddress];
    }
}   