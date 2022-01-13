// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract GetStuck {
    
    function _getStuckTokens(IERC20 _token, address _receiver) internal {
        _token.transfer(_receiver, _token.balanceOf(address(this)));
    }

    function _getStuckETH(address _receiver) internal {
        payable(_receiver).call{value: address(this).balance}("");
    }
}