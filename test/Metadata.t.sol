// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Connectors.sol";
import "src/interfaces/IMetadata.sol";

contract MetadataTest is Test {
    // Contracts
    Connectors connectors;

    // Users
    address bob = address(111);
    address eve = address(222);

    // Renders
    string base;
    string player1;
    string player2;

    // State
    address metadata;
    string blue;
    string red;
    string yellow;
    uint256 gameId;

    // Errors
    bytes NOT_OWNER_ERROR = bytes("Ownable: caller is not the owner");

    /// =====================
    /// ===== MODIFIERS =====
    /// =====================
    modifier prank(address _sender) {
        vm.startPrank(_sender);
        _;
        vm.stopPrank();
    }

    /// =================
    /// ===== SETUP =====
    /// =================
    function setUp() public {
        connectors = new Connectors();
        metadata = connectors.metadata();
        initializePalette();

        vm.label(address(connectors), "Connectors");
        vm.label(metadata, "Metadata");
        vm.label(address(this), "MetadataTest");
        vm.label(bob, "Bob");
        vm.label(eve, "Eve");
    }

    /// ====================
    /// ===== REGISTER =====
    /// ====================
    function testRegisterSuccess() public {
        // setup
        gameId = 1;
        // execute
        _register(address(connectors), gameId);
        // assert
        assertEq(base, yellow);
        assertEq(player1, blue);
        assertEq(player2, red);

        // setup
        gameId = 2;
        // execute
        _register(address(connectors), gameId);
        // assert
        assertEq(base, blue);
        assertEq(player1, red);
        assertEq(player2, yellow);

        // setup
        gameId = 3;
        // execute
        _register(address(connectors), gameId);
        // assert
        assertEq(base, red);
        assertEq(player1, yellow);
        assertEq(player2, blue);
    }

    function testRegisterRevertNotOwner() public {
        // setup
        gameId = 1;
        // revert
        vm.expectRevert(NOT_OWNER_ERROR);
        // execute
        _register(address(this), gameId);
    }

    /// ===================
    /// ===== HELPERS =====
    /// ===================

    function initializePalette() public {
        blue = IMetadata(metadata).BLUE();
        red = IMetadata(metadata).RED();
        yellow = IMetadata(metadata).YELLOW();
    }

    function _challenge(address _sender, address _opponent) internal prank(_sender) {
        connectors.challenge(_opponent);
        gameId = connectors.totalSupply();
    }

    function _register(address _sender, uint256 _gameId) internal prank(_sender) {
        IMetadata(metadata).register(_gameId);
        (base, player1, player2) = IMetadata(metadata).renders(_gameId);
    }
}
