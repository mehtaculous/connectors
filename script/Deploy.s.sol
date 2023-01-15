// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "src/Connectoooors.sol";

contract DeployScript is Script {
    Connectoooors connectors;
    address metadata;

    function run() public {
        vm.startBroadcast();
        deploy();
        vm.stopBroadcast();
    }

    function deploy() public {
        connectors = new Connectoooors();
        metadata = connectors.metadata();
    }
}
