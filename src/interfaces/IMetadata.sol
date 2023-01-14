// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {COL, ROW, State} from "src/interfaces/IConnector.sol";

struct Render {
    string base;
    string player1;
    string player2;
}

interface IMetadata {
    function BLUE() external view returns (string memory);

    function RED() external view returns (string memory);

    function YELLOW() external view returns (string memory);

    function renders(uint256) external view returns (string memory, string memory, string memory);

    function generateBase(string memory _base) external pure returns (string memory);

    function generateBoard() external pure returns (string memory);

    function generateCell(
        uint256 _row,
        string memory _checker
    ) external pure returns (string memory);

    function generateGrid(uint256 _col) external pure returns (string memory);

    function generateSVG(
        uint256 _gameId,
        address _player1,
        address _player2,
        address[COL][ROW] memory _board
    ) external view returns (string memory svg);

    function getChecker(uint256 _gameId) external view returns (string memory, string memory);

    function getStatus(State _state) external view returns (string memory status);

    function register(uint256 _gameId) external;
}