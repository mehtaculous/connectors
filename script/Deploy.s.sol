// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

import "src/Connector.sol";
import "src/Render.sol";
import "src/interfaces/IConnector.sol";
import "src/interfaces/IRender.sol";

contract DeployScript is Script {
    Connector connector;

    address render;
    uint256 gameId;

    function setUp() public {
        vm.startBroadcast();
        run();
        vm.stopBroadcast();
    }

    function run() public {
        connector = new Connector();
        render = connector.render();
    }
}
