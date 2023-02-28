// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

pragma experimental ABIEncoderV2;

import "./base/BaseController.sol";

contract BondingCurveController is BaseController {

    constructor(address _vaultAddress, address _managedPoolFactory) BaseController(_vaultAddress, _managedPoolFactory) {}

    // As liquidity is added/removed, pool tokens are minted/burned and a price calculated for the pool tokens
    // according to the bonding curve formula. 
    function runCheck(bytes32 _poolId) public view restricted returns(uint)
    {
        // Get Pool tokens
        // (tokens, balances, lastChangeBlock) = vault.getPoolTokens(poolId);
        (IERC20[] memory tokens, , ) = vault.getPoolTokens(_poolId);
        IAsset[] memory assets = _convertERC20sToAssets(tokens);

        // Returns a collection of tokens and their amounts
        // tokens:  [0xba100000625a3754423978a60c9317c58a424e3D,
        //           0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2]
        // 
        // balances:  [5720903090084350251216632,
        //             7939247003721636150710]

        // Calculate the weighting here
        // https://docs.balancer.fi/reference/math/weighted-math.html#overview

        // Check if outside of bounds and if so, transfer tokens

        // const uint supply = bpt.totalSupply();

        // pool.getOwner();
        // pool.getPausedState();

        return assets.length;
    }
}
