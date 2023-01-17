// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "src/Connectors.sol";

contract DeployScript is Script {
    Connectors connectors;
    address metadata;

    uint64 constant FEE = 0.0420 ether;
    address constant ARCH = 0x0aa0Bc25769C52e623D09A9764e079A221BeA2a1;
    address constant WILL = 0x69EC014c15baF1C96620B6BA02A391aBaBB9C96b;
    address constant STEVEN = 0xBa9B51b8d0ade90296203625d653332367a08087;

    function run() public {
        vm.startBroadcast();
        deploy();
        connectors.setFee(0);
        challenge(ARCH);
        challenge(WILL);
        challenge(STEVEN);
        connectors.setFee(FEE);
        vm.stopBroadcast();
    }

    function deploy() public {
        connectors = new Connectors();
        metadata = connectors.metadata();
    }

    function challenge(address _opponent) public {
        connectors.challenge(_opponent);
    }
}
