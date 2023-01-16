// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "src/Connectoooors.sol";

contract DeployScript is Script {
    Connectoooors connectors;
    address metadata;
    address constant OPPONENT = 0x16107A92e44E105b135d5F84D5730E9EAaa167B7;

    function run() public {
        vm.startBroadcast();
        deploy();
        vm.stopBroadcast();
    }

    function deploy() public {
        connectors = new Connectoooors();
        metadata = connectors.metadata();
    }

    function challenge() public {
        connectors.challenge(OPPONENT);
    }
}
