// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/utils/Strings.sol";
import "src/interfaces/IGenerator.sol";

contract Generator is IGenerator {
    using Strings for uint256;
    string public constant BLUE = "#29335c";
    string public constant RED = "#DB2B39";
    string public constant YELLOW = "#F3A712";

    constructor() payable {}

    function generateSVG(
        uint256 _gameId,
        uint8 _row,
        uint8 _col,
        uint8[COL][ROW] memory _board
    ) external pure returns (string memory svg) {
        string memory board = _generateBoard();
        (string memory base, string memory player1, string memory player2) = _getPalette(_gameId);
        for (uint8 y; y < COL; ++y) {
            board = string.concat(board, _generateGrid(y));
            for (uint8 x; x < ROW; ++x) {
                string memory cell;
                if (_board[x][y] == PLAYER_1) {
                    cell = _generateCell(x, y, _row, _col, player1);
                } else if (_board[x][y] == PLAYER_2) {
                    cell = _generateCell(x, y, _row, _col, player2);
                }
                board = string.concat(board, cell);
            }
            board = string.concat(board, _generateBase(base));
        }
        svg = string.concat(board, "</svg>");
    }

    function getCheckers(
        uint256 _gameId
    ) external pure returns (string memory checker1, string memory checker2) {
        (, string memory player1, string memory player2) = _getPalette(_gameId);
        checker1 = _getColor(player1);
        checker2 = _getColor(player2);
    }

    function getStatus(State _state) external pure returns (string memory status) {
        if (_state == State.INACTIVE) status = "Inactive";
        else if (_state == State.ACTIVE) status = "Active";
        else if (_state == State.SUCCESS) status = "Success";
        else status = "Draw";
    }

    function _generateBoard() internal pure returns (string memory) {
        return
            "<svg viewBox='0 0 700 600' xmlns='http://www.w3.org/2000/svg'><defs><pattern id='cell-pattern' patternUnits='userSpaceOnUse' width='100' height='100'><circle cx='50' cy='50' r='45' fill='black'></circle></pattern><mask id='cell-mask'><rect width='100' height='600' fill='white'></rect><rect width='100' height='600' fill='url(#cell-pattern)'></rect></mask></defs>";
    }

    function _generateGrid(uint256 _col) internal pure returns (string memory) {
        uint256 x = _col * 100;
        string[3] memory grid;
        grid[0] = "<svg x='";
        grid[1] = x.toString();
        grid[2] = "' y='0'>";

        return string(abi.encodePacked(grid[0], grid[1], grid[2]));
    }

    function _generateCell(
        uint256 _x,
        uint256 _y,
        uint8 _row,
        uint8 _col,
        string memory _checker
    ) internal pure returns (string memory cell) {
        uint256 cy = 550 - (_x * 100);
        if (_x == _row && _y == _col) {
            cell = _animateCell(cy, _checker);
        } else {
            cell = _staticCell(cy, _checker);
        }
    }

    function _animateCell(
        uint256 _cy,
        string memory _checker
    ) internal pure returns (string memory) {
        uint256 duration = (_cy / 100 == 0) ? 1 : _cy / 100;
        string memory secs = string.concat(duration.toString(), "s");
        string[7] memory cell;
        cell[0] = "<circle cx='50' r='45' fill='";
        cell[1] = _checker;
        cell[2] = "'><animate attributeName='cy' from='0' to='";
        cell[3] = _cy.toString();
        cell[4] = "' dur='";
        cell[5] = secs;
        cell[6] = "' begin='2s' fill='freeze'></animate></circle>";

        return string(abi.encodePacked(cell[0], cell[1], cell[2], cell[3], cell[4], cell[5], cell[6]));
    }

    function _staticCell(
        uint256 _cy,
        string memory _checker
    ) internal pure returns (string memory) {
        string[5] memory cell;
        cell[0] = "<circle cx='50' cy='";
        cell[1] = _cy.toString();
        cell[2] = "' r='45' fill='";
        cell[3] = _checker;
        cell[4] = "'></circle>";

        return string(abi.encodePacked(cell[0], cell[1], cell[2], cell[3], cell[4]));
    }

    function _generateBase(string memory _base) internal pure returns (string memory) {
        string[3] memory base;
        base[0] = "<rect width='100' height='600' fill='";
        base[1] = _base;
        base[2] = "' mask='url(#cell-mask)'></rect></svg>";

        return string(abi.encodePacked(base[0], base[1], base[2]));
    }

    function _getPalette(
        uint256 _gameId
    ) internal pure returns (string memory base, string memory player1, string memory player2) {
        if (_gameId % 3 == 0) {
            base = RED;
            if (_gameId % 2 == 0) {
                player1 = BLUE;
                player2 = YELLOW;
            } else {
                player1 = YELLOW;
                player2 = BLUE;
            }
        } else if (_gameId % 3 == 1) {
            base = YELLOW;
            if (_gameId % 2 == 0) {
                player1 = RED;
                player2 = BLUE;
            } else {
                player1 = BLUE;
                player2 = RED;
            }
        } else if (_gameId % 3 == 2) {
            base = BLUE;
            if (_gameId % 2 == 0) {
                player1 = RED;
                player2 = YELLOW;
            } else {
                player1 = YELLOW;
                player2 = RED;
            }
        }
    }

    function _getColor(string memory _player) internal pure returns (string memory checker) {
        if (_hashStr(_player) == _hashStr(BLUE)) checker = "Blue";
        else if (_hashStr(_player) == _hashStr(RED)) checker = "Red";
        else checker = "Yellow";
    }

    function _hashStr(string memory _value) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_value));
    }
}
