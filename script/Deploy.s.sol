// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "src/Connectors.sol";

contract DeployScript is Script {
    Connectors connectors;
    address metadata;

    function run() public {
        vm.startBroadcast();
        deploy();
        vm.stopBroadcast();
    }

    function deploy() public {
        connectors = new Connectors();
        metadata = connectors.metadata();
    }
}
