// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {COL, ROW, PLAYER_1, PLAYER_2, State} from "src/interfaces/IConnectors.sol";

struct Render {
    string base;
    string player1;
    string player2;
}

interface IMetadata {
    function BLUE() external view returns (string memory);

    function RED() external view returns (string memory);

    function YELLOW() external view returns (string memory);

    function generateSVG(
        uint256 _gameId,
        uint8 _row,
        uint8 _col,
        uint8[COL][ROW] memory _board
    ) external view returns (string memory);

    function getChecker(uint256 _gameId) external view returns (string memory, string memory);

    function getStatus(State _state) external view returns (string memory);

    function register(uint256 _gameId) external;

    function renders(uint256) external view returns (string memory, string memory, string memory);
}
