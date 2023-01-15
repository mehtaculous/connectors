# Connectoooors

Just a friendly on-chain game of Connect Four. Your move anon.

<img src="images/board.svg">


### `Challenge`

> Creates a new game and mints a new token

- Challenging an opponent mints a new ERC-721 token of a fresh game board.
- Follow along for a visual status of the game by visiting any [marketplace](https://testnets.opensea.io/collection/connectors-v2) that supports on-chain art.

### `Begin`

> Activates a new game and executes the first move on the game board

- Opponents must first begin the game before any moves can be made.
- Each board consists of **6** Rows and **7** Columns that are *zero-indexed*.
- The `row` values range from **0 - 5**.
- The `col` values range from **0 - 6**.
- Row values are only valid if the cell below it has already been occupied.

### `Move`

> Executes next placement on an active board

- There is a maximum number of **42** moves per game.
- Every move dynamically updates the metadata and SVG image of the NFT on-chain and in real time.
- Players can win by getting **4** in a row *horizontally*, *vertically* or *diagonally*.
- When a player wins, they are transferred the winning game board (total supply is capped at **100**).
- If the game ends in a draw (or if maximum supply has been reached), no player will receive the NFT.


### Mainnet

| Name                | Address                                                                                                                      |
| ---------------     | ---------------------------------------------------------------------------------------------------------------------------- |
| `Connectoooors.sol` | [](https://etherscan.io/address/) |
| `Metadata.sol`      | [](https://etherscan.io/address/) |


### Goerli

| Name                | Address                                                                                                                      |
| ---------------     | ---------------------------------------------------------------------------------------------------------------------------- |
| `Connectoooors.sol` | [0x8797681E553197442accabBC85Dc30A2eE4b6f87](https://goerli.etherscan.io/address/0x8797681E553197442accabBC85Dc30A2eE4b6f87) |
| `Metadata.sol`      | [0xD6237A39Dd8D3c68fC9178F445a2Ee84936356bb](https://goerli.etherscan.io/address/0xD6237A39Dd8D3c68fC9178F445a2Ee84936356bb) |


### Gas Report

| src/Connectoooors.sol                        |                 |        |        |        |         |
|----------------------------------------------|-----------------|--------|--------|--------|---------|
| Deployment Cost                              | Deployment Size |        |        |        |         |
| 4575096                                      | 22877           |        |        |        |         |
| Function Name                                | min             | avg    | median | max    | # calls |
| begin                                        | 524             | 46006  | 49851  | 67751  | 19      |
| challenge                                    | 469             | 190142 | 227825 | 227825 | 24      |
| games                                        | 1449            | 2912   | 1449   | 13449  | 123     |
| getRow                                       | 10905           | 18399  | 10905  | 94905  | 99      |
| move                                         | 548             | 34824  | 29095  | 114004 | 81      |
| setFee                                       | 2508            | 5076   | 5310   | 7410   | 3       |
| toggleAnimate                                | 2474            | 6573   | 6573   | 10673  | 2       |
| tokenURI                                     | 251882          | 311806 | 330785 | 567405 | 29      |
| withdraw                                     | 9498            | 9498   | 9498   | 9498   | 1       |
