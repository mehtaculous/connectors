// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "src/Connectors.sol";

contract DeployScript is Script {
    Connectors connectors;
    address generator;

    function run() public {
        vm.startBroadcast();
        deploy();
        vm.stopBroadcast();
    }

    function deploy() public {
        connectors = new Connectors();
        generator = connectors.generator();
    }

    function challenge(address _opponent) public {
        connectors.challenge(_opponent);
    }
}
