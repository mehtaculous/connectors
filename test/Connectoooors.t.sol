// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Connectoooors.sol";
import "src/interfaces/IConnectoooors.sol";

contract ConnectoooorsTest is Test {
    // Contracts
    Connectoooors connectors;

    // Users
    address bob = address(111);
    address eve = address(222);

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
    uint256 gameId;

    // Constants
    uint256 constant FEE = .042 ether;
    uint256 constant ETH_BALANCE = 100 ether;

    // Errors
    bytes NOT_OWNER_ERROR = bytes("Ownable: caller is not the owner");
    bytes4 INVALID_GAME_ERROR = IConnectoooors.InvalidGame.selector;
    bytes4 INVALID_MATCHUP_ERROR = IConnectoooors.InvalidMatchup.selector;
    bytes4 INVALID_MOVE_ERROR = IConnectoooors.InvalidMove.selector;
    bytes4 INVALID_PAYMENT_ERROR = IConnectoooors.InvalidPayment.selector;
    bytes4 INVALID_PLAYER_ERROR = IConnectoooors.InvalidPlayer.selector;
    bytes4 INVALID_STATE_ERROR = IConnectoooors.InvalidState.selector;
    bytes4 NOT_AUTHORIZED_ERROR = IConnectoooors.NotAuthorized.selector;

    /// =====================
    /// ===== MODIFIERS =====
    /// =====================
    modifier prank(address _sender) {
        vm.startPrank(_sender);
        _;
        vm.stopPrank();
    }

    modifier prankOrigin(address _sender, address _origin) {
        vm.startPrank(_sender, _origin);
        _;
        vm.stopPrank();
    }

    receive() external payable {}

    /// =================
    /// ===== SETUP =====
    /// =================
    function setUp() public {
        connectors = new Connectoooors();
        metadata = connectors.metadata();

        vm.deal(bob, ETH_BALANCE);
        vm.deal(eve, ETH_BALANCE);
        vm.deal(address(this), ETH_BALANCE);

        vm.label(address(connectors), "Connectoooors");
        vm.label(address(this), "ConnectoooorsTest");
        vm.label(metadata, "Metadata");
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
        assertEq(turn, eve);
        assertEq(uint256(state), uint256(State.INACTIVE));
        assertEq(bob.balance, ETH_BALANCE - FEE);
        assertEq(address(connectors).balance, FEE);
        assertEq(connectors.ownerOf(gameId), address(connectors));
        connectors.tokenURI(gameId);
    }

    function testChallengeRevertInvalidPlayerOrigin() public {
        // revert
        vm.expectRevert(INVALID_PLAYER_ERROR);
        // execute
        connectors.challenge(bob);
    }

    function testChallengeRevertInvalidPlayerContract() public {
        // revert
        vm.expectRevert(INVALID_PLAYER_ERROR);
        // execute
        _challenge(bob, address(this), FEE);
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

    /// =================
    /// ===== BEGIN =====
    /// =================
    function testBeginSuccess(uint256 _col) public {
        // setup
        testChallengeSuccess();
        _col = _boundCol(_col, 0, COL);
        // execute
        _begin(eve, gameId, row, _col, FEE);
        // assert
        assertEq(board[row][col], eve);
        assertEq(moves, 1);
        assertEq(turn, bob);
        assertEq(uint256(state), uint256(State.ACTIVE));
        assertEq(eve.balance, ETH_BALANCE - FEE);
        assertEq(address(connectors).balance, FEE * 2);
        connectors.tokenURI(gameId);
    }

    function testBeginRevertInvalidGame(uint256 _col) public {
        // setup
        testChallengeSuccess();
        _col = _boundCol(_col, 0, COL);
        // revert
        vm.expectRevert(INVALID_GAME_ERROR);
        // execute
        _begin(eve, ++gameId, row, _col, FEE);
    }

    function testBeginRevertInvalidState(uint256 _col) public {
        // setup
        testBeginSuccess(_col);
        _col = _boundCol(_col, 0, COL);
        // revert
        vm.expectRevert(INVALID_STATE_ERROR);
        // execute
        _begin(eve, gameId, row, _col, FEE);
    }

    function testBeginRevertNotAuthorized(uint256 _col) public {
        // setup
        testChallengeSuccess();
        _col = _boundCol(_col, 0, COL);
        // revert
        vm.expectRevert(NOT_AUTHORIZED_ERROR);
        // execute
        _begin(bob, gameId, row, _col, FEE);
    }

    function testBeginRevertInvalidPayment(uint256 _col) public {
        // setup
        testChallengeSuccess();
        _setFee(address(this), 1 ether);
        _col = _boundCol(_col, 0, COL);
        // revert
        vm.expectRevert(INVALID_PAYMENT_ERROR);
        // execute
        _begin(eve, gameId, row, _col, FEE - 1);
    }

    /// ================
    /// ===== MOVE =====
    /// ================
    function testMoveSuccess() public {
        // setup
        _challenge(bob, eve, FEE);
        _begin(eve, gameId, row, col, FEE);
        // execute
        _move(bob, gameId, row, col + 1);
        // assert
        assertEq(board[row][col], bob);
        assertEq(moves, 2);
        assertEq(turn, eve);
        connectors.tokenURI(gameId);
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
        assertEq(_fee, connectors.fee());
    }

    function testSetFeeRevertNotOwner(uint256 _fee) public {
        // revert
        vm.expectRevert(NOT_OWNER_ERROR);
        // execute
        _setFee(bob, _fee);
    }

    /// ==========================
    /// ===== TOGGLE ANIMATE =====
    /// ==========================
    function testToggleAnimateSuccess() public {
        // execute
        _toggleAnimate(address(this));
        // assert
        assertTrue(IMetadata(metadata).animate());
    }

    function testToggleAnimateRevertNotOwner() public {
        // revert
        vm.expectRevert(NOT_OWNER_ERROR);
        // execute
        _toggleAnimate(bob);
    }

    /// ====================
    /// ===== WITHDRAW =====
    /// ====================
    function testWithdraw(uint256 _col) public {
        // setup
        testBeginSuccess(_col);
        // execute
        _withdraw(address(this), payable(address(this)));
        // assert
        assertEq(address(this).balance, ETH_BALANCE + (FEE * 2));
    }

    /// =====================
    /// ===== TOKEN URI =====
    /// =====================
    function testTokenURI() public {
        // setup
        testMoveSuccess();
        // execute
        connectors.tokenURI(gameId);
    }

    /// ===================
    /// ===== SUCCESS =====
    /// ===================
    function testHorizontal() public {
        // setup
        _challenge(bob, eve, FEE);
        _begin(eve, gameId, 0, 0, FEE);
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
        assertEq(connectors.ownerOf(gameId), eve);
        assertEq(connectors.totalSupply(), 1);
        connectors.tokenURI(gameId);
    }

    function testVertical() public {
        // setup
        _challenge(bob, eve, FEE);
        _begin(eve, gameId, 0, 0, FEE);
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
        assertEq(connectors.ownerOf(gameId), eve);
        assertEq(connectors.totalSupply(), 1);
        connectors.tokenURI(gameId);
    }

    function testAscending() public {
        // setup
        _challenge(bob, eve, FEE);
        _begin(eve, gameId, 0, 0, FEE);
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
        assertEq(connectors.ownerOf(gameId), eve);
        assertEq(connectors.totalSupply(), 1);
        connectors.tokenURI(gameId);
    }

    function testDescending() public {
        // setup
        _challenge(bob, eve, FEE);
        _begin(eve, gameId, 0, 0, FEE);
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
        assertEq(connectors.ownerOf(gameId), eve);
        assertEq(connectors.totalSupply(), 1);
        connectors.tokenURI(gameId);
    }

    /// ================
    /// ===== DRAW =====
    /// ================
    function testDraw() public {
        // setup
        _challenge(bob, eve, FEE);
        _begin(eve, gameId, 0, 0, FEE);
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
        assertEq(connectors.ownerOf(gameId), address(connectors));
        assertEq(connectors.totalSupply(), 0);
        connectors.tokenURI(gameId);
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

    function _challenge(
        address _sender,
        address _opponent,
        uint256 _fee
    ) internal prankOrigin(_sender, _sender) {
        connectors.challenge{value: _fee}(_opponent);
        _setGame();
        _setState(gameId);
    }

    function _begin(
        address _sender,
        uint256 _gameId,
        uint256 _row,
        uint256 _col,
        uint256 _fee
    ) internal prank(_sender) {
        connectors.begin{value: _fee}(_gameId, _row, _col);
        _setState(gameId);
        _setMove(_row, _col);
        if (row < ROW) _setBoard(gameId, row);
    }

    function _move(
        address _sender,
        uint256 _gameId,
        uint256 _row,
        uint256 _col
    ) internal prank(_sender) {
        connectors.move(_gameId, _row, _col);
        _setState(gameId);
        _setMove(_row, _col);
        if (row < ROW) _setBoard(gameId, row);
    }

    function _setFee(address _sender, uint256 _fee) internal prank(_sender) {
        connectors.setFee(_fee);
    }

    function _toggleAnimate(address _sender) internal prank(_sender) {
        connectors.toggleAnimate();
    }

    function _withdraw(address _sender, address payable _to) internal prank(_sender) {
        connectors.withdraw(_to);
    }

    function _setGame() internal {
        gameId = connectors.currentId();
    }

    function _setState(uint256 _gameId) internal {
        (state, strat, player1, player2, turn, moves, , ) = connectors.games(_gameId);
    }

    function _setMove(uint256 _row, uint256 _col) internal {
        row = _row;
        col = _col;
    }

    function _setBoard(uint256 _gameId, uint256 _row) internal {
        board[_row] = connectors.getRow(_gameId, _row);
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
