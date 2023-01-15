// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

import "src/Connectors.sol";
import "src/Metadata.sol";
import "src/interfaces/IConnectors.sol";
import "src/interfaces/IMetadata.sol";

contract DeployScript is Script {
    // Contracts
    Connectors connectors;

    // State
    address metadata;
    uint256 gameId;
    uint256 col;
    uint256 row;

    // Constants
    address constant OPPONENT = 0x16107A92e44E105b135d5F84D5730E9EAaa167B7;

    function run() public {
        vm.startBroadcast();
        deploy();
        challenge();
        vm.stopBroadcast();
    }

    function deploy() public {
        connectors = new Connectors();
        metadata = connectors.metadata();
    }

    function challenge() public {
        connectors.challenge(OPPONENT);
        gameId = connectors.currentId();
    }
}
