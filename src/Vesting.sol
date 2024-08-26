// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {VestingWallet} from "@openzeppelin/contracts/finance/VestingWallet.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

contract Vesting is VestingWallet {
    error InsufficientFunds();

    uint256 private _released;
    mapping(address token => uint256) private _erc20Released;

    string public tag;

    constructor(
        string memory _tag,
        address beneficiary,
        uint64 startTimestamp,
        uint64 durationSeconds
    ) VestingWallet(beneficiary, startTimestamp, durationSeconds) {
        tag = _tag;
    }

    function release() public override onlyOwner {
        super.release();
    }

    function release(address token) public override onlyOwner {
        super.release(token);
    }

    function release(uint256 amount) public onlyOwner {
        uint256 releasableAmount = releasable();

        if (amount > releasableAmount) {
            revert InsufficientFunds();
        }

        _released += amount;
        emit EtherReleased(amount);
        Address.sendValue(payable(owner()), amount);
    }

    function release(address token, uint256 amount) public onlyOwner {
        uint256 releasableAmount = releasable(token);

        if (amount > releasableAmount) {
            revert InsufficientFunds();
        }

        _erc20Released[token] += amount;
        emit ERC20Released(token, amount);
        SafeERC20.safeTransfer(IERC20(token), owner(), amount);
    }

    /**
     * @dev Amount of eth already released
     */
    function released() public view override returns (uint256) {
        return _released + super.released();
    }

    /**
     * @dev Amount of token already released
     */
    function released(address token) public view override returns (uint256) {
        return _erc20Released[token] + super.released(token);
    }
}
