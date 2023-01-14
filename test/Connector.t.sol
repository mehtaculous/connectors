// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "src/Connector.sol";
import "src/Render.sol";
import "src/interfaces/IConnector.sol";
import "src/interfaces/IRender.sol";

contract ConnectorTest is Test {
    using Strings for uint160;
    using Strings for uint256;

    Connector connector;

    address alice;
    address bob;
    address render;
    uint256 gameId;

    function setUp() public {
        connector = new Connector();
        render = connector.render();
    }

    function testChallengeSuccess() public {}

    function testChallengeRevertInvalidPayment() public {}

    function testChallengeRevertInvalidMatchup() public {}

    function testBeginSuccess() public {}

    function testBeginRevertInvalidPayment() public {}

    function testBeginRevertInvalidState() public {}

    function testBeginRevertNotAuthorized() public {}

    function testMoveSuccess() public {}

    function testMoveRevertInvalidGame() public {}

    function testMoveRevertInvalidState() public {}

    function testMoveRevertInvalidTurn() public {}

    function testMoveRevertInvalidMove() public {}

    function testMoveRevertInvalidPlacement() public {}

    function testSetFeeSuccess() public {}

    function testSetFeeRevertUnauthorized() public {}

    function testWithdraw() public {}

    function testTokenURI() public {}
}
