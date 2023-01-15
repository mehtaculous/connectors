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
    uint256 row;
    uint256 col;
    address[COL][ROW] board;
}

interface IConnectoooors {
    error InvalidGame();
    error InvalidMatchup();
    error InvalidMove();
    error InvalidPayment();
    error InvalidPlayer();
    error InvalidState();
    error NotAuthorized();

    event Challenge(uint256 indexed _gameId, address indexed _player1, address indexed _player2);

    event Begin(uint256 indexed _gameId, address indexed _player2, State indexed _state);

    event Move(
        uint256 indexed _gameId,
        address indexed _player,
        uint256 _moves,
        uint256 _row,
        uint256 _col
    );

    event Result(
        uint256 indexed _gameId,
        address indexed _winner,
        State indexed _state,
        Strat _strat,
        address[COL][ROW] _board
    );

    function MAX_SUPPLY() external view returns (uint256);

    function challenge(address _opponent) external payable;

    function currentId() external view returns (uint256);

    function begin(uint256 _gameId, uint256 _row, uint256 _col) external payable;

    function fee() external view returns (uint256);

    function getRow(uint256 _gameId, uint256 _row) external view returns (address[COL] memory);

    function metadata() external view returns (address);

    function move(uint256 _gameId, uint256 _row, uint256 _col) external payable returns (Strat);

    function setFee(uint256 _fee) external payable;

    function toggleAnimate() external payable;

    function totalSupply() external view returns (uint256);

    function withdraw(address payable _to) external payable;
}
