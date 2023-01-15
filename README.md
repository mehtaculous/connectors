# Connectors

Just a friendly on-chain game of Connect Four.

<img src="images/board.svg">


### `Challenge`

> Creates a new game and mints a new game board NFT

- Challenge an **EOA** to a game of **Connect Four** by paying a small fee.
- A new ERC-721 game board NFT gets minted to the `Connectors` contract.
- Follow along by viewing the visual status of the game board on any marketplace that supports on-chain art, such as [OpenSea](https://opensea.io/).

### `Begin`

> Activates a new game and executes the first move on the game board

- Only the opponent of an inactive game can begin it by paying the same fee.
- The new game becomes active as the opponent executes the first move on the board in the same transaction.
- Each board consists of **6** Rows and **7** Columns that are *zero-indexed*.
- The `row` values range from **0 - 5**.
- The `col` values range from **0 - 6**.
- Row values are only valid if the cell below it has already been filled.

### `Move`

> Executes next placement on an active board

- Each game has a maximum number of **42** possible moves.
- Every move dynamically updates the metadata and SVG image of the NFT on-chain.
- Players can win by getting **4** in a row *horizontally*, *vertically* or *diagonally*.
- In the event of a successful board (`Success`), the winning player is transferred the game board NFT.
- In the event of a tie board (`Draw`), the game board NFT will remain with the `Connectors` contract.
- The total supply of game board NFTs that are transferred to winning players may never exceed **100**.


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
| 4334477                                | 21765           |        |        |        |         |
| Function Name                          | min             | avg    | median | max    | # calls |
| begin                                  | 524             | 39335  | 49621  | 49621  | 19      |
| challenge                              | 447             | 189971 | 227825 | 227825 | 24      |
| games                                  | 1208            | 1858   | 1208   | 9208   | 123     |
| getRow                                 | 10642           | 27308  | 10642  | 94642  | 99      |
| move                                   | 548             | 28921  | 27919  | 98808  | 81      |
| setFee                                 | 2573            | 19754  | 24575  | 24575  | 5       |
| tokenURI                               | 171945          | 269335 | 221383 | 558376 | 6       |
| withdraw                               | 7498            | 7498   | 7498   | 7498   | 1       |
