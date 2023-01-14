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
    address[COL] column;

    // Constants
    uint256 constant ETH_BALANCE = 100 ether;

    // Errors
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
        // execute
        _challenge(alice, bob, fee);
        // assert
        assertEq(gameId, 1);
        assertEq(player1, alice);
        assertEq(player2, bob);
        assertEq(turn, bob);
        assertEq(uint256(state), uint256(State.INACTIVE));
        assertEq(connector.ownerOf(gameId), address(connector));
    }

    function testChallengeRevertInvalidPayment() public {
        // setup
        _setFee(address(this), 1 ether);
        vm.expectRevert(INVALID_PAYMENT_ERROR);
        // execute
        _challenge(alice, bob, fee - 1);
    }

    function testChallengeRevertInvalidMatchup() public {
        // revert
        vm.expectRevert(INVALID_MATCHUP_ERROR);
        // execute
        _challenge(alice, alice, fee);
    }

    function testBeginSuccess(uint256 _col) public {
        // setup
        testChallengeSuccess();
        _col = _boundCol(_col, 0, COL);
        // execute
        _begin(bob, gameId, row, _col, fee);
        // assert
        assertEq(board[row][col], bob);
        assertEq(moves, 1);
        assertEq(turn, alice);
        assertEq(uint256(state), uint256(State.ACTIVE));
    }

    function testBeginRevertInvalidGame(uint256 _col) public {
        // setup
        testChallengeSuccess();
        _col = _boundCol(_col, 0, COL);
        // revert
        vm.expectRevert(INVALID_GAME_ERROR);
        // execute
        _begin(bob, ++gameId, row, _col, fee);
    }

    function testBeginRevertInvalidPayment(uint256 _col) public {
        // setup
        testChallengeSuccess();
        _setFee(address(this), 1 ether);
        _col = _boundCol(_col, 0, COL);
        // revert
        vm.expectRevert(INVALID_PAYMENT_ERROR);
        // execute
        _begin(bob, gameId, row, _col, fee - 1);
    }

    function testBeginRevertInvalidState(uint256 _col) public {
        // setup
        testBeginSuccess(_col);
        _col = _boundCol(_col, 0, COL);
        // revert
        vm.expectRevert(INVALID_STATE_ERROR);
        // execute
        _begin(alice, gameId, row, _col, fee);
    }

    function testBeginRevertNotAuthorized(uint256 _col) public {
        // setup
        testChallengeSuccess();
        _col = _boundCol(_col, 0, COL);
        // revert
        vm.expectRevert(NOT_AUTHORIZED_ERROR);
        // execute
        _begin(alice, gameId, row, _col, fee);
    }

    function testMoveSuccess() public {
        // setup
        _challenge(alice, bob, fee);
        _begin(bob, gameId, row, col, fee);
        // execute
        _move(alice, gameId, row, col + 1);
        // assert
        assertEq(board[row][col], alice);
        assertEq(moves, 2);
        assertEq(turn, bob);
    }

    function testMoveRevertInvalidGame(uint256 _col) public {
        // setup
        testBeginSuccess(_col);
        _col = _boundCol(_col, 0, COL);
        // revert
        vm.expectRevert(INVALID_GAME_ERROR);
        // execute
        _move(alice, ++gameId, row, _col);
    }

    function testMoveRevertInvalidState(uint256 _col) public {
        // setup
        testChallengeSuccess();
        _col = _boundCol(_col, 0, COL);
        // revert
        vm.expectRevert(INVALID_STATE_ERROR);
        // execute
        _move(bob, gameId, row, _col);
    }

    function testMoveRevertInvalidTurn(uint256 _col) public {
        // setup
        testBeginSuccess(_col);
        _col = _boundCol(_col, 0, COL);
        // revert
        vm.expectRevert(INVALID_TURN_ERROR);
        // execute
        _move(bob, gameId, row, _col);
    }

    function testMoveRevertRowOutOfBounds(uint256 _col) public {
        // setup
        testBeginSuccess(_col);
        // revert
        vm.expectRevert();
        // execute
        _move(alice, gameId, ROW, col);
    }

    function testMoveRevertColOutOfBounds(uint256 _col) public {
        // setup
        testBeginSuccess(_col);
        // revert
        vm.expectRevert();
        // execute
        _move(alice, gameId, row, COL);
    }

    function testMoveRevertInvalidMove(uint256 _col) public {
        // setup
        testBeginSuccess(_col);
        // revert
        vm.expectRevert(INVALID_MOVE_ERROR);
        // execute
        _move(alice, gameId, row, col);
    }

    function testSetFeeSuccess(uint256 _fee) public {
        // execute
        _setFee(address(this), _fee);
        // assert
        assertEq(fee, connector.fee());
    }

    function testSetFeeRevertNotOwner(uint256 _fee) public {
        // revert
        vm.expectRevert();
        // execute
        _setFee(alice, _fee);
    }

    function testWithdraw(uint256 _col) public {
        // setup
        _setFee(address(this), 1 ether);
        testBeginSuccess(_col);
        // execute
        _withdraw(address(this), payable(address(this)));
        // assert
        assertEq(address(this).balance, ETH_BALANCE + (fee * 2));
    }

    function testTokenURI() public {
        // setup
        testMoveSuccess();
        // execute
        connector.tokenURI(gameId);
    }

    /// ===================
    /// ===== HELPERS =====
    /// ===================

    function _challenge(address _sender, address _opponent, uint256 _fee) internal prank(_sender) {
        connector.challenge{value: _fee}(_opponent);
        _setGame();
        _setState(gameId, row, col);
    }

    function _begin(
        address _sender,
        uint256 _gameId,
        uint256 _row,
        uint256 _col,
        uint256 _fee
    ) internal prank(_sender) {
        connector.begin{value: _fee}(_gameId, _row, _col);
        _setState(gameId, _row, _col);
        if (_row < ROW) _setBoard(gameId, _row);
    }

    function _move(
        address _sender,
        uint256 _gameId,
        uint256 _row,
        uint256 _col
    ) internal prank(_sender) {
        connector.move(_gameId, _row, _col);
        _setState(gameId, _row, _col);
        if (_row < ROW) _setBoard(gameId, _row);
    }

    function _setFee(address _sender, uint256 _fee) internal prank(_sender) {
        connector.setFee(_fee);
        fee = _fee;
    }

    function _withdraw(address _sender, address payable _to) internal prank(_sender) {
        connector.withdraw(_to);
    }

    function _setGame() internal {
        gameId = connector.currentId();
    }

    function _setState(uint256 _gameId, uint256 _row, uint256 _col) internal {
        (state, strat, player1, player2, turn, moves) = connector.games(_gameId);
        row = _row;
        col = _col;
    }

    function _setBoard(uint256 _gameId, uint256 _row) internal {
        column = connector.getRow(_gameId, _row);
        board[_row] = column;
    }

    function _boundCol(
        uint256 _col,
        uint256 _min,
        uint256 _max
    ) internal view returns (uint256 value) {
        value = bound(_col, _min, _max);
        vm.assume(value >= _min && value < _max);
    }
}
