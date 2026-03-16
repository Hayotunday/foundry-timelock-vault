// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {TimeVault} from "src/TimeVault.sol";
import {DeployTimeVault} from "script/DeployTimeVault.s.sol";

contract TimeVaultTest is Test {
  TimeVault public timeVault;
  address public immutable IUSER1 = makeAddr("user1");
  address public immutable IUSER2 = makeAddr("user2");

  function setUp() public {
    DeployTimeVault deployer = new DeployTimeVault();
    timeVault = deployer.run();
    vm.deal(IUSER1, 10 ether);
    vm.deal(IUSER2, 10 ether);
  }

  function testDeposit() public {
    vm.startPrank(IUSER1);
    uint256 lockDuration = 1 days;
    timeVault.deposit{value: 1 ether}(lockDuration);
    (uint256 amount, uint256 unlockTime) = timeVault.vaults(IUSER1);
    assertEq(amount, 1 ether);
    assertEq(unlockTime, block.timestamp + lockDuration);
    vm.stopPrank();
  }

  function testWithdraw() public {
    vm.startPrank(IUSER1);
    uint256 lockDuration = 1 days;
    timeVault.deposit{value: 1 ether}(lockDuration);
    (uint256 amount, uint256 unlockTime) = timeVault.vaults(IUSER1);
    vm.warp(unlockTime + 1);
    timeVault.withdraw();
    (amount, unlockTime) = timeVault.vaults(IUSER1);
    assertEq(amount, 0);
    assertEq(unlockTime, 0);
    vm.stopPrank();
  }

  function testCannotWithdrawBeforeUnlock() public {
    vm.startPrank(IUSER1);
    uint256 lockDuration = 1 days;
    timeVault.deposit{value: 1 ether}(lockDuration);
    (, uint256 unlockTime) = timeVault.vaults(IUSER1);
    vm.expectRevert(abi.encodeWithSelector(TimeVault.TimeVault__DepositNotMatured.selector, unlockTime));
    timeVault.withdraw();
    vm.stopPrank();
  }

  function testCannotWithdrawWithoutActiveDeposit() public {
    vm.startPrank(IUSER2);
    vm.expectRevert(TimeVault.TimeVault__NoActiveDeposit.selector);
    timeVault.withdraw();
    vm.stopPrank();
  }

  function testCannotDepositWithActiveDeposit() public {
    vm.startPrank(IUSER1);
    uint256 lockDuration = 1 days;
    timeVault.deposit{value: 1 ether}(lockDuration);
    vm.expectRevert(TimeVault.TimeVault__AddressHasActiveDeposit.selector);
    timeVault.deposit{value: 1 ether}(lockDuration);
    vm.stopPrank();
  }

  function testCannotDepositWithZeroAmount() public {
    vm.startPrank(IUSER1);
    uint256 lockDuration = 1 days;
    vm.expectRevert(TimeVault.TimeVault__DepositAmountMustBeGreaterThanZero.selector);
    timeVault.deposit{value: 0}(lockDuration);
    vm.stopPrank();
  }

  function testCannotDepositWithZeroLockDuration() public {
    vm.startPrank(IUSER1);
    uint256 lockDuration = 0;
    vm.expectRevert(TimeVault.TimeVault__LockDurationMustBeGreaterThanZero.selector);
    timeVault.deposit{value: 1 ether}(lockDuration);
    vm.stopPrank();
  }

  function testCannotWithdrawWithBurnAddress() public {
    vm.startPrank(IUSER1);
    uint256 lockDuration = 1 days;
    timeVault.deposit{value: 1 ether}(lockDuration);
    vm.stopPrank();
    vm.warp(lockDuration + 1);
    vm.startPrank(address(0));
    vm.expectRevert(TimeVault.TimeVault__WithdrawalAddressNotAllowed.selector);
    timeVault.withdraw();
    vm.stopPrank();
  }
}
