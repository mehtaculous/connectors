// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

import "src/Connector.sol";
import "src/Metadata.sol";
import "src/interfaces/IConnector.sol";
import "src/interfaces/IMetadata.sol";

contract DeployScript is Script {
    Connector connector;
    address metadata;
    uint256 gameId;

    function setUp() public {
        vm.startBroadcast();
        run();
        vm.stopBroadcast();
    }

    function run() public {
        connector = new Connector();
        metadata = connector.metadata();
    }
}
