// SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

import {notOwner, insufficientFunds, withdrawalFailed} from "../Errors.sol";

contract GoldVault {
    address public owner;
    uint256 public balance;

    event Deposit(address indexed sender, uint256 amount);
    event Withdrawal(address indexed recipient, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    function _onlyOwner() internal view {
        if (msg.sender != owner) revert notOwner();
    }

    function deposit() external payable {
        if (msg.value == 0) revert insufficientFunds();
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external onlyOwner {
        if (amount > address(this).balance) revert insufficientFunds();

        (bool success,) = payable(owner).call{value: amount}("");
        if (!success) revert withdrawalFailed();

        emit Withdrawal(owner, amount);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
