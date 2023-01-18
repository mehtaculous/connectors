// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

/// @title Connectors
/// @author swa.eth

/*********************************
 *           0       0           *
 * |░░░|░░░|░░░|░░░|░░░|░░░|░░░| *
 * |░░░|░░░|░░░|░░░|░░░|░░░|░░░| *
 * |░░░|░░░|░░░|░░░|░░░|░░░|░░░| *
 * |░░░|░░░|░░░|░░░|░░░|░░░|░░░| *
 * |░░░|░░░|░░░|░░░|░░░|░░░|░░░| *
 * |░░░|░░░|░░░|░░░|░░░|░░░|░░░| *
 * |                           | *
 *********************************/

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "src/Generator.sol";
import "src/interfaces/IConnectors.sol";
import "src/lib/Base64.sol";

/// @notice Just a friendly on-chain game of Connect Four
contract Connectors is IConnectors, ERC721, ERC721Holder, Ownable {
    using Strings for uint8;
    using Strings for uint160;
    using Strings for uint256;
    /// @dev Interface identifier for royalty standard
    bytes4 constant _INTERFACE_ID_ERC2981 = 0x2a55205a;
    /// @notice Maximum supply of NFTs
    uint16 public constant MAX_SUPPLY = 420;
    /// @notice Address of Generator contract
    address public immutable generator;
    /// @notice Current supply of NFTs
    uint16 public totalSupply;
    /// @notice Ether amount required to play (per player)
    uint64 public fee = 0.0420 ether;
    /// @notice Mapping of game ID to game info
    mapping(uint256 => Game) public games;

    /// @dev Deploys Generator contract
    constructor() payable ERC721("Connectors", "C4") {
        generator = address(new Generator());
    }

    /// @notice Creates new game and mints empty game board
    /// @dev Game can only become active once opponent calls begin
    /// @param _opponent Address of opponent
    function challenge(address _opponent) external payable {
        // Reverts if caller is also the opponent
        if (msg.sender == _opponent) revert InvalidMatchup();
        // Reverts if max supply has been minted
        if (totalSupply == MAX_SUPPLY) revert InsufficientSupply();
        // Reverts if payment amount is incorrect
        if (msg.value != fee) revert InvalidPayment();

        // Initializes game info
        Game storage game = games[++totalSupply];
        game.player1 = msg.sender;
        game.player2 = _opponent;
        game.turn = PLAYER_2;

        // Mints new board to this contract
        _safeMint(address(this), totalSupply);

        // Emits event for challenging opponent
        emit Challenge(totalSupply, msg.sender, _opponent);
    }

    /// @notice Activates new game and executes first move on board
    /// @dev Column numbers are zero-indexed
    /// @param _gameId ID of the game
    /// @param _col Value of column placement on board (0-6)
    function begin(uint256 _gameId, uint8 _col) external payable {
        // Reverts if game does not exist
        if (_gameId == 0 || _gameId > totalSupply) revert InvalidGame();
        Game storage game = games[_gameId];
        uint8 playerId = _getPlayerId(game, msg.sender);
        // Reverts if game state is not Inactive
        if (game.state != State.INACTIVE) revert InvalidState();
        // Reverts if caller is not authorized to execute move
        if (game.turn != playerId) revert NotAuthorized();
        // Reverts if payment amount is incorrect
        if (msg.value != fee) revert InvalidPayment();

        // Sets game state to Active
        game.state = State.ACTIVE;

        // Emits event for beginning a new game
        emit Begin(_gameId, msg.sender, game.state);

        // Executes first move on board
        move(_gameId, _col);
    }

    /// @notice Executes next placement on active board
    /// @dev Column numbers are zero-indexed
    /// @param _gameId ID of the game
    /// @param _col Value of column placement on board (0-6)
    function move(uint256 _gameId, uint8 _col) public returns (bool result) {
        // Reverts if game does not exist
        if (_gameId == 0 || _gameId > totalSupply) revert InvalidGame();
        Game storage game = games[_gameId];
        uint8[COL][ROW] storage board = game.board;
        uint8 playerId = _getPlayerId(game, msg.sender);
        uint8 row = getNextRow(board, _col);
        // Reverts if game state is not Active
        if (game.state != State.ACTIVE) revert InvalidState();
        // Reverts if caller is not authorized to execute move
        if (game.turn != playerId) revert NotAuthorized();
        // Reverts if column is fully occupied
        if (board[row][_col] != 0) revert InvalidMove();

        // Increments total number of moves made
        ++game.moves;
        uint8 moves = game.moves;

        // Records player move
        game.row = row;
        game.col = _col;
        board[row][_col] = playerId;

        // Emits event for creating new move on board
        emit Move(_gameId, msg.sender, moves, row, _col);

        // Only checks board for win if minimum number of moves have been made
        if (moves > 6) result = _checkBoard(playerId, row, _col, board);

        // Checks if game has been won
        if (result) {
            _success(_gameId, game);
        } else {
            // Updates player turn based on caller
            game.turn = (msg.sender == game.player1) ? PLAYER_2 : PLAYER_1;

            // Checks if number of moves has reached maximum moves
            if (moves == ROW * COL) _draw(_gameId, game);
        }
    }

    /// @notice Sets fee amount required to play game
    /// @param _fee Amount in ether
    function setFee(uint64 _fee) external payable onlyOwner {
        fee = _fee;
    }

    /// @notice Withdraws balance from this contract
    /// @param _to Target address for transferring balance to
    function withdraw(address payable _to) external payable onlyOwner {
        (bool success, ) = _to.call{value: address(this).balance}("");
        if (!success) revert TransferFailed();
    }

    /// @notice Gets the entire column for a given row
    /// @param _gameId ID of the game
    /// @param _row Value of row number on board
    function getColumn(uint256 _gameId, uint8 _row) external view returns (uint8[COL] memory) {
        Game memory game = games[_gameId];
        return game.board[_row];
    }

    /// @notice Returns royalty information for secondary sales
    function royaltyInfo(
        uint256 /* _tokenId */,
        uint256 _salePrice
    ) external view returns (address receiver, uint256 royalty) {
        receiver = owner();
        royalty = (_salePrice * 1000) / 10000;
    }

    /// @notice Supports interface for ERC-165 implementation
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return interfaceId == _INTERFACE_ID_ERC2981 || super.supportsInterface(interfaceId); // ERC165 Interface ID for ERC2981
    }

    /// @notice Gets metadata of token in JSON format
    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        _requireMinted(_tokenId);

        Game memory game = games[_tokenId];
        uint8[COL][ROW] memory board = game.board;
        address player1 = game.player1;
        address player2 = game.player2;
        string memory name = (game.state == State.SUCCESS)
            ? string.concat("Connector #", _tokenId.toString())
            : string.concat("Game #", _tokenId.toString());
        string memory description = "Just a friendly on-chain game of Connect Four. Your move anon.";
        string memory gameTraits = _generateGameTraits(game);
        string memory playerTraits = _generatePlayerTraits(_tokenId, player1, player2);
        string memory image = Base64.encode(
            abi.encodePacked(IGenerator(generator).generateSVG(_tokenId, game.row, game.col, board))
        );

        return
            string.concat(
                "data:application/json;base64,",
                Base64.encode(
                    abi.encodePacked(
                        string.concat(
                            '{"name":"',
                                name,
                            '",',
                            '"description":"',
                                description,
                            '",',
                            '"image": "data:image/svg+xml;base64,',
                                image,
                            '",',
                            '"attributes": [',
                                playerTraits,
                                gameTraits,
                            "]}"
                        )
                    )
                )
            );
    }

    /// @notice Gets the next row value for the given column
    /// @param _board Current state of the game board
    /// @param _col Value of the column placement
    function getNextRow(uint8[COL][ROW] memory _board, uint8 _col) public pure returns (uint8) {
        unchecked {
            for (uint8 row; row < ROW; ++row) {
                if (_board[row][_col] == 0)  {
                    return row;
                }
            }
        }

        return 0;
    }

    /// @dev Sets game as success and transfers connector to winner
    function _success(uint256 _gameId, Game storage _game) internal {
        _game.state = State.SUCCESS;
        emit Result(_gameId, msg.sender, _game.state, _game.board);

        _burn(_gameId);
        _safeMint(msg.sender, _gameId);
    }

    /// @dev Sets game as draw
    function _draw(uint256 _gameId, Game storage _game) internal {
        _game.turn = 0;
        _game.state = State.DRAW;

        emit Result(_gameId, address(0), _game.state, _game.board);
    }

    /// @dev Checks if move wins game in any of the four directions
    function _checkBoard(
        uint8 _playerId,
        uint8 _row,
        uint8 _col,
        uint8[COL][ROW] storage _board
    ) internal view returns (bool result) {
        result = _checkHorizontal(_playerId, _row, _col, _board);
        if (!result) result = _checkVertical(_playerId, _row, _col, _board);
        if (!result) result = _checkAscending(_playerId, _row, _col, _board);
        if (!result) result = _checkDescending(_playerId, _row, _col, _board);
    }

    /// @dev Checks horizontal placement of move on board
    function _checkHorizontal(
        uint8 _playerId,
        uint8 _row,
        uint8 _col,
        uint8[COL][ROW] storage _board
    ) internal view returns (bool result) {
        uint8 i;
        uint8 counter;
        unchecked {
            for (i = 1; i < 4; ++i) {
                if (_col == 0) break;
                if (_board[_row][_col - i] == _playerId) {
                    ++counter;
                } else {
                    break;
                }
                if (_col - i == 0) break;
            }

            for (i = 1; i < 4; ++i) {
                if (_col + i == COL) break;
                if (_board[_row][_col + i] == _playerId) {
                    ++counter;
                } else {
                    break;
                }
            }
        }

        if (counter > 2) result = true;
    }

    /// @dev Checks vertical placement of move on board
    function _checkVertical(
        uint8 _playerId,
        uint8 _row,
        uint8 _col,
        uint8[COL][ROW] storage _board
    ) internal view returns (bool result) {
        uint8 i;
        uint8 counter;
        unchecked {
            for (i = 1; i < 4; ++i) {
                if (_row == 0) break;
                if (_board[_row - i][_col] == _playerId) {
                    ++counter;
                } else {
                    break;
                }
                if (_row - i == 0) break;
            }

            for (i = 1; i < 4; ++i) {
                if (_row + i == ROW) break;
                if (_board[_row + i][_col] == _playerId) {
                    ++counter;
                } else {
                    break;
                }
            }
        }

        if (counter > 2) result = true;
    }

    /// @dev Checks diagonal placement of move ascending from left to right
    function _checkAscending(
        uint8 _playerId,
        uint8 _row,
        uint8 _col,
        uint8[COL][ROW] storage _board
    ) internal view returns (bool result) {
        uint8 i;
        uint8 counter;
        unchecked {
            for (i = 1; i < 4; ++i) {
                if (_row == 0 || _col == 0) break;
                if (_board[_row - i][_col - i] == _playerId) {
                    ++counter;
                } else {
                    break;
                }
                if (_row - i == 0 || _col - i == 0) break;
            }

            for (i = 1; i < 4; ++i) {
                if (_row + i == ROW || _col + i == COL) break;
                if (_board[_row + i][_col + i] == _playerId) {
                    ++counter;
                } else {
                    break;
                }
            }
        }

        if (counter > 2) result = true;
    }

    /// @dev Checks diagonal placement of move descending from left to right
    function _checkDescending(
        uint8 _playerId,
        uint8 _row,
        uint8 _col,
        uint8[COL][ROW] storage _board
    ) internal view returns (bool result) {
        uint8 i;
        uint8 counter;
        unchecked {
            for (i = 1; i < 4; ++i) {
                if (_row + i == ROW || _col == 0) break;
                if (_board[_row + i][_col - i] == _playerId) {
                    ++counter;
                } else {
                    break;
                }
                if (_col - i == 0) break;
            }

            for (i = 1; i < 4; ++i) {
                if (_row == 0 || _col + i == COL) break;
                if (_board[_row - i][_col + i] == _playerId) {
                    ++counter;
                } else {
                    break;
                }
                if (_row - i == 0) break;
            }
        }

        if (counter > 2) result = true;
    }

    /// @dev Generates JSON formatted data of game traits
    function _generateGameTraits(Game memory _game) internal view returns (string memory) {
        string memory moves = _game.moves.toString();
        string memory status = IGenerator(generator).getStatus(_game.state);
        string memory label = (_game.state == State.SUCCESS) ? "Winner" : "Turn";
        string memory turn = uint160(address(0)).toHexString(20);
        if (_game.turn == PLAYER_1) {
            turn = uint160(_game.player1).toHexString(20);
        } else if (_game.turn == PLAYER_2) {
            turn = uint160(_game.player2).toHexString(20);
        }
        string memory latest = string.concat(
            "(",
            _game.row.toString(),
            ", ",
            _game.col.toString(),
            ")"
        );

        return
            string(
                abi.encodePacked(
                    '{"trait_type":"Latest", "value":"',
                        latest,
                    '"},',
                    '{"trait_type":"Moves", "value":"',
                        moves,
                    '"},',
                    '{"trait_type":"Status", "value":"',
                        status,
                    '"},',
                    '{"trait_type":"',
                        label,
                    '", "value":"',
                        turn,
                    '"}'
                )
            );
    }

    /// @dev Generates JSON formatted data of player traits
    function _generatePlayerTraits(
        uint256 _gameId,
        address _player1,
        address _player2
    ) internal view returns (string memory) {
        string memory player1 = uint160(_player1).toHexString(20);
        string memory player2 = uint160(_player2).toHexString(20);
        (string memory checker1, string memory checker2) = IGenerator(generator).getCheckers(_gameId);

        return
            string(
                abi.encodePacked(
                    '{"trait_type":"',
                        checker1,
                    '", "value":"',
                        player1,
                    '"},',
                    '{"trait_type":"',
                        checker2,
                    '", "value":"',
                        player2,
                    '"},'
                )
            );
    }

    /// @dev Gets player ID of caller
    function _getPlayerId(
        Game storage _game,
        address _player
    ) internal view returns (uint8 playerId) {
        if (_player == _game.player1) {
            playerId = PLAYER_1;
        } else if (_player == _game.player2) {
            playerId = PLAYER_2;
        }
    }
}
