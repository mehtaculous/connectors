// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "src/interfaces/IMetadata.sol";

contract Metadata is IMetadata, Ownable {
    using Strings for uint256;
    string public constant BLUE = "#29335c";
    string public constant RED = "#DB2B39";
    string public constant YELLOW = "#F3A712";
    bool public animate;
    string[] public palette = [YELLOW, BLUE, RED];
    mapping(uint256 => Render) public renders;

    constructor() payable {}

    function register(uint256 _gameId) external onlyOwner {
        Render storage render = renders[_gameId];
        render.base = palette[(_gameId - 1) % 3];
        render.player1 = palette[(_gameId) % 3];
        render.player2 = palette[(_gameId + 1) % 3];
    }

    function generateSVG(
        uint256 _gameId,
        uint8 _row,
        uint8 _col,
        uint8[COL][ROW] memory _board
    ) external view returns (string memory svg) {
        Render memory render = renders[_gameId];
        string memory board = _generateBoard();
        for (uint256 y; y < COL; ++y) {
            board = string.concat(board, _generateGrid(y));
            for (uint256 x; x < ROW; ++x) {
                string memory cell;
                if (_board[x][y] == PLAYER_1) {
                    cell = _generateCell(x, y, _row, _col, render.player1);
                } else if (_board[x][y] == PLAYER_2) {
                    cell = _generateCell(x, y, _row, _col, render.player2);
                }
                board = string.concat(board, cell);
            }
            board = string.concat(board, _generateBase(render.base));
        }
        svg = string.concat(board, "</svg>");
    }

    function toggleAnimate() external onlyOwner {
        animate = !animate;
    }

    function getChecker(
        uint256 _gameId
    ) external view returns (string memory player1, string memory player2) {
        Render memory render = renders[_gameId];
        player1 = _getColor(render.player1);
        player2 = _getColor(render.player2);
    }

    function getStatus(State _state) external pure returns (string memory status) {
        if (_state == State.INACTIVE) status = "Inactive";
        else if (_state == State.ACTIVE) status = "Active";
        else if (_state == State.SUCCESS) status = "Success";
        else status = "Draw";
    }

    function _generateCell(
        uint256 _x,
        uint256 _y,
        uint8 _row,
        uint8 _col,
        string memory _checker
    ) internal view returns (string memory cell) {
        uint256 cy = 550 - (_x * 100);
        if (_x == _row && _y == _col && animate) {
            cell = _animateCell(cy, _checker);
        } else {
            cell = _staticCell(cy, _checker);
        }
    }

    function _generateBoard() internal pure returns (string memory) {
        return
            "<svg width='600px' viewBox='0 0 700 600' xmlns='http://www.w3.org/2000/svg'><defs><pattern id='cell-pattern' patternUnits='userSpaceOnUse' width='100' height='100'><circle cx='50' cy='50' r='45' fill='black'></circle></pattern><mask id='cell-mask'><rect width='100' height='600' fill='white'></rect><rect width='100' height='600' fill='url(#cell-pattern)'></rect></mask></defs>";
    }

    function _generateGrid(uint256 _col) internal pure returns (string memory) {
        uint256 x = _col * 100;
        string[3] memory grid;
        grid[0] = "<svg x='";
        grid[1] = x.toString();
        grid[2] = "' y='0'>";

        return string(abi.encodePacked(grid[0], grid[1], grid[2]));
    }

    function _generateBase(string memory _base) internal pure returns (string memory) {
        string[3] memory base;
        base[0] = "<rect width='100' height='600' fill='";
        base[1] = _base;
        base[2] = "' mask='url(#cell-mask)'></rect></svg>";

        return string(abi.encodePacked(base[0], base[1], base[2]));
    }

    function _animateCell(
        uint256 _cy,
        string memory _checker
    ) internal pure returns (string memory) {
        uint256 duration = (_cy / 100 == 0) ? 1 : _cy / 100;
        string memory secs = string.concat(duration.toString(), "s");

        string[7] memory cell;
        cell[0] = "<circle id='latest' cx='50' cy='0' r='45' fill='";
        cell[1] = _checker;
        cell[2] = "'><animate xlink:href='#latest' attributename='cy' from='0' to='";
        cell[3] = _cy.toString();
        cell[4] = " 'dur='";
        cell[5] = secs;
        cell[6] = "' begin='2s' fill='freeze'></animate></circle>";

        return
            string(abi.encodePacked(cell[0], cell[1], cell[2], cell[3], cell[4], cell[5], cell[6]));
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

    function _getColor(string memory _player) internal pure returns (string memory checker) {
        if (_hash(_player) == _hash(BLUE)) checker = "Blue";
        else if (_hash(_player) == _hash(RED)) checker = "Red";
        else checker = "Yellow";
    }

    function _hash(string memory _value) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_value));
    }
}
