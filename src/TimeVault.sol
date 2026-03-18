// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// @title A simple time-locked vault for ETH.
/// @notice Users can deposit ETH and can only withdraw it after a specified lock duration.
contract TimeVault {
  /// @notice
  error TimeVault__NoActiveDeposit();
  error TimeVault__AddressHasActiveDeposit();
  error TimeVault__DepositNotMatured(uint256 unlockTime);
  error TimeVault__DepositAmountMustBeGreaterThanZero();
  error TimeVault__LockDurationMustBeGreaterThanZero();
  error TimeVault__WithdrawalAddressNotAllowed();
  error TimeVault__WithdrawalFailed();

  /// @notice A struct to hold the details of a user's deposit.
  struct Vault {
    uint256 amount;
    uint256 unlockTime;
  }

  /// @notice Maps a user's address to their vault details.
  mapping(address => Vault) public vaults;

  /// @notice Emitted when a user successfully deposits ETH.
  event EthDeposited(address indexed user, uint256 amount, uint256 unlockTime);
  event EthWithdrawn(address indexed user, uint256 amount);

  /// @notice Deposits ETH into a time-locked vault for the caller.
  /// @param _lockDurationInSeconds The duration in seconds for which the funds will be locked.
  function deposit(uint256 _lockDurationInSeconds) external payable {
    if (msg.value == 0) {
      revert TimeVault__DepositAmountMustBeGreaterThanZero();
    }
    if (vaults[msg.sender].amount > 0) {
      revert TimeVault__AddressHasActiveDeposit();
    }
    if (_lockDurationInSeconds == 0) {
      revert TimeVault__LockDurationMustBeGreaterThanZero();
    }
    uint256 unlockTime = block.timestamp + _lockDurationInSeconds;
    vaults[msg.sender] = Vault(msg.value, unlockTime);

    emit EthDeposited(msg.sender, msg.value, unlockTime);
  }

  function withdraw() external {
    if (msg.sender == address(0)) {
      revert TimeVault__WithdrawalAddressNotAllowed();
    }
    Vault memory userVault = vaults[msg.sender];
    if (userVault.amount == 0) {
      revert TimeVault__NoActiveDeposit();
    }
    if (block.timestamp < userVault.unlockTime) {
      revert TimeVault__DepositNotMatured(userVault.unlockTime);
    }
    delete vaults[msg.sender];
    (bool success,) = (msg.sender).call{value: userVault.amount}("");
    if (!success) {
      revert TimeVault__WithdrawalFailed();
    }

    emit EthWithdrawn(msg.sender, userVault.amount);
  }
}
