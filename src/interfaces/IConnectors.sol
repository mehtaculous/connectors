// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

uint8 constant COL = 7;
uint8 constant ROW = 6;
uint8 constant PLAYER_1 = 1;
uint8 constant PLAYER_2 = 2;

enum State {
    INACTIVE,
    ACTIVE,
    SUCCESS,
    DRAW
}

struct Game {
    State state;
    uint8 row;
    uint8 col;
    uint8 moves;
    uint8 turn;
    address player1;
    address player2;
    uint8[COL][ROW] board;
}

interface IConnectors {
    error InsufficientSupply();
    error InvalidGame();
    error InvalidMatchup();
    error InvalidMove();
    error InvalidPayment();
    error InvalidState();
    error NotAuthorized();
    error TransferFailed();

    event Challenge(uint256 indexed _gameId, address indexed _player1, address indexed _player2);

    event Begin(uint256 indexed _gameId, address indexed _player2, State indexed _state);

    event Move(
        uint256 indexed _gameId,
        address indexed _player,
        uint8 _moves,
        uint8 _row,
        uint8 _col
    );

    event Result(
        uint256 indexed _gameId,
        address indexed _winner,
        State indexed _state,
        uint8[COL][ROW] _board
    );

    function MAX_SUPPLY() external view returns (uint16);

    function challenge(address _opponent) external payable;

    function begin(uint256 _gameId, uint8 _col) external payable;

    function fee() external view returns (uint64);

    function generator() external view returns (address);

    function getColumn(uint256 _gameId, uint8 _row) external view returns (uint8[COL] memory);

    function getNextRow(uint8[COL][ROW] memory _board, uint8 _col) external view returns (uint8);

    function move(uint256 _gameId, uint8 _col) external returns (bool);

    function setFee(uint64 _fee) external payable;

    function totalSupply() external view returns (uint16);

    function withdraw(address payable _to) external payable;
}
