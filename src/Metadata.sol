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
    string[] public palette = [YELLOW, BLUE, RED];
    mapping(uint256 => Render) public renders;

    constructor() payable {}

    function register(uint256 _gameId) external onlyOwner {
        Render storage render = renders[_gameId];
        render.base = palette[_gameId - (1 % 3)];
        render.player1 = palette[(_gameId) % 3];
        render.player2 = palette[(_gameId + 1) % 3];
    }

    function generateSVG(
        uint256 _gameId,
        address _player1,
        address _player2,
        address[COL][ROW] memory _board
    ) external view returns (string memory svg) {
        Render memory render = renders[_gameId];
        string memory board = generateBoard();
        for (uint256 y; y < COL; ++y) {
            board = string.concat(board, generateGrid(y));
            for (uint256 x; x < ROW; ++x) {
                if (_board[x][y] == _player1) {
                    board = string.concat(board, generateCell(x, render.player1));
                } else if (_board[x][y] == _player2) {
                    board = string.concat(board, generateCell(x, render.player2));
                }
            }
            board = string.concat(board, generateBase(render.base));
        }
        svg = string.concat(board, "</svg>");
    }

    function generateBoard() public pure returns (string memory) {
        return
            "<svg width='600px' viewBox='0 0 700 600' xmlns='http://www.w3.org/2000/svg'><defs><pattern id='cell-pattern' patternUnits='userSpaceOnUse' width='100' height='100'><circle cx='50' cy='50' r='45' fill='black'></circle></pattern><mask id='cell-mask'><rect width='100' height='600' fill='white'></rect><rect width='100' height='600' fill='url(#cell-pattern)'></rect></mask></defs>";
    }

    function generateGrid(uint256 _col) public pure returns (string memory) {
        uint256 x = _col * 100;
        string[3] memory grid;
        grid[0] = "<svg x='";
        grid[1] = x.toString();
        grid[2] = "' y='0'>";

        return string(abi.encodePacked(grid[0], grid[1], grid[2]));
    }

    function generateBase(string memory _base) public pure returns (string memory) {
        string[3] memory base;
        base[0] = "<rect width='100' height='600' fill='";
        base[1] = _base;
        base[2] = "' mask='url(#cell-mask)'></rect></svg>";

        return string(abi.encodePacked(base[0], base[1], base[2]));
    }

    function generateCell(
        uint256 _row,
        string memory _checker
    ) public pure returns (string memory) {
        uint256 cy = 550 - (_row * 100);
        string[5] memory cell;
        cell[0] = "<circle cx='50' cy='";
        cell[1] = cy.toString();
        cell[2] = "' r='45' fill='";
        cell[3] = _checker;
        cell[4] = "'></circle>";

        return string(abi.encodePacked(cell[0], cell[1], cell[2], cell[3], cell[4]));
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

    function _getColor(string memory _player) internal pure returns (string memory checker) {
        if (_hash(_player) == _hash(BLUE)) checker = "Blue";
        else if (_hash(_player) == _hash(RED)) checker = "Red";
        else checker = "Yellow";
    }

    function _hash(string memory _value) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_value));
    }
}
