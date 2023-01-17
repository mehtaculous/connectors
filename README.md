# Connectors

Just a friendly on-chain game of Connect Four. Your move anon.

<img src="images/board.svg">


### `Challenge`

> Creates a new game and mints an empty game board

- Challenge anyone to a game of Connect Four.
- Both players must pay a fee of **.0420** eth to play.
- Each new game mints an ERC-721 token of an empty game board.
- Follow along with the game on any [marketplace](https://testnets.opensea.io/collection/connectors-v4) that supports on-chain art.

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
| `Connectors.sol`    | [0x51f89AA01259C08D7334dFF461C26F856b3a2858](https://goerli.etherscan.io/address/0x51f89AA01259C08D7334dFF461C26F856b3a2858) |
| `Metadata.sol`      | [0xcC37eb7A9aC72615eCcf5120f2cE6d7aBB38ab5c](https://goerli.etherscan.io/address/0xcC37eb7A9aC72615eCcf5120f2cE6d7aBB38ab5c) |


### Gas Report

| Connectors.sol                         |                 |        |        |        |         |
|----------------------------------------|-----------------|--------|--------|--------|---------|
| Deployment Cost                        | Deployment Size |        |        |        |         |
| 4003944                                | 20090           |        |        |        |         |
| Function Name                          | min             | avg    | median | max    | # calls |
| begin                                  | 636             | 30789  | 31097  | 31097  | 439     |
| challenge                              | 398             | 85114  | 94968  | 101768 | 869     |
| getRow                                 | 14591           | 16002  | 14591  | 26591  | 3042    |
| move                                   | 707             | 21805  | 26114  | 75476  | 2603    |
| setFee                                 | 2619            | 4108   | 4108   | 5598   | 2       |
| tokenURI                               | 265160          | 295998 | 270877 | 570952 | 29      |
| withdraw                               | 7520            | 7520   | 7520   | 7520   | 1       |
