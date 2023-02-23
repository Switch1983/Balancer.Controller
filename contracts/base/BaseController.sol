// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@balancer-labs/v2-interfaces/contracts/vault/IVault.sol";
import "@balancer-labs/v2-interfaces/contracts/pool-utils/IManagedPool.sol";

interface IController {
   function runCheck(bytes32 _poolId) external view returns(uint);
}

abstract contract BaseController is IController {
    address public manager;
    IVault internal immutable vault;

    mapping(address => bool) public managedPools; // Pools and their managers

    constructor(address _vaultAddress) {
        manager = msg.sender;
        vault = IVault(_vaultAddress);
    }
    
    function registerPool(address _poolAddress) public restricted {
        managedPools[_poolAddress] = true;
    }

    function transferManagement(address _manager) public restricted {
        manager = _manager;
    }
    
    function updateSwapFeeGradually(
        address poolAddress,
        uint256 startTime,
        uint256 endTime,
        uint256 startSwapFeePercentage,
        uint256 endSwapFeePercentage) public restricted {

        IManagedPool managedPool;
        managedPool = IManagedPool(poolAddress);
        managedPool.updateSwapFeeGradually(startTime, endTime, startSwapFeePercentage, endSwapFeePercentage);
    }

    function updateSwapFeeGradually(
        address poolAddress,
        uint256 startTime,
        uint256 endTime,
        IERC20[] memory tokens,
        uint256[] memory endWeights) public restricted {

        IManagedPool managedPool;
        managedPool = IManagedPool(poolAddress);
        managedPool.updateWeightsGradually(startTime, endTime, tokens, endWeights);
    }

    function setJoinExitEnabled(
        address poolAddress,
        bool joinExitEnabled) public restricted {

        IManagedPool managedPool;
        managedPool = IManagedPool(poolAddress);
        managedPool.setJoinExitEnabled(joinExitEnabled);
    }

    function setSwapEnabled(
        address poolAddress,
        bool swapEnabled) public restricted {

        IManagedPool managedPool;
        managedPool = IManagedPool(poolAddress);
        managedPool.setSwapEnabled(swapEnabled);
    }

    function setMustAllowlistLPs(
        address poolAddress,
        bool mustAllowlistLPs) public restricted {

        IManagedPool managedPool;
        managedPool = IManagedPool(poolAddress);
        managedPool.setMustAllowlistLPs(mustAllowlistLPs);
    }

    function addAllowedAddress(
        address poolAddress,
        address member) public restricted {

        IManagedPool managedPool;
        managedPool = IManagedPool(poolAddress);
        managedPool.addAllowedAddress(member);
    }

    function removeAllowedAddress(
        address poolAddress,
        address member) public restricted {

        IManagedPool managedPool;
        managedPool = IManagedPool(poolAddress);
        managedPool.removeAllowedAddress(member);
    }

    function collectAumManagementFees(
        address poolAddress) public restricted {

        IManagedPool managedPool;
        managedPool = IManagedPool(poolAddress);
        managedPool.collectAumManagementFees();
    }
    
    function setManagementAumFeePercentage(
        address poolAddress,
        uint256 managementAumFeePercentage) public restricted {

        IManagedPool managedPool;
        managedPool = IManagedPool(poolAddress);
        managedPool.setManagementAumFeePercentage(managementAumFeePercentage);
    }

    function setCircuitBreakers(
        address poolAddress,
        IERC20[] memory tokens,
        uint256[] memory bptPrices,
        uint256[] memory lowerBoundPercentages,
        uint256[] memory upperBoundPercentages) public restricted {

        IManagedPool managedPool;
        managedPool = IManagedPool(poolAddress);
        managedPool.setCircuitBreakers(tokens, bptPrices, lowerBoundPercentages, upperBoundPercentages);
    }

    /**
     * @dev This helper function is a fast and cheap way to convert between IERC20[] and IAsset[] types
     */
    function _convertERC20sToAssets(IERC20[] memory tokens) internal pure returns (IAsset[] memory assets) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            assets := tokens
        }
    }

    modifier restricted() {
        require(msg.sender == manager);
        _;
    }
}
