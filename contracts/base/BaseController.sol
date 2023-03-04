// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

pragma experimental ABIEncoderV2;

import "@balancer-labs/v2-interfaces/contracts/vault/IVault.sol";
import "@balancer-labs/v2-interfaces/contracts/pool-utils/IManagedPool.sol";
import "../ManagedPoolFactory.sol";

interface IController {
   function runCheck(bytes32 _poolId) external view returns(uint);
}

abstract contract BaseController is IController {
    address public manager;
    IVault internal immutable vault;
    ManagedPoolFactory internal immutable managedPoolFactory;

    mapping(address => bool) public managedPools; // Pools and their managers

    constructor(address _vaultAddress, address _managedPoolFactory) {
        manager = msg.sender;
        vault = IVault(_vaultAddress);
        managedPoolFactory = ManagedPoolFactory(_managedPoolFactory);
    }
    
    function createPool(string memory _name,
                        string memory _symbol,
                        address[] memory _tokens,
                        uint256[] memory _normalizedWeights,
                        address[] memory _assetManagers,
                        uint256 _swapFeePercentage,
                        bool _swapEnabledOnStart,
                        bool _mustAllowlistLPs,
                        uint256 _managementAumFeePercentage,
                        uint256 _aumFeeId) public restricted {

        ManagedPoolSettings.NewPoolParams memory poolParams;
        poolParams.name = _name;
        poolParams.symbol = _symbol;
        poolParams.tokens = _tokens;
        poolParams.normalizedWeights = _normalizedWeights;
        poolParams.assetManagers = _assetManagers;
        poolParams.swapFeePercentage = _swapFeePercentage;
        poolParams.swapEnabledOnStart = _swapEnabledOnStart;
        poolParams.mustAllowlistLPs = _mustAllowlistLPs;
        poolParams.managementAumFeePercentage = _managementAumFeePercentage;
        poolParams.aumFeeId = _aumFeeId;

        address _poolAddress = managedPoolFactory.create(poolParams, address(this));
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

    function updateWeightsGradually(
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

    function addToken(
        address poolAddress,
        IERC20 tokenToAdd,
        address assetManager,
        uint256 tokenToAddNormalizedWeight,
        uint256 mintAmount,
        address recipient) public restricted {

        IManagedPool managedPool;
        managedPool = IManagedPool(poolAddress);
        managedPool.addToken(tokenToAdd, assetManager, tokenToAddNormalizedWeight, mintAmount, recipient);
    }

    function removeToken(
        address poolAddress,
        IERC20 tokenToRemove,
        uint256 burnAmount,
        address sender) public restricted {

        IManagedPool managedPool;
        managedPool = IManagedPool(poolAddress);
        managedPool.removeToken(tokenToRemove, burnAmount, sender);
    }

    function withdrawFunds(
        address recipientAddress,
        address tokenAddress,
        uint256 amount) public restricted {

        IERC20 _token = IERC20(tokenAddress);
        _token.transferFrom(address(this), recipientAddress, amount);
    }

    function depositTokens(
        uint amount,
        address tokenAddress) public restricted checkAllowance(amount, tokenAddress) {
        IERC20 token = IERC20(tokenAddress);
        token.transferFrom(msg.sender, address(this), amount);
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

    // Modifier to check token allowance
    modifier checkAllowance(uint amount, address tokenAddress) {
        IERC20 token = IERC20(tokenAddress);
        require(token.allowance(msg.sender, address(this)) >= amount, "Error");
        _;
    }
}
