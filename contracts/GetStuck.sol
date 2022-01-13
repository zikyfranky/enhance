// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IRouter.sol";
import "./DividendTracker.sol";

contract GetStuck is Ownable {
    function getStuckTokens() public payable {
        revert();
    }
}