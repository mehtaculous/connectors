// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

import "src/Connectors.sol";
import "src/Metadata.sol";
import "src/interfaces/IConnectors.sol";
import "src/interfaces/IMetadata.sol";

contract DeployScript is Script {
    Connectors connectors;
    address metadata;

    function run() public {
        vm.startBroadcast();
        connectors = new Connectors();
        metadata = connectors.metadata();
        vm.stopBroadcast();
    }
}
