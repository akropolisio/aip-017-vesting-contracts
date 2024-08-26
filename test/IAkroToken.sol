// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAkroToken {
    function mint(address _to, uint256 _amount) external;

    function transferOwnership(address _newOwner) external;
    function claimOwnership() external;
}
