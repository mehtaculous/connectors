// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {COL, ROW, PLAYER_1, PLAYER_2, State} from "src/interfaces/IConnectors.sol";

interface IGenerator {
    function BLUE() external view returns (string memory);

    function RED() external view returns (string memory);

    function YELLOW() external view returns (string memory);

    function generateSVG(
        uint256 _gameId,
        uint8 _row,
        uint8 _col,
        uint8[COL][ROW] memory _board
    ) external pure returns (string memory);

    function getCheckers(uint256 _gameId) external pure returns (string memory, string memory);

    function getStatus(State _state) external view returns (string memory);
}
