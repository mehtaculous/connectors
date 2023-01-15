# Connectors

Just a friendly on-chain game of Connect Four.

<img src="images/board.svg">


### `Challenge`

> Creates a new game and mints a new game board NFT

- Challenging an opponent mints a new ERC-721 token of the game board.
- Follow along for a visual status of the game board by visiting any [marketplace](https://opensea.io/) that supports on-chain art.

### `Begin`

> Activates a new game and executes the first move on the game board

- The opponent must first begin the game before moves can be made.
- Each board consists of **6** Rows and **7** Columns that are *zero-indexed*.
- The `row` values range from **0 - 5**.
- The `col` values range from **0 - 6**.
- Row values are only valid if the cell below it has already been occupied.

### `Move`

> Executes next placement on an active board

- There is a maximum number of **42** possible moves per game.
- Every move dynamically updates the metadata and SVG image of the NFT on-chain and in real-time.
- Players can win by getting **4** in a row *horizontally*, *vertically* or *diagonally*.
- When a player wins, they are transferred the winning game board NFT.
- If the game ends in a draw, no player will receive the NFT.
- The total supply of NFTs that are transferred to winning players is capped at **100**.


### Mainnet

| Name            | Address                                                                                                                       |
| --------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `Connectors.sol`    | [](https://etherscan.io/address/) |
| `Metadata.sol`      | [](https://etherscan.io/address/) |


### Goerli

| Name            | Address                                                                                                                       |
| --------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `Connectors.sol`    | [](https://goerli.etherscan.io/address/) |
| `Metadata.sol`      | [](https://goerli.etherscan.io/address/) |


### Gas Report

| Connectors.sol                         |                 |        |        |        |         |
|----------------------------------------|-----------------|--------|--------|--------|---------|
| Deployment Cost                        | Deployment Size |        |        |        |         |
| 4569809                                | 22940           |        |        |        |         |
| Function Name                          | min             | avg    | median | max    | # calls |
| begin                                  | 524             | 44755  | 49854  | 69754  | 19      |
| challenge                              | 469             | 189993 | 227847 | 227847 | 24      |
| games                                  | 1471            | 2934   | 1471   | 13471  | 123     |
| getRow                                 | 10905           | 27571  | 10905  | 94905  | 99      |
| move                                   | 548             | 34826  | 29098  | 114007 | 81      |
| setFee                                 | 2508            | 19689  | 24510  | 24510  | 5       |
| tokenURI                               | 181846          | 254915 | 216926 | 568236 | 8       |
| withdraw                               | 7520            | 7520   | 7520   | 7520   | 1       |
