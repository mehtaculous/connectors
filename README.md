# Connectors

Just a friendly on-chain game of Connect Four.

<svg width="200px" viewBox="0 0 700 600" xmlns="http://www.w3.org/2000/svg"><defs><pattern id="cell-pattern" patternUnits="userSpaceOnUse" width="100" height="100"><circle cx="50" cy="50" r="45" fill="black"></circle></pattern><mask id="cell-mask"><rect width="100" height="600" fill="white"></rect><rect width="100" height="600" fill="url(#cell-pattern)"></rect></mask></defs><svg x="0" y="0"><circle cx="50" cy="550" r="45" fill="#29335c"></circle><rect width="100" height="600" fill="#F3A712" mask="url(#cell-mask)"></rect></svg><svg x="100" y="0"><circle cx="50" cy="550" r="45" fill="#DB2B39"></circle><rect width="100" height="600" fill="#F3A712" mask="url(#cell-mask)"></rect></svg><svg x="200" y="0"><circle cx="50" cy="550" r="45" fill="#29335c"></circle><rect width="100" height="600" fill="#F3A712" mask="url(#cell-mask)"></rect></svg><svg x="300" y="0"><circle cx="50" cy="550" r="45" fill="#DB2B39"></circle><rect width="100" height="600" fill="#F3A712" mask="url(#cell-mask)"></rect></svg><svg x="400" y="0"><circle cx="50" cy="550" r="45" fill="#29335c"></circle><rect width="100" height="600" fill="#F3A712" mask="url(#cell-mask)"></rect></svg><svg x="500" y="0"><circle cx="50" cy="550" r="45" fill="#DB2B39"></circle><rect width="100" height="600" fill="#F3A712" mask="url(#cell-mask)"></rect></svg><svg x="600" y="0"><circle cx="50" cy="550" r="45" fill="#29335c"></circle><rect width="100" height="600" fill="#F3A712" mask="url(#cell-mask)"></rect></svg></svg>


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
- Every move dynamically updates the metadata of the NFT on-chain and the changes reflect immediately on the game board.
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
