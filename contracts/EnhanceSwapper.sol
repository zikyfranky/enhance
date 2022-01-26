//SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IRouter.sol";


 /// @title Enable direct buy for the Enhance Token
 /// @author Isaac Frank (https://zikyfranky.com)
 /// @notice Send Native funds to the contract to get the Enhance Token
 /// @dev Just a direct buy for the Enhance Token
contract EnhanceSwapper is Ownable{
    
    IRouter02 public router = IRouter02(0xE804f3C3E6DdA8159055428848fE6f2a91c2b9AF);
    address public ENHANCE = 0xA001862BA0866Ee3e3a2613fAb5954861452B9Bf;
    
    constructor() {
        // transfer ownership to mission control
        transferOwnership(0x7054281a2808C56c372B894578529F97Bb366AF5);
    }
    
    // Incase of a new version of DEX, update
    function updateRouter(address _router) external onlyOwner {
        router = IRouter02(_router);
    }
    
    // New version of enhance, update
    function updateToken(address _token) external onlyOwner {
        ENHANCE = _token;
    }
    
    // Get mistakenly sent token out
    function withdrawForeignFunds(address token) external onlyOwner{
        uint256 bal = IERC20(token).balanceOf(address(this));
        require(bal > 0, 'empty');
        IERC20(token).transfer(owner(), bal);
    }
    
    // Swap For Enhance
    receive() external payable {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = ENHANCE;
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            msg.sender,
            block.timestamp + 30
        );
    }
    
}