// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

uint256 constant COL = 7;
uint256 constant ROW = 6;

enum State {
    INACTIVE,
    ACTIVE,
    SUCCESS,
    DRAW
}

enum Strat {
    NONE,
    VERTICAL,
    HORIZONTAL,
    ASCENDING,
    DESCENDING
}

struct Game {
    State state;
    Strat strat;
    address player1;
    address player2;
    address turn;
    uint256 moves;
    address winner;
    address[COL][ROW] board;
}

interface IConnector {
    error InvalidGame();
    error InvalidMatchup();
    error InvalidMove();
    error InvalidPayment();
    error InvalidPlacement();
    error InvalidState();
    error InvalidTurn();
    error NotAuthorized();
    error UnsuccessfulTransfer();

    event Challenge(uint256 indexed _gameId, address indexed _player1, address indexed _player2);

    event Begin(uint256 indexed _gameId, address indexed _player2, State indexed _state);

    event Move(uint256 indexed _gameId, address indexed _player, uint256 _move, uint256 _col, uint256 _row);

    event Result(
        uint256 indexed _gameId,
        address indexed _winner,
        State indexed _state,
        Strat _strat,
        address[COL][ROW] _board
    );

    function challenge(address _opponent) external payable;

    function currentId() external view returns (uint256);

    function begin(uint256 _gameId, uint256 _col, uint256 _row) external payable;

    function fee() external view returns (uint256);

    function move(uint256 _gameId, uint256 _col, uint256 _row) external payable returns (Strat result);

    function setFee(uint256 _fee) external payable;

    function totalSupply() external view returns (uint256);

    function withdraw(address payable _to) external payable;
}
