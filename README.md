# Connectors

Just a friendly on-chain game of Connect Four. Your move anon.

<img src="images/board.svg">


### `Challenge`

> Creates a new game and mints an empty game board

- Challenge anyone to a game of Connect Four.
- Both players must pay a fee of **.0420** eth to play.
- Each new game mints an ERC-721 token of an empty game board.
- Follow along with the game on any [marketplace](https://testnets.opensea.io/collection/connectors-v3) that supports on-chain art.

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
- When a player wins, they are transferred the winning game board.
- If the game ends in a draw, the NFT will remain with the smart contract.
- Total supply is capped at **420**.


### Mainnet Contracts

| Name                | Address                                                                                                                      |
| ---------------     | ---------------------------------------------------------------------------------------------------------------------------- |
| `Connectors.sol`    | [](https://etherscan.io/address/) |
| `Metadata.sol`      | [](https://etherscan.io/address/) |


### Goerli Contracts

| Name                | Address                                                                                                                      |
| ---------------     | ---------------------------------------------------------------------------------------------------------------------------- |
| `Connectors.sol`    | [0x62455e0E1Cf34a88b64d15dAd96137e73388C266](https://goerli.etherscan.io/address/0x62455e0E1Cf34a88b64d15dAd96137e73388C266) |
| `Metadata.sol`      | [0x617c35f2ecd44C7Ac12F745dC9081C8a379102fA](https://goerli.etherscan.io/address/0x617c35f2ecd44C7Ac12F745dC9081C8a379102fA) |


### Gas Report

| Connectors.sol                         |                 |        |        |        |         |
|----------------------------------------|-----------------|--------|--------|--------|---------|
| Deployment Cost                        | Deployment Size |        |        |        |         |
| 4030759                                | 20224           |        |        |        |         |
| Function Name                          | min             | avg    | median | max    | # calls |
| begin                                  | 636             | 30847  | 31156  | 31156  | 439     |
| challenge                              | 398             | 85153  | 94968  | 101768 | 863     |
| getRow                                 | 14793           | 16205  | 14793  | 26793  | 3041    |
| move                                   | 707             | 22043  | 26253  | 76209  | 2603    |
| setFee                                 | 2619            | 4108   | 4108   | 5598   | 2       |
| tokenURI                               | 266066          | 278505 | 271783 | 375435 | 25      |
| withdraw                               | 7520            | 7520   | 7520   | 7520   | 1       |
