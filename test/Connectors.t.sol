// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Connectors.sol";
import "src/interfaces/IConnectors.sol";

contract ConnectorsTest is Test {
    // Contracts
    Connectors connectors;

    // Users
    address bob = address(111);
    address eve = address(222);

    // State
    address generator;
    uint256 gameId;
    string checker1;
    string checker2;

    // Game
    State state;
    uint8 row;
    uint8 col;
    uint8 moves;
    uint8 turn;
    address player1;
    address player2;
    uint8[COL][ROW] board;

    // Constants
    string constant BLUE = "Blue";
    string constant RED = "Red";
    string constant YELLOW = "Yellow";
    uint16 constant SUPPLY = 999;
    uint64 constant FEE = .01 ether;
    uint256 constant BALANCE = 100 ether;

    // Errors
    bytes NOT_OWNER_ERROR = bytes("Ownable: caller is not the owner");
    bytes4 INSUFFICIENT_SUPPLY_ERROR = IConnectors.InsufficientSupply.selector;
    bytes4 INVALID_COLUMN_ERROR = IConnectors.InvalidColumn.selector;
    bytes4 INVALID_GAME_ERROR = IConnectors.InvalidGame.selector;
    bytes4 INVALID_MATCHUP_ERROR = IConnectors.InvalidMatchup.selector;
    bytes4 INVALID_MOVE_ERROR = IConnectors.InvalidMove.selector;
    bytes4 INVALID_PAYMENT_ERROR = IConnectors.InvalidPayment.selector;
    bytes4 INVALID_STATE_ERROR = IConnectors.InvalidState.selector;
    bytes4 NOT_AUTHORIZED_ERROR = IConnectors.NotAuthorized.selector;

    /// =====================
    /// ===== MODIFIERS =====
    /// =====================
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
        connectors = new Connectors();
        generator = connectors.generator();

        vm.deal(bob, BALANCE);
        vm.deal(eve, BALANCE);
        vm.deal(address(this), BALANCE);

        vm.label(address(connectors), "Connectors");
        vm.label(address(this), "ConnectorsTest");
        vm.label(generator, "Generator");
        vm.label(bob, "Bob");
        vm.label(eve, "Eve");
    }

    /// =====================
    /// ===== CHALLENGE =====
    /// =====================
    function testChallengeSuccess() public {
        // execute
        _challenge(bob, eve, FEE);
        // assert
        assertEq(gameId, 1);
        assertEq(player1, bob);
        assertEq(player2, eve);
        assertEq(turn, PLAYER_2);
        assertEq(uint8(state), uint8(State.ACTIVE));
        assertEq(bob.balance, BALANCE - FEE);
        assertEq(address(connectors).balance, FEE);
        assertEq(connectors.ownerOf(gameId), address(connectors));
    }

    function testChallengeRevertInsufficientSupply() public {
        // setup
        for (uint256 i; i < SUPPLY; ++i) simulateGame(bob, eve);
        // revert
        vm.expectRevert(INSUFFICIENT_SUPPLY_ERROR);
        // execute
        _challenge(bob, eve, FEE);
    }

    function testChallengeRevertInvalidMatchup() public {
        // revert
        vm.expectRevert(INVALID_MATCHUP_ERROR);
        // execute
        _challenge(bob, bob, FEE);
    }

    function testChallengeRevertInvalidPayment() public {
        // revert
        vm.expectRevert(INVALID_PAYMENT_ERROR);
        // execute
        _challenge(bob, eve, FEE - 1);
    }

    /// ================
    /// ===== MOVE =====
    /// ================
    function testMoveSuccess(uint8 _col) public {
        // setup
        testChallengeSuccess();
        _col = _boundCol(_col, 1, COL);
        // execute
        _move(eve, gameId, _col);
        // assert
        assertEq(board[row][col], PLAYER_2);
        assertEq(turn, PLAYER_1);
        assertEq(moves, 1);
    }

    function testMoveRevertInvalidGame(uint8 _col) public {
        // setup
        testMoveSuccess(_col);
        _col = _boundCol(_col, 1, COL);
        // revert
        vm.expectRevert(INVALID_GAME_ERROR);
        // execute
        _move(bob, ++gameId, _col);
    }

    function testMoveRevertInvalidState(uint8 _col) public {
        // setup
        testHorizontal();
        _col = _boundCol(_col, 1, COL);
        // revert
        vm.expectRevert(INVALID_STATE_ERROR);
        // execute
        _move(bob, gameId, _col);
    }

    function testMoveRevertNotAuthorized(uint8 _col) public {
        // setup
        testMoveSuccess(_col);
        _col = _boundCol(_col, 1, COL);
        // revert
        vm.expectRevert(NOT_AUTHORIZED_ERROR);
        // execute
        _move(eve, gameId, _col);
    }

    function testMoveRevertInvalidColumn(uint8 _col) public {
        // setup
        testMoveSuccess(_col);
        _col = _boundCol(_col, 1, COL);
        // revert
        vm.expectRevert(INVALID_COLUMN_ERROR);
        // execute
        _move(bob, gameId, 0);
    }

    function testMoveRevertColOutOfBounds(uint8 _col) public {
        // setup
        testMoveSuccess(_col);
        // revert
        vm.expectRevert();
        // execute
        _move(bob, gameId, COL + 1);
    }

    function testMoveRevertInvalidMove() public {
        // setup
        testChallengeSuccess();
        _move(eve, gameId, 1);
        _move(bob, gameId, 1);
        _move(eve, gameId, 1);
        _move(bob, gameId, 1);
        _move(eve, gameId, 1);
        _move(bob, gameId, 1);
        // revert
        vm.expectRevert(INVALID_MOVE_ERROR);
        // execute
        _move(eve, gameId, 1);
    }

    /// ========================
    /// ===== TOTAL SUPPLY =====
    /// ========================
    function testTotalSupply() public {
        for (uint256 i; i < SUPPLY; ++i) {
            // setup
            _challenge(bob, eve, FEE);
            // assert
            assertEq(connectors.totalSupply(), i + 1);
        }
    }

    /// ===================
    /// ===== SET FEE =====
    /// ===================
    function testSetFeeSuccess(uint64 _fee) public {
        // execute
        _setFee(address(this), _fee);
        // assert
        assertEq(_fee, connectors.fee());
    }

    function testSetFeeRevertNotOwner(uint64 _fee) public {
        // revert
        vm.expectRevert(NOT_OWNER_ERROR);
        // execute
        _setFee(bob, _fee);
    }

    /// ====================
    /// ===== WITHDRAW =====
    /// ====================
    function testWithdraw(uint8 _col) public {
        // setup
        testMoveSuccess(_col);
        // execute
        _withdraw(address(this), payable(address(this)));
        // assert
        assertEq(address(this).balance, BALANCE + FEE);
    }

    /// =====================
    /// ===== TOKEN URI =====
    /// =====================
    function testTokenURI(uint8 _col) public {
        // setup
        testMoveSuccess(_col);
        // execute
        connectors.tokenURI(gameId);
    }

    /// ========================
    /// ===== GET CHECKERS =====
    /// ========================
    function testGetCheckers() public {
        // 1
        _challenge(bob, eve, FEE);
        (checker1, checker2) = IGenerator(generator).getCheckers(gameId);
        assertEq(checker1, BLUE);
        assertEq(checker2, RED);
        // 2
        _challenge(bob, eve, FEE);
        (checker1, checker2) = IGenerator(generator).getCheckers(gameId);
        assertEq(checker1, RED);
        assertEq(checker2, YELLOW);
        // 3
        _challenge(bob, eve, FEE);
        (checker1, checker2) = IGenerator(generator).getCheckers(gameId);
        assertEq(checker1, YELLOW);
        assertEq(checker2, BLUE);
        // 4
        _challenge(bob, eve, FEE);
        (checker1, checker2) = IGenerator(generator).getCheckers(gameId);
        assertEq(checker1, RED);
        assertEq(checker2, BLUE);
        // 5
        _challenge(bob, eve, FEE);
        (checker1, checker2) = IGenerator(generator).getCheckers(gameId);
        assertEq(checker1, YELLOW);
        assertEq(checker2, RED);
        // 6
        _challenge(bob, eve, FEE);
        (checker1, checker2) = IGenerator(generator).getCheckers(gameId);
        assertEq(checker1, BLUE);
        assertEq(checker2, YELLOW);
    }

    /// ===================
    /// ===== SUCCESS =====
    /// ===================
    function testHorizontal() public {
        // setup
        _challenge(bob, eve, FEE);
        _move(eve, gameId, 1);
        _move(bob, gameId, 1);
        _move(eve, gameId, 2);
        _move(bob, gameId, 1);
        _move(eve, gameId, 3);
        _move(bob, gameId, 1);
        _move(eve, gameId, 4);
        connectors.tokenURI(gameId);
        // assert
        assertEq(turn, PLAYER_2);
        assertEq(moves, 7);
        assertEq(uint256(state), uint256(State.SUCCESS));
        assertEq(connectors.ownerOf(gameId), eve);
        assertEq(connectors.totalSupply(), 1);
    }

    function testVertical() public {
        // setup
        _challenge(bob, eve, FEE);
        _move(eve, gameId, 1);
        _move(bob, gameId, 2);
        _move(eve, gameId, 1);
        _move(bob, gameId, 3);
        _move(eve, gameId, 1);
        _move(bob, gameId, 4);
        _move(eve, gameId, 1);
        connectors.tokenURI(gameId);
        // assert
        assertEq(turn, PLAYER_2);
        assertEq(moves, 7);
        assertEq(uint8(state), uint8(State.SUCCESS));
        assertEq(connectors.ownerOf(gameId), eve);
        assertEq(connectors.totalSupply(), 1);
    }

    function testAscending() public {
        // setup
        _challenge(bob, eve, FEE);
        _move(eve, gameId, 1);
        _move(bob, gameId, 2);
        _move(eve, gameId, 2);
        _move(bob, gameId, 3);
        _move(eve, gameId, 5);
        _move(bob, gameId, 3);
        _move(eve, gameId, 5);
        _move(bob, gameId, 4);
        _move(eve, gameId, 4);
        _move(bob, gameId, 4);
        _move(eve, gameId, 4);
        _move(bob, gameId, 6);
        _move(eve, gameId, 3);
        connectors.tokenURI(gameId);
        // assert
        assertEq(turn, PLAYER_2);
        assertEq(moves, 13);
        assertEq(uint8(state), uint8(State.SUCCESS));
        assertEq(connectors.ownerOf(gameId), eve);
        assertEq(connectors.totalSupply(), 1);
    }

    function testDescending() public {
        // setup
        _challenge(bob, eve, FEE);
        _move(eve, gameId, 1);
        _move(bob, gameId, 1);
        _move(eve, gameId, 1);
        _move(bob, gameId, 2);
        _move(eve, gameId, 1);
        _move(bob, gameId, 2);
        _move(eve, gameId, 2);
        _move(bob, gameId, 3);
        _move(eve, gameId, 3);
        _move(bob, gameId, 3);
        _move(eve, gameId, 4);
        connectors.tokenURI(gameId);
        // assert
        assertEq(turn, PLAYER_2);
        assertEq(moves, 11);
        assertEq(uint8(state), uint8(State.SUCCESS));
        assertEq(connectors.ownerOf(gameId), eve);
        assertEq(connectors.totalSupply(), 1);
    }

    /// ================
    /// ===== DRAW =====
    /// ================
    function testDraw() public {
        // setup
        _challenge(bob, eve, FEE);
        _move(eve, gameId, 1);
        _move(bob, gameId, 1);
        _move(eve, gameId, 1);
        _move(bob, gameId, 1);
        _move(eve, gameId, 1);
        _move(bob, gameId, 1);
        _move(eve, gameId, 2);
        _move(bob, gameId, 2);
        _move(eve, gameId, 2);
        _move(bob, gameId, 2);
        _move(eve, gameId, 2);
        _move(bob, gameId, 2);
        _move(eve, gameId, 3);
        _move(bob, gameId, 3);
        _move(eve, gameId, 3);
        _move(bob, gameId, 3);
        _move(eve, gameId, 3);
        _move(bob, gameId, 3);
        _move(eve, gameId, 5);
        _move(bob, gameId, 4);
        _move(eve, gameId, 4);
        _move(bob, gameId, 4);
        _move(eve, gameId, 4);
        _move(bob, gameId, 4);
        _move(eve, gameId, 4);
        _move(bob, gameId, 5);
        _move(eve, gameId, 5);
        _move(bob, gameId, 5);
        _move(eve, gameId, 5);
        _move(bob, gameId, 5);
        _move(eve, gameId, 6);
        _move(bob, gameId, 6);
        _move(eve, gameId, 6);
        _move(bob, gameId, 6);
        _move(eve, gameId, 6);
        _move(bob, gameId, 6);
        _move(eve, gameId, 7);
        _move(bob, gameId, 7);
        _move(eve, gameId, 7);
        _move(bob, gameId, 7);
        _move(eve, gameId, 7);
        _move(bob, gameId, 7);
        connectors.tokenURI(gameId);
        // assert
        assertEq(turn, 0);
        assertEq(moves, ROW * COL);
        assertEq(uint8(state), uint8(State.DRAW));
        assertEq(connectors.ownerOf(gameId), address(connectors));
        assertEq(connectors.totalSupply(), 1);
    }

    /// ===================
    /// ===== HELPERS =====
    /// ===================

    function simulateGame(address _player1, address _player2) public {
        _challenge(_player1, _player2, FEE);
        _move(_player2, gameId, 1);
        _move(_player1, gameId, 1);
        _move(_player2, gameId, 2);
        _move(_player1, gameId, 1);
        _move(_player2, gameId, 3);
        _move(_player1, gameId, 1);
        _move(_player2, gameId, 4);
    }

    function printBoard() public view {
        uint8 x = 1;
        uint8 y = 1;
        for (uint8 i; i < ROW; ++i) {
            for (uint8 j; j < COL; ++j) {
                console.log(x, y, board[i][j]);
                ++y;
            }
            ++x;
            y = 1;
        }
    }

    function _challenge(address _sender, address _opponent, uint64 _fee) internal prank(_sender) {
        connectors.challenge{value: _fee}(_opponent);
        _setGame();
        _setState(gameId);
    }

    function _move(address _sender, uint256 _gameId, uint8 _col) internal prank(_sender) {
        connectors.move(_gameId, _col);
        _setState(gameId);
        if (row < ROW) _setBoard(gameId, row);
    }

    function _setFee(address _sender, uint64 _fee) internal prank(_sender) {
        connectors.setFee(_fee);
    }

    function _withdraw(address _sender, address payable _to) internal prank(_sender) {
        connectors.withdraw(_to);
    }

    function _setGame() internal {
        gameId = connectors.totalSupply();
    }

    function _setState(uint256 _gameId) internal {
        (state, row, col, moves, turn, player1, player2) = connectors.games(_gameId);
    }

    function _setBoard(uint256 _gameId, uint8 _row) internal {
        board[_row] = connectors.getColumn(_gameId, _row);
    }

    function _boundCol(uint8 _col, uint8 _min, uint8 _max) internal view returns (uint8 value) {
        value = uint8(bound(_col, _min, _max));
        vm.assume(value >= _min && value <= _max);
    }
}
