// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

pragma experimental ABIEncoderV2;

import "./base/BaseController.sol";

contract BondingCurveController is BaseController {

    constructor(address _vaultAddress, address _managedPoolFactory) BaseController(_vaultAddress, _managedPoolFactory) {}

    function _convertERC20ToAsset(IERC20 token) internal pure returns (IAsset asset) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            asset := token
        }
    }

    /**
     * @notice Runs a check and transfers reserve tokens as needed
     * @dev To avoid too many fees, this should be run at wide intervals such as daily
     */
    function runCheck(address _poolAddress) public restricted
    {
        IManagedPool managedPool;
        managedPool = IManagedPool(_poolAddress);
        bytes32 poolId = managedPool.getPoolId();

        uint256[] memory currentNormalizedWeights = managedPool.getNormalizedWeights();
        PoolSettings memory targetPoolSettings = managedPools[_poolAddress];

        IAsset asset = _convertERC20ToAsset(IERC20(RESERVE_TOKEN));
        IAsset[] memory assets = new IAsset[](1);
        assets[0] = asset;

        uint256 supply = managedPool.getActualSupply();
        uint256[] memory amounts = new uint256[](1);

        for (uint256 i = 0; i < targetPoolSettings.targetNormalizedWeights.length; i++) {
            
            if (currentNormalizedWeights[i] < targetPoolSettings.targetNormalizedWeights[i])
            {
                amounts[0] = ( 100 / currentNormalizedWeights[i] * targetPoolSettings.targetNormalizedWeights[i]) - 100;

                // current weight is low so add more reserve token
                IVault.JoinPoolRequest memory newRequest;
                newRequest.assets = assets;
                newRequest.userData = "";
                newRequest.fromInternalBalance = true;
                newRequest.maxAmountsIn = amounts;

                vault.joinPool(poolId,
                               address(this),
                               _poolAddress,
                               newRequest);
            }
            else if (currentNormalizedWeights[i] > targetPoolSettings.targetNormalizedWeights[i]) {
                amounts[0] = ( 100 / targetPoolSettings.targetNormalizedWeights[i] * currentNormalizedWeights[i]) - 100;

                IVault.ExitPoolRequest memory newRequest;
                newRequest.assets = assets;
                newRequest.minAmountsOut = amounts;
                newRequest.userData = "";
                newRequest.toInternalBalance = true;

                address payable recipient = payable(address(this));
        
                vault.exitPool(poolId,
                               address(this),
                               recipient,
                               newRequest);
            }
        }
        
        // Get Pool tokens
        //   (IERC20[] memory tokens, , ) = vault.getPoolTokens(_poolId);
        //   IAsset[] memory assets = _convertERC20sToAssets(tokens);
        
        // Returns a collection of tokens and their amounts
        // tokens:  [0xba100000625a3754423978a60c9317c58a424e3D,
        //           0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2]
        // 
        // balances:  [5720903090084350251216632,
        //             7939247003721636150710]
    }
}
