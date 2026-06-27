// SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

/**
 * @title SecureVault
 * @notice Secure custody / safekeeping contract (ethical asset deposit)
 * @dev Modular building block for trusted asset holding without interest
 */
contract SecureVault {
    uint256 public totalDeposit;
    address public owner;
    address public custodian; // the guards

    event DepositReceived(address from, uint256 amount);
    event WithdrawalMade(address to, uint256 amount);

    constructor(uint256 _initialDeposit) {
        require(_initialDeposit > 0, "Initial deposit must be greater than zero");

        totalDeposit = _initialDeposit;
        owner = msg.sender;
        custodian = msg.sender; // can change later
    }

    /**
     * @notice Deposit additional funds
     */
    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        totalDeposit += msg.value;
        emit DepositReceived(msg.sender, msg.value);
    }

    /**
     * @notice Withdraw funds (only owner atau custodian)
     */
    function withdraw(uint256 _amount) external {
        require(msg.sender == owner || msg.sender == custodian, "Not authorized");
        require(_amount <= totalDeposit, "Insufficient balance");

        totalDeposit -= _amount;
        (bool success,) = msg.sender.call{value: _amount}("");
        require(success, "Withdrawal failed");

        emit WithdrawalMade(msg.sender, _amount);
    }

    /**
     * @notice View current total deposit
     */
    function getTotalDeposit() external view returns (uint256) {
        return totalDeposit;
    }
}
