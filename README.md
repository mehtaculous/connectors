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

| Connectoooors.sol                            |                 |        |        |        |         |
|----------------------------------------------|-----------------|--------|--------|--------|---------|
| Deployment Cost                              | Deployment Size |        |        |        |         |
| 4772329                                      | 23862           |        |        |        |         |
| Function Name                                | min             | avg    | median | max    | # calls |
| begin                                        | 679             | 24023  | 29241  | 31141  | 19      |
| challenge                                    | 469             | 171722 | 205722 | 205722 | 24      |
| games                                        | 1117            | 1279   | 1117   | 5117   | 123     |
| getRow                                       | 14793           | 15742  | 14793  | 26793  | 99      |
| move                                         | 638             | 15995  | 10347  | 95466  | 81      |
| setFee                                       | 2508            | 4959   | 4959   | 7410   | 2       |
| toggleAnimate                                | 2474            | 6573   | 6573   | 10673  | 2       |
| tokenURI                                     | 264366          | 290814 | 270152 | 568648 | 29      |
| withdraw                                     | 9498            | 9498   | 9498   | 9498   | 1       |
