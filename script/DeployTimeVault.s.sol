// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";
import {TimeVault} from "src/TimeVault.sol";

contract DeployTimeVault is Script {
  TimeVault public timeVault;

  function run() external returns (TimeVault) {
    vm.startBroadcast();
    timeVault = new TimeVault();
    vm.stopBroadcast();
    return timeVault;
  }
}
