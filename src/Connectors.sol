// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

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
import "src/Metadata.sol";
import "src/interfaces/IConnectors.sol";

/// @title Connectors
/// @author swa.eth
/// @notice Just a friendly on-chain game of Connect Four
contract Connectors is IConnectors, ERC721, ERC721Holder, Ownable {
    using Strings for uint8;
    using Strings for uint160;
    using Strings for uint256;
    /// @dev Interface identifier for royalty standard
    bytes4 constant _INTERFACE_ID_ERC2981 = 0x2a55205a;
    /// @notice Maximum supply of winning game boards
    uint8 public constant MAX_SUPPLY = 100;
    /// @notice Current supply of winning game boards
    uint8 public totalSupply;
    /// @notice Address of Metadata contract
    address public immutable metadata;
    /// @notice Current game ID
    uint256 public currentId;
    /// @notice Ether amount required to play per player
    uint256 public fee = 0.0420 ether;
    /// @notice Mapping of game ID to game info
    mapping(uint256 => Game) public games;

    /// @dev Deploys new Metadata contract
    constructor() payable ERC721("Connectors", "C4") {
        metadata = address(new Metadata());
    }

    /// @notice Creates new game and mints new game board
    /// @dev Game can only become active once opponent calls begin
    /// @param _opponent Address of opponent
    function challenge(address _opponent) external payable {
        // Reverts if caller or opponent is a smart contract
        if (msg.sender != tx.origin || _isContract(_opponent)) revert InvalidPlayer();
        // Reverts if caller is also the opponent
        if (msg.sender == _opponent) revert InvalidMatchup();
        // Reverts if payment amount is incorrect
        if (msg.value != fee) revert InvalidPayment();

        // Initializes game info
        Game storage game = games[++currentId];
        game.player1 = msg.sender;
        game.player2 = _opponent;
        game.turn = PLAYER_2;

        // Registers game on metadata contract
        IMetadata(metadata).register(currentId);

        // Mints new board to this contract
        _safeMint(address(this), currentId);

        // Emits event for challenging opponent
        emit Challenge(currentId, msg.sender, _opponent);
    }

    /// @notice Activates new game and executes first move on board
    /// @dev Row and Column numbers are zero-indexed
    /// @param _gameId ID of the game
    /// @param _row Value of row placement on board (0-5)
    /// @param _col Value of column placement on board (0-6)
    function begin(uint256 _gameId, uint8 _row, uint8 _col) external payable {
        // Reverts if game does not exist
        if (_gameId == 0 || _gameId > currentId) revert InvalidGame();
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
        move(_gameId, _row, _col);
    }

    /// @notice Executes next placement on active board
    /// @dev Row and Column numbers are zero-indexed
    /// @param _gameId ID of the game
    /// @param _row Value of row placement on board (0-5)
    /// @param _col Value of column placement on board (0-6)
    function move(uint256 _gameId, uint8 _row, uint8 _col) public returns (Strat result) {
        // Reverts if game does not exist
        if (_gameId == 0 || _gameId > currentId) revert InvalidGame();
        Game storage game = games[_gameId];
        uint8[COL][ROW] storage board = game.board;
        uint8 playerId = _getPlayerId(game, msg.sender);
        // Reverts if game state is not Active
        if (game.state != State.ACTIVE) revert InvalidState();
        // Reverts if caller is not authorized to execute move
        if (game.turn != playerId) revert NotAuthorized();
        // Reverts if cell is occupied or row placement is not valid
        if (board[_row][_col] != 0 || (_row > 0 && board[_row - 1][_col] == 0))
            revert InvalidMove();

        // Increments total number of moves made
        ++game.moves;
        uint8 moves = game.moves;

        // Records player move
        game.row = _row;
        game.col = _col;
        board[_row][_col] = playerId;

        // Emits event for creating new move on board
        emit Move(_gameId, msg.sender, moves, _row, _col);

        // Checks if minimum number of moves for a possible win have been made
        if (moves > 6) {
            // Checks horizontal placement of move
            result = _checkHorizontal(playerId, _row, _col, board);
            // Checks vertical placement of move
            if (result == Strat.NONE) result = _checkVertical(playerId, _row, _col, board);
            // Checks diagonal placement of move ascending from left to right
            if (result == Strat.NONE) result = _checkAscending(playerId, _row, _col, board);
            // Checks diagonal placement of move descending from left to right
            if (result == Strat.NONE) result = _checkDescending(playerId, _row, _col, board);
        }

        // Checks if result is any of the winning strategies
        if (result != Strat.NONE) {
            // Updates state of game to successful
            game.strat = result;
            game.state = State.SUCCESS;
            // Emits event for finishing game with a winner
            emit Result(_gameId, msg.sender, game.state, game.strat, board);

            // Checks if number of winning games is less than maximum
            if (totalSupply < MAX_SUPPLY) {
                // Burns game board
                _burn(_gameId);
                // Increments total supply
                ++totalSupply;
                // Mints connector to caller
                _safeMint(msg.sender, _gameId);
            }
        } else {
            // Updates player turn based on caller
            game.turn = (msg.sender == game.player1) ? PLAYER_2 : PLAYER_1;

            // Checks if number of moves has reached maximum moves
            if (moves == ROW * COL) {
                // Updates state of game to draw
                game.turn = 0;
                game.state = State.DRAW;
                // Emits event for finishing game with a draw
                emit Result(_gameId, address(0), game.state, game.strat, board);
            }
        }
    }

    /// @notice Sets fee amount required to play game
    /// @param _fee Amount in ether
    function setFee(uint256 _fee) external payable onlyOwner {
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
    function getRow(uint256 _gameId, uint8 _row) external view returns (uint8[COL] memory) {
        Game memory game = games[_gameId];
        return game.board[_row];
    }

    /// @notice Returns royalty information for secondary sales
    function royaltyInfo(
        uint256 /* _id */,
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
        string memory title = (game.state == State.SUCCESS) ? "Connector #" : "Board #";
        string memory name = string.concat(title, _tokenId.toString());
        string memory description = "Just a friendly on-chain game of Connect Four. Your move anon.";
        string memory playerTraits = generatePlayerTraits(_tokenId, player1, player2);
        string memory gameTraits = generateGameTraits(game);
        string memory image = IMetadata(metadata).generateSVG(_tokenId, game.row, game.col, board);

        return
            string(
                abi.encodePacked(
                    "data:application/json;utf8,",
                    '{"name":"',
                        name,
                    '",',
                    '"description":"',
                        description,
                    '",',
                    '"image": "data:image/svg+xml;utf8,',
                        image,
                    '",',
                    '"attributes": [',
                        playerTraits,
                        gameTraits,
                    "]}"
                )
            );
    }

    /// @dev Generates JSON formatted data of player traits
    /// @param _tokenId ID of the token
    /// @param _player1 Address of player1
    /// @param _player2 Address of player2
    /// return JSON data of player traits
    function generatePlayerTraits(
        uint256 _tokenId,
        address _player1,
        address _player2
    ) public view returns (string memory) {
        string memory player1 = uint160(_player1).toHexString(20);
        string memory player2 = uint160(_player2).toHexString(20);
        (string memory checker1, string memory checker2) = IMetadata(metadata).getChecker(_tokenId);

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

    /// @dev Generates JSON formatted data of game traits
    /// @param _game Game information
    /// return JSON data of game traits
    function generateGameTraits(Game memory _game) public view returns (string memory) {
        string memory moves = _game.moves.toString();
        string memory status = IMetadata(metadata).getStatus(_game.state);
        string memory turn = uint160(address(0)).toHexString(20);
        string memory label = (_game.state == State.SUCCESS) ? "Winner" : "Turn";
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

    /// @dev Checks horizontal placement of move on board
    function _checkHorizontal(
        uint8 _playerId,
        uint8 _row,
        uint8 _col,
        uint8[COL][ROW] storage _board
    ) internal view returns (Strat result) {
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

        if (counter > 2) result = Strat.HORIZONTAL;
    }

    /// @dev Checks vertical placement of move on board
    function _checkVertical(
        uint8 _playerId,
        uint8 _row,
        uint8 _col,
        uint8[COL][ROW] storage _board
    ) internal view returns (Strat result) {
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

        if (counter > 2) result = Strat.VERTICAL;
    }

    /// @dev Checks diagonal placement of move ascending from left to right
    function _checkAscending(
        uint8 _playerId,
        uint8 _row,
        uint8 _col,
        uint8[COL][ROW] storage _board
    ) internal view returns (Strat result) {
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

        if (counter > 2) result = Strat.ASCENDING;
    }

    /// @dev Checks diagonal placement of move descending from left to right
    function _checkDescending(
        uint8 _playerId,
        uint8 _row,
        uint8 _col,
        uint8[COL][ROW] storage _board
    ) internal view returns (Strat result) {
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

        if (counter > 2) result = Strat.DESCENDING;
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

    /// @dev Checks if given address is a smart contract
    function _isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
}
