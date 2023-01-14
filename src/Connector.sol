// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./IConnector.sol";
import "./Render.sol";

contract Connector is IConnector, ERC721, ERC721Holder, Ownable {
    using Strings for uint160;
    using Strings for uint256;

    address public immutable render;
    uint256 public currentId;
    uint256 public fee;
    uint256 public totalSupply;
    mapping(uint256 => Game) public games;

    constructor() payable ERC721("Connector", "C4") {
        render = address(new Render());
    }

    function challenge(address _opponent) external payable {
        if (msg.value != fee / 2) revert InvalidPayment();
        if (msg.sender == _opponent) revert InvalidMatchup();

        Game storage game = games[++currentId];
        game.player1 = msg.sender;
        game.player2 = _opponent;
        game.turn = _opponent;

        IRender(render).register(currentId);
        _safeMint(address(this), currentId);

        emit Challenge(currentId, msg.sender, _opponent);
    }

    function begin(
        uint256 _gameId,
        uint256 _col,
        uint256 _row
    ) external payable {
        Game storage game = games[_gameId];
        if (msg.value != fee / 2) revert InvalidPayment();
        if (State.INACTIVE != game.state) revert InvalidState();
        if (msg.sender != game.player2) revert NotAuthorized();

        game.state = State.ACTIVE;
        emit Begin(_gameId, msg.sender, game.state);

        move(_gameId, _col, _row);
    }

    function move(
        uint256 _gameId,
        uint256 _col,
        uint256 _row
    ) public payable returns (Strat result) {
        if (_gameId == 0 || _gameId > currentId) revert InvalidGame();
        Game storage game = games[_gameId];
        address[COL][ROW] storage board = game.board;

        if (game.state != State.ACTIVE) revert InvalidState();
        if (game.turn != msg.sender) revert InvalidTurn();
        if (board[_row][_col] != address(0) || (_row > 0 && board[_row-1][_col] == address(0))) revert InvalidMove();
        if (_row >= ROW || _col >= COL) revert InvalidPlacement();

        ++game.moves;
        uint256 moves = game.moves;
        board[_row][_col] = msg.sender;
        emit Move(_gameId, msg.sender, moves, _col, _row);

        if (moves >= 7) {
            result = _checkHorizontal(msg.sender, _col, _row, board);
            if (result == Strat.NONE) result = _checkVertical(msg.sender, _col, _row, board);
            if (result == Strat.NONE) result = _checkAscending(msg.sender, _col, _row, board);
            if (result == Strat.NONE) result = _checkDescending(msg.sender, _col, _row, board);
        }

        if (result != Strat.NONE) {
            game.strat = result;
            game.state = State.SUCCESS;
            game.winner = msg.sender;
            emit Result(_gameId, game.winner, game.state, game.strat, board);

            if (totalSupply < 100) {
                ++totalSupply;
                safeTransferFrom(address(this), msg.sender, _gameId);
            }
        } else {
            game.turn = (msg.sender == game.player1) ? game.player2 : game.player1;

            if (moves == ROW * COL) {
                game.state = State.DRAW;
                emit Result(_gameId, address(0), game.state, game.strat, board);
            }
        }
    }

    function setFee(uint256 _fee) external payable onlyOwner {
        fee = _fee;
    }

    function withdraw(address payable _to) external payable onlyOwner {
        (bool success, ) = _to.call{value: address(this).balance}("");
        if (!success) revert UnsuccessfulTransfer();
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        _requireMinted(_tokenId);

        Game memory game = games[_tokenId];
        address[COL][ROW] memory board = game.board;
        address player1 = game.player1;
        address player2 = game.player2;
        address turn = game.turn;
        uint256 moves = game.moves;

        string memory image = IRender(render).generateSVG(_tokenId, player1, player2, board);
        string memory status = _getStatus(game.state);
        string memory winner = (game.winner == address(0)) ? "N/A" : _substring(uint160(game.winner).toHexString(20), 0, 10);
        (string memory checker1, string memory checker2) = IRender(render).getCheckers(_tokenId);

        return
            string(
                abi.encodePacked(
                    'data:application/json;utf8,',
                    '{"name":"',
                        string.concat("Connector #", _tokenId.toString()),
                    '",',
                    '"description":"',
                        "Just a friendly on-chain game of Connect Four.",
                    '",',
                    '"image": "data:image/svg+xml;utf8,',
                        image,
                    '",',
                    '"attributes": [{"trait_type":"',
                        checker1,
                    '", "value":"',
                        _substring(uint160(player1).toHexString(20), 0, 10),
                    '"},',
                    '{"trait_type":"',
                        checker2,
                    '", "value":"',
                        _substring(uint160(player2).toHexString(20), 0, 10),
                    '"},',
                    '{"trait_type":"Turn", "value":"',
                        _substring(uint160(turn).toHexString(20), 0, 10),
                    '"},',
                    '{"trait_type":"Moves", "value":"',
                        moves.toString(),
                    '"},',
                    '{"trait_type":"Status", "value":"',
                        status,
                    '"},',
                    '{"trait_type":"Winner", "value":"',
                        winner,
                    '"}]}'
                )
            );
    }

    function _checkVertical(
        address _player,
        uint256 _col,
        uint256 _row,
        address[COL][ROW] storage _board
    ) internal view returns (Strat result) {
        uint256 i;
        uint256 counter;
        unchecked {
            for (i = 1; i < 4; ++i) {
                if (_row == 0) break;
                if (_board[_row - i][_col] == _player) {
                    ++counter;
                } else {
                    break;
                }
                if (_row - i == 0) break;
            }

            for (i = 1; i < 4; ++i) {
                if (_row + i == ROW) break;
                if (_board[_row + i][_col] == _player) {
                    ++counter;
                } else {
                    break;
                }
            }
        }

        if (counter > 2) result = Strat.VERTICAL;
    }

    function _checkHorizontal(
        address _player,
        uint256 _col,
        uint256 _row,
        address[COL][ROW] storage _board
    ) internal view returns (Strat result) {
        uint256 i;
        uint256 counter;
        unchecked {
            for (i = 1; i < 4; ++i) {
                if (_col == 0) break;
                if (_board[_row][_col - i] == _player) {
                    ++counter;
                } else {
                    break;
                }
                if (_col - i == 0) break;
            }

            for (i = 1; i < 4; ++i) {
                if (_col + i == COL) break;
                if (_board[_row][_col + i] == _player) {
                    ++counter;
                } else {
                    break;
                }
            }
        }

        if (counter > 2) result = Strat.HORIZONTAL;
    }

    function _checkAscending(
        address _player,
        uint256 _col,
        uint256 _row,
        address[COL][ROW] storage _board
    ) internal view returns (Strat result) {
        uint256 i;
        uint256 counter;
        unchecked {
            for (i = 1; i < 4; ++i) {
                if (_row == 0 || _col == 0) break;
                if (_board[_row - i][_col - i] == _player) {
                    ++counter;
                } else {
                    break;
                }
                if (_row - i == 0 || _col - i == 0) break;
            }

            for (i = 1; i < 4; ++i) {
                if (_row + i == ROW || _col + i == COL) break;
                if (_board[_row + i][_col + i] == _player) {
                    ++counter;
                } else {
                    break;
                }
            }
        }

        if (counter > 2) result = Strat.ASCENDING;
    }

    function _checkDescending(
        address _player,
        uint256 _col,
        uint256 _row,
        address[COL][ROW] storage _board
    ) internal view returns (Strat result) {
        uint256 i;
        uint256 counter;
        unchecked {
            for (i = 1; i < 4; ++i) {
                if (_row + i == ROW || _col == 0) break;
                if (_board[_row + i][_col - i] == _player) {
                    ++counter;
                } else {
                    break;
                }
                if (_col - i == 0) break;
            }

            for (i = 1; i < 4; ++i) {
                if (_row == 0 || _col + i == COL) break;
                if (_board[_row - i][_col + i] == _player) {
                    ++counter;
                } else {
                    break;
                }
                if (_row - i == 0) break;
            }
        }

        if (counter > 2) result = Strat.DESCENDING;
    }

    function _getStatus(State _state) internal pure returns (string memory status) {
        if (_state == State.INACTIVE) {
            status = "Inactive";
        } else if (_state == State.ACTIVE) {
            status = "Active";
        } else if (_state == State.SUCCESS) {
            status = "Success";
        } else {
            status = "Draw";
        }
    }

    function _substring(string memory _str, uint256 _start, uint256 _end) public pure returns (string memory) {
        bytes memory strBytes = bytes(_str);
        bytes memory result = new bytes(_end - _start);
        for(uint i = _start; i < _end; ++i) {
            result[i-_start] = strBytes[i];
        }
        return string(result);
    }
}
