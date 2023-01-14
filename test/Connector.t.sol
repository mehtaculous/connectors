// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "src/Connector.sol";
import "src/Metadata.sol";
import "src/interfaces/IConnector.sol";
import "src/interfaces/IMetadata.sol";

contract ConnectorTest is Test {
    using Strings for uint160;
    using Strings for uint256;

    // Contracts
    Connector connector;

    // Users
    address alice = address(111);
    address bob = address(222);

    // Game
    Game game;
    State state;
    Strat strat;
    address player1;
    address player2;
    address turn;
    uint256 moves;
    address[COL][ROW] board;

    // State
    address metadata;
    uint256 col;
    uint256 fee;
    uint256 gameId;
    uint256 row;
    uint256 totalSupply;

    // Constants
    uint256 constant ETH_BALANCE = 100 ether;

    // Errors
    bytes INDEX_OUT_OF_BOUNDS_ERROR = bytes("Index out of bounds");
    bytes4 INVALID_GAME_ERROR = IConnector.InvalidGame.selector;
    bytes4 INVALID_MATCHUP_ERROR = IConnector.InvalidMatchup.selector;
    bytes4 INVALID_MOVE_ERROR = IConnector.InvalidMove.selector;
    bytes4 INVALID_PAYMENT_ERROR = IConnector.InvalidPayment.selector;
    bytes4 INVALID_STATE_ERROR = IConnector.InvalidState.selector;
    bytes4 INVALID_TURN_ERROR = IConnector.InvalidTurn.selector;
    bytes4 NOT_AUTHORIZED_ERROR = IConnector.NotAuthorized.selector;

    modifier prank(address _sender) {
        vm.startPrank(_sender);
        _;
        vm.stopPrank();
    }

    receive() external payable {}

    function setUp() public {
        connector = new Connector();
        metadata = connector.metadata();

        vm.deal(alice, ETH_BALANCE);
        vm.deal(bob, ETH_BALANCE);
        vm.deal(address(this), ETH_BALANCE);

        vm.label(alice, "Alice");
        vm.label(bob, "Bob");
        vm.label(address(connector), "Connector");
        vm.label(metadata, "Metadata");
        vm.label(address(this), "ConnectorTest");
    }

    function testChallengeSuccess() public {
        _challenge(alice, bob, fee);
    }

    function testChallengeRevertInvalidPayment() public {
        vm.expectRevert(INVALID_PAYMENT_ERROR);
        _challenge(alice, bob, 1 wei);
    }

    function testChallengeRevertInvalidMatchup() public {
        vm.expectRevert(INVALID_MATCHUP_ERROR);
        _challenge(alice, alice, fee);
    }

    function testBeginSuccess(uint256 _col) public {
        testChallengeSuccess();
        _col = _boundColumn(_col, 0, COL);

        _begin(bob, gameId, row, _col, fee);
    }

    function testBeginRevertInvalidGame(uint256 _col) public {
        testChallengeSuccess();
        _col = _boundColumn(_col, 0, COL);

        vm.expectRevert(INVALID_GAME_ERROR);
        _begin(bob, ++gameId, row, _col, fee);
    }

    function testBeginRevertInvalidPayment(uint256 _col) public {
        testChallengeSuccess();
        _col = _boundColumn(_col, 0, COL);

        vm.expectRevert(INVALID_PAYMENT_ERROR);
        _begin(bob, gameId, row, _col, 1 wei);
    }

    function testBeginRevertInvalidState(uint256 _col) public {
        testBeginSuccess(_col);
        _col = _boundColumn(_col, 0, COL);

        vm.expectRevert(INVALID_STATE_ERROR);
        _begin(alice, gameId, row, _col, fee);
    }

    function testBeginRevertNotAuthorized(uint256 _col) public {
        testChallengeSuccess();
        _col = _boundColumn(_col, 0, COL);

        vm.expectRevert(NOT_AUTHORIZED_ERROR);
        _begin(alice, gameId, row, _col, fee);
    }

    function testMoveSuccess() public {
        _challenge(alice, bob, fee);
        _begin(bob, gameId, row, col, fee);

        _move(alice, gameId, row, col + 1);
    }

    function testMoveRevertInvalidGame(uint256 _col) public {
        testBeginSuccess(_col);
        _col = _boundColumn(_col, 0, COL);

        vm.expectRevert(INVALID_GAME_ERROR);
        _move(alice, ++gameId, row, _col);
    }

    function testMoveRevertInvalidState(uint256 _col) public {
        testChallengeSuccess();
        _col = _boundColumn(_col, 0, COL);

        vm.expectRevert(INVALID_STATE_ERROR);
        _move(bob, gameId, row, _col);
    }

    function testMoveRevertInvalidTurn(uint256 _col) public {
        testBeginSuccess(_col);
        _col = _boundColumn(_col, 0, COL);

        vm.expectRevert(INVALID_TURN_ERROR);
        _move(bob, gameId, row, _col);
    }

    function testMoveRevertRowOutOfBounds(uint256 _col) public {
        testBeginSuccess(_col);

        vm.expectRevert();
        _move(alice, gameId, ROW, col);
    }

    function testMoveRevertColOutOfBounds(uint256 _col) public {
        testBeginSuccess(_col);

        vm.expectRevert();
        _move(alice, gameId, row, COL);
    }

    function testMoveRevertInvalidMove(uint256 _col) public {
        testBeginSuccess(_col);

        vm.expectRevert(INVALID_MOVE_ERROR);
        _move(alice, gameId, row, col);
    }

    function testSetFeeSuccess(uint256 _fee) public {
        _setFee(address(this), _fee);
    }

    function testSetFeeRevertNotOwner(uint256 _fee) public {
        vm.expectRevert();
        _setFee(alice, _fee);
    }

    function testWithdraw() public {
        _withdraw(address(this), payable(address(this)));
    }

    function xtestTokenURI() public view {
        connector.tokenURI(gameId);
    }

    /// ===================
    /// ===== HELPERS =====
    /// ===================

    function _challenge(address _sender, address _opponent, uint256 _fee) internal prank(_sender) {
        connector.challenge{value: _fee}(_opponent);
        gameId = connector.currentId();
    }

    function _begin(
        address _sender,
        uint256 _gameId,
        uint256 _row,
        uint256 _col,
        uint256 _fee
    ) internal prank(_sender) {
        connector.begin{value: _fee}(_gameId, _row, _col);
        row = _row;
        col = _col;
    }

    function _move(
        address _sender,
        uint256 _gameId,
        uint256 _row,
        uint256 _col
    ) internal prank(_sender) {
        connector.move(_gameId, _row, _col);
        row = _row;
        col = _col;
    }

    function _setFee(address _sender, uint256 _fee) internal prank(_sender) {
        connector.setFee(_fee);
        fee = _fee;
    }

    function _withdraw(address _sender, address payable _to) internal prank(_sender) {
        connector.withdraw(_to);
    }

    function _boundColumn(
        uint256 _col,
        uint256 _min,
        uint256 _max
    ) internal view returns (uint256 column) {
        column = bound(_col, _min, _max);
        vm.assume(column >= _min && column < _max);
    }
}
