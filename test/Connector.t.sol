// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "src/Connector.sol";
import "src/Metadata.sol";
import "src/interfaces/IConnector.sol";
import "src/interfaces/IMetadata.sol";

contract ConnectorTest is Test {
    // Contracts
    Connector connector;

    // Users
    address bob = address(222);
    address eve = address(333);

    // Game
    State state;
    Strat strat;
    address player1;
    address player2;
    address turn;
    uint256 moves;
    address[COL][ROW] board;

    // State
    address metadata;
    uint256 row;
    uint256 col;
    uint256 fee;
    uint256 gameId;

    // Constants
    uint256 constant ETH_BALANCE = 100 ether;

    // Errors
    bytes4 INVALID_GAME_ERROR = IConnector.InvalidGame.selector;
    bytes4 INVALID_MATCHUP_ERROR = IConnector.InvalidMatchup.selector;
    bytes4 INVALID_MOVE_ERROR = IConnector.InvalidMove.selector;
    bytes4 INVALID_PAYMENT_ERROR = IConnector.InvalidPayment.selector;
    bytes4 INVALID_STATE_ERROR = IConnector.InvalidState.selector;
    bytes4 NOT_AUTHORIZED_ERROR = IConnector.NotAuthorized.selector;

    modifier prank(address _sender) {
        vm.startPrank(_sender);
        _;
        vm.stopPrank();
    }

    receive() external payable {}

    /// =================
    /// ===== SETUP =====
    /// =================
    function setUp() public {
        connector = new Connector();
        metadata = connector.metadata();

        vm.deal(bob, ETH_BALANCE);
        vm.deal(eve, ETH_BALANCE);
        vm.deal(address(this), ETH_BALANCE);

        vm.label(bob, "Bob");
        vm.label(eve, "Eve");
        vm.label(metadata, "Metadata");
        vm.label(address(connector), "Connector");
        vm.label(address(this), "ConnectorTest");
    }

    /// =====================
    /// ===== CHALLENGE =====
    /// =====================
    function testChallengeSuccess() public {
        // execute
        _challenge(bob, eve, fee);
        // assert
        assertEq(gameId, 1);
        assertEq(player1, bob);
        assertEq(player2, eve);
        assertEq(turn, eve);
        assertEq(uint256(state), uint256(State.INACTIVE));
        assertEq(connector.ownerOf(gameId), address(connector));
    }

    function testChallengeRevertInvalidPayment() public {
        // setup
        _setFee(address(this), 1 ether);
        // revert
        vm.expectRevert(INVALID_PAYMENT_ERROR);
        // execute
        _challenge(bob, eve, fee - 1);
    }

    function testChallengeRevertInvalidMatchup() public {
        // revert
        vm.expectRevert(INVALID_MATCHUP_ERROR);
        // execute
        _challenge(bob, bob, fee);
    }

    /// =================
    /// ===== BEGIN =====
    /// =================
    function testBeginSuccess(uint256 _col) public {
        // setup
        testChallengeSuccess();
        _col = _boundCol(_col, 0, COL);
        // execute
        _begin(eve, gameId, row, _col, fee);
        // assert
        assertEq(board[row][col], eve);
        assertEq(moves, 1);
        assertEq(turn, bob);
        assertEq(uint256(state), uint256(State.ACTIVE));
    }

    function testBeginRevertInvalidGame(uint256 _col) public {
        // setup
        testChallengeSuccess();
        _col = _boundCol(_col, 0, COL);
        // revert
        vm.expectRevert(INVALID_GAME_ERROR);
        // execute
        _begin(eve, ++gameId, row, _col, fee);
    }

    function testBeginRevertInvalidPayment(uint256 _col) public {
        // setup
        testChallengeSuccess();
        _setFee(address(this), 1 ether);
        _col = _boundCol(_col, 0, COL);
        // revert
        vm.expectRevert(INVALID_PAYMENT_ERROR);
        // execute
        _begin(eve, gameId, row, _col, fee - 1);
    }

    function testBeginRevertInvalidState(uint256 _col) public {
        // setup
        testBeginSuccess(_col);
        _col = _boundCol(_col, 0, COL);
        // revert
        vm.expectRevert(INVALID_STATE_ERROR);
        // execute
        _begin(eve, gameId, row, _col, fee);
    }

    function testBeginRevertNotAuthorized(uint256 _col) public {
        // setup
        testChallengeSuccess();
        _col = _boundCol(_col, 0, COL);
        // revert
        vm.expectRevert(NOT_AUTHORIZED_ERROR);
        // execute
        _begin(bob, gameId, row, _col, fee);
    }

    /// ================
    /// ===== MOVE =====
    /// ================
    function testMoveSuccess() public {
        // setup
        _challenge(bob, eve, fee);
        _begin(eve, gameId, row, col, fee);
        // execute
        _move(bob, gameId, row, col + 1);
        // assert
        assertEq(board[row][col], bob);
        assertEq(moves, 2);
        assertEq(turn, eve);
    }

    function testMoveRevertInvalidGame(uint256 _col) public {
        // setup
        testBeginSuccess(_col);
        _col = _boundCol(_col, 0, COL);
        // revert
        vm.expectRevert(INVALID_GAME_ERROR);
        // execute
        _move(bob, ++gameId, row, _col);
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

    function testMoveRevertNotAuthorized(uint256 _col) public {
        // setup
        testBeginSuccess(_col);
        _col = _boundCol(_col, 0, COL);
        // revert
        vm.expectRevert(NOT_AUTHORIZED_ERROR);
        // execute
        _move(eve, gameId, row, _col);
    }

    function testMoveRevertRowOutOfBounds(uint256 _col) public {
        // setup
        testBeginSuccess(_col);
        // revert
        vm.expectRevert();
        // execute
        _move(bob, gameId, ROW, col);
    }

    function testMoveRevertColOutOfBounds(uint256 _col) public {
        // setup
        testBeginSuccess(_col);
        // revert
        vm.expectRevert();
        // execute
        _move(bob, gameId, row, COL);
    }

    function testMoveRevertInvalidMove(uint256 _col) public {
        // setup
        testBeginSuccess(_col);
        // revert
        vm.expectRevert(INVALID_MOVE_ERROR);
        // execute
        _move(bob, gameId, row, col);
    }

    /// ===================
    /// ===== SET FEE =====
    /// ===================
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
        _setFee(bob, _fee);
    }

    /// ====================
    /// ===== WITHDRAW =====
    /// ====================
    function testWithdraw(uint256 _col) public {
        // setup
        _setFee(address(this), 1 ether);
        testBeginSuccess(_col);
        // execute
        _withdraw(address(this), payable(address(this)));
        // assert
        assertEq(address(this).balance, ETH_BALANCE + (fee * 2));
    }

    /// =====================
    /// ===== TOKEN URI =====
    /// =====================
    function testTokenURI() public {
        // setup
        testMoveSuccess();
        // execute
        connector.tokenURI(gameId);
    }

    /// ===================
    /// ===== SUCCESS =====
    /// ===================
    function testHorizontal() public {
        // setup
        _challenge(bob, eve, fee);
        _begin(eve, gameId, 0, 0, fee);
        _move(bob, gameId, 1, 0);
        _move(eve, gameId, 0, 1);
        _move(bob, gameId, 2, 0);
        _move(eve, gameId, 0, 2);
        _move(bob, gameId, 3, 0);
        _move(eve, gameId, 0, 3);
        // assert
        assertEq(turn, eve);
        assertEq(moves, 7);
        assertEq(uint256(state), uint256(State.SUCCESS));
        assertEq(uint256(strat), uint256(Strat.HORIZONTAL));
        assertEq(connector.ownerOf(gameId), eve);
        assertEq(connector.totalSupply(), 1);
        connector.tokenURI(gameId);
    }

    function testVertical() public {
        // setup
        _challenge(bob, eve, fee);
        _begin(eve, gameId, 0, 0, fee);
        _move(bob, gameId, 0, 1);
        _move(eve, gameId, 1, 0);
        _move(bob, gameId, 0, 2);
        _move(eve, gameId, 2, 0);
        _move(bob, gameId, 0, 3);
        _move(eve, gameId, 3, 0);
        // assert
        assertEq(turn, eve);
        assertEq(moves, 7);
        assertEq(uint256(state), uint256(State.SUCCESS));
        assertEq(uint256(strat), uint256(Strat.VERTICAL));
        assertEq(connector.ownerOf(gameId), eve);
        assertEq(connector.totalSupply(), 1);
        connector.tokenURI(gameId);
    }

    function testAscending() public {
        // setup
        _challenge(bob, eve, fee);
        _begin(eve, gameId, 0, 0, fee);
        _move(bob, gameId, 0, 1);
        _move(eve, gameId, 1, 1);
        _move(bob, gameId, 0, 2);
        _move(eve, gameId, 1, 0);
        _move(bob, gameId, 1, 2);
        _move(eve, gameId, 2, 2);
        _move(bob, gameId, 0, 3);
        _move(eve, gameId, 1, 3);
        _move(bob, gameId, 2, 3);
        _move(eve, gameId, 3, 3);
        // assert
        assertEq(turn, eve);
        assertEq(moves, 11);
        assertEq(uint256(state), uint256(State.SUCCESS));
        assertEq(uint256(strat), uint256(Strat.ASCENDING));
        assertEq(connector.ownerOf(gameId), eve);
        assertEq(connector.totalSupply(), 1);
        connector.tokenURI(gameId);
    }

    function testDescending() public {
        // setup
        _challenge(bob, eve, fee);
        _begin(eve, gameId, 0, 0, fee);
        _move(bob, gameId, 1, 0);
        _move(eve, gameId, 2, 0);
        _move(bob, gameId, 0, 1);
        _move(eve, gameId, 3, 0);
        _move(bob, gameId, 1, 1);
        _move(eve, gameId, 2, 1);
        _move(bob, gameId, 0, 2);
        _move(eve, gameId, 1, 2);
        _move(bob, gameId, 2, 2);
        _move(eve, gameId, 0, 3);
        // assert
        assertEq(turn, eve);
        assertEq(moves, 11);
        assertEq(uint256(state), uint256(State.SUCCESS));
        assertEq(uint256(strat), uint256(Strat.DESCENDING));
        assertEq(connector.ownerOf(gameId), eve);
        assertEq(connector.totalSupply(), 1);
        connector.tokenURI(gameId);
    }

    /// ================
    /// ===== DRAW =====
    /// ================
    function testDraw() public {
        // setup
        _challenge(bob, eve, fee);
        _begin(eve, gameId, 0, 0, fee);
        _move(bob, gameId, 1, 0);
        _move(eve, gameId, 2, 0);
        _move(bob, gameId, 3, 0);
        _move(eve, gameId, 4, 0);
        _move(bob, gameId, 5, 0);
        _move(eve, gameId, 0, 1);
        _move(bob, gameId, 1, 1);
        _move(eve, gameId, 2, 1);
        _move(bob, gameId, 3, 1);
        _move(eve, gameId, 4, 1);
        _move(bob, gameId, 5, 1);
        _move(eve, gameId, 0, 2);
        _move(bob, gameId, 1, 2);
        _move(eve, gameId, 2, 2);
        _move(bob, gameId, 3, 2);
        _move(eve, gameId, 4, 2);
        _move(bob, gameId, 5, 2);
        _move(eve, gameId, 0, 4);
        _move(bob, gameId, 0, 3);
        _move(eve, gameId, 1, 3);
        _move(bob, gameId, 2, 3);
        _move(eve, gameId, 3, 3);
        _move(bob, gameId, 4, 3);
        _move(eve, gameId, 5, 3);
        _move(bob, gameId, 1, 4);
        _move(eve, gameId, 2, 4);
        _move(bob, gameId, 3, 4);
        _move(eve, gameId, 4, 4);
        _move(bob, gameId, 5, 4);
        _move(eve, gameId, 0, 5);
        _move(bob, gameId, 1, 5);
        _move(eve, gameId, 2, 5);
        _move(bob, gameId, 3, 5);
        _move(eve, gameId, 4, 5);
        _move(bob, gameId, 5, 5);
        _move(eve, gameId, 0, 6);
        _move(bob, gameId, 1, 6);
        _move(eve, gameId, 2, 6);
        _move(bob, gameId, 3, 6);
        _move(eve, gameId, 4, 6);
        _move(bob, gameId, 5, 6);
        // assert
        assertEq(turn, address(0));
        assertEq(moves, ROW * COL);
        assertEq(uint256(state), uint256(State.DRAW));
        assertEq(uint256(strat), uint256(Strat.NONE));
        assertEq(connector.ownerOf(gameId), address(connector));
        assertEq(connector.totalSupply(), 0);
        connector.tokenURI(gameId);
    }

    /// ===================
    /// ===== HELPERS =====
    /// ===================

    function printBoard() public view {
        uint256 x = 1;
        uint256 y = 1;
        for (uint256 i; i < ROW; ++i) {
            for (uint256 j; j < COL; ++j) {
                console.log(x, y, board[i][j]);
                ++y;
            }
            ++x;
            y = 1;
        }
    }

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
        board[_row] = connector.getRow(_gameId, _row);
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
