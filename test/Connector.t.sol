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

    // Contracts
    Connector connector;

    // Game
    Game game;
    State state;
    Strat strat;
    address player1;
    address player2;
    address turn;
    address winner;
    uint256 moves;
    address[COL][ROW] board;

    // State
    address render;
    uint256 gameId;
    uint256 row;
    uint256 totalSupply;

    // Users
    address alice = address(111);
    address bob = address(222);

    // Balances
    uint256 aliceBalance;
    uint256 bobBalance;

    // Constants
    uint256 constant ETH_BALANCE = 100 ether;
    uint256 constant MIN_ETHER = 1 wei;

    // Errors
    bytes4 INVALID_GAME_ERROR = IConnector.InvalidGame.selector;
    bytes4 INVALID_MATCHUP_ERROR = IConnector.InvalidMatchup.selector;
    bytes4 INVALID_MOVE_ERROR = IConnector.InvalidMove.selector;
    bytes4 INVALID_PAYMENT_ERROR = IConnector.InvalidPayment.selector;
    bytes4 INVALID_PLACEMENT_ERROR = IConnector.InvalidPlacement.selector;
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
        render = connector.render();

        vm.deal(alice, ETH_BALANCE);
        vm.deal(bob, ETH_BALANCE);
        vm.deal(address(this), ETH_BALANCE);

        vm.label(alice, "Alice");
        vm.label(bob, "Bob");
        vm.label(address(connector), "Connector");
        vm.label(render, "Render");
        vm.label(address(this), "ConnectorTest");
    }

    function testChallengeSuccess() public {
        _challenge(alice, bob);
        gameId = connector.currentId();
    }

    function testChallengeRevertInvalidPayment() public {
        _setFee(address(this), 1 wei);

        vm.expectRevert(INVALID_PAYMENT_ERROR);
        _challenge(alice, bob);
    }

    function testChallengeRevertInvalidMatchup() public {
        vm.expectRevert(INVALID_MATCHUP_ERROR);
        _challenge(alice, alice);
    }

    function testBeginSuccess(uint256 _col) public {
        testChallengeSuccess();
        _col = _boundCol(_col, 0, COL);

        _begin(bob, gameId, row, _col);
    }

    function testBeginRevertInvalidPayment(uint256 _col) public {
        testChallengeSuccess();
        _setFee(address(this), 1 wei);
        _col = _boundCol(_col, 0, COL);

        vm.expectRevert(INVALID_PAYMENT_ERROR);
        _begin(bob, gameId, row, _col);
    }

    function testBeginRevertInvalidState(uint256 _col) public {
        _col = _boundCol(_col, 0, COL);

        vm.expectRevert(INVALID_STATE_ERROR);
        _begin(bob, gameId, row, _col);
    }

    function testBeginRevertNotAuthorized(uint256 _col) public {
        testChallengeSuccess();
        _col = _boundCol(_col, 0, COL);

        vm.expectRevert(NOT_AUTHORIZED_ERROR);
        _begin(alice, gameId, row, _col);
    }

    function testMoveSuccess(uint256 _row, uint256 _col) public {
        testChallengeSuccess();
        testBeginSuccess(_col);
        vm.assume(_row < 2);
        _col = _boundCol(_row, 0, COL-1);

        _move(alice, gameId, _row, _col);
    }

    function testMoveRevertInvalidGame(uint256 _row, uint256 _col) public {
        testChallengeSuccess();
        testBeginSuccess(_col);
        vm.assume(_row < 2);
        _col = _boundCol(_row, 0, COL);

        vm.expectRevert(INVALID_GAME_ERROR);
        _move(alice, 0, _row, _col);
    }

    function testMoveRevertInvalidState(uint256 _row, uint256 _col) public {
        testChallengeSuccess();
        testBeginSuccess(_col);
        vm.assume(_row < 2);
        _col = _boundCol(_row, 0, COL);

        vm.expectRevert(INVALID_STATE_ERROR);
        _move(alice, gameId, _row, _col);
    }

    function testMoveRevertInvalidTurn(uint256 _row, uint256 _col) public {
        testBeginSuccess(_col);
        vm.assume(_row < 2);
        _col = _boundCol(_row, 0, COL);

        vm.expectRevert(INVALID_TURN_ERROR);
        _move(bob, gameId, _row, _col);
    }

    function testMoveRevertInvalidMove(uint256 _row, uint256 _col) public {
        testBeginSuccess(_col);
        vm.assume(_row >= 2);
        _col = _boundCol(_row, 0, COL);

        vm.expectRevert(INVALID_MOVE_ERROR);
        _move(alice, gameId, _row, _col);
    }

    function testMoveRevertInvalidPlacement(uint256 _row, uint256 _col) public {
        testBeginSuccess(_col);
        vm.assume(_row < 2);
        _col = _boundCol(_row, 0, COL);

        vm.expectRevert(INVALID_PLACEMENT_ERROR);
        _move(alice, gameId, _row, _col);
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

    function testTokenURI() public view {
        connector.tokenURI(gameId);
    }

    /// ===================
    /// ===== HELPERS =====
    /// ===================

    function _challenge(address _sender, address _opponent) internal prank(_sender) {
        connector.challenge(_opponent);
    }

    function _begin(address _sender, uint256 _gameId, uint256 _row, uint256 _col) internal prank(_sender) {
        connector.begin(_gameId, _row, _col);
    }

    function _move(address _sender, uint256 _gameId, uint256 _row, uint256 _col) internal prank(_sender) {
        connector.move(_gameId, _row, _col);
    }

    function _setFee(address _sender, uint256 _fee) internal prank(_sender) {
        connector.setFee(_fee);
    }

    function _withdraw(address _sender, address payable _to) internal prank(_sender) {
        connector.withdraw(_to);
    }

    function _boundCol(uint256 _col, uint256 _min, uint256 _max) internal view returns (uint256 col) {
        col = bound(_col, _min, _max);
        vm.assume(col >= _min && col < _max);
    }

    function _boundFee(uint256 _fee, uint256 _min, uint256 _max) internal view returns (uint256 fee) {
        fee = bound(_fee, _min, _max);
        vm.assume(fee >= _min && fee < _max);
    }
}
