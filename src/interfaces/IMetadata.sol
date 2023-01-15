// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {COL, ROW, State} from "src/interfaces/IConnectors.sol";

struct Render {
    string base;
    string player1;
    string player2;
}

interface IMetadata {
    function BLUE() external view returns (string memory);

    function RED() external view returns (string memory);

    function YELLOW() external view returns (string memory);

    function animate() external view returns (bool);

    function generateSVG(
        uint256 _gameId,
        uint256 _row,
        uint256 _col,
        address _player1,
        address _player2,
        address[COL][ROW] memory _board
    ) external view returns (string memory);

    function getChecker(uint256 _gameId) external view returns (string memory, string memory);

    function getStatus(State _state) external view returns (string memory);

    function register(uint256 _gameId) external;

    function renders(uint256) external view returns (string memory, string memory, string memory);

    function toggleAnimate() external;
}
