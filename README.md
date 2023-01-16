# Connectors

Just a friendly on-chain game of Connect Four. Your move anon.

<img src="images/board.svg">


### `Challenge`

> Creates a new game and mints an empty game board

- Challenge any EOA to a game of Connect Four.
- Each new game mints an ERC-721 token of an empty game board.
- Follow along with the game on any [marketplace](https://testnets.opensea.io/collection/connectoooors-v4) that supports on-chain art.

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
- If the game ends in a draw (or if max supply has been reached), the NFT will remain with the smart contract.


### Mainnet

| Name                | Address                                                                                                                      |
| ---------------     | ---------------------------------------------------------------------------------------------------------------------------- |
| `Connectors.sol`    | [](https://etherscan.io/address/) |
| `Metadata.sol`      | [](https://etherscan.io/address/) |


### Goerli

| Name                | Address                                                                                                                      |
| ---------------     | ---------------------------------------------------------------------------------------------------------------------------- |
| `Connectors.sol`    | [0x62455e0E1Cf34a88b64d15dAd96137e73388C266](https://goerli.etherscan.io/address/0x62455e0E1Cf34a88b64d15dAd96137e73388C266) |
| `Metadata.sol`      | [0x617c35f2ecd44C7Ac12F745dC9081C8a379102fA](https://goerli.etherscan.io/address/0x617c35f2ecd44C7Ac12F745dC9081C8a379102fA) |


### Gas Report

| Connectors.sol                         |                 |        |        |        |         |
|----------------------------------------|-----------------|--------|--------|--------|---------|
| Deployment Cost                        | Deployment Size |        |        |        |         |
| 4727054                                | 23626           |        |        |        |         |
| Function Name                          | min             | avg    | median | max    | # calls |
| begin                                  | 657             | 24012  | 29219  | 31119  | 19      |
| challenge                              | 447             | 171719 | 205722 | 205722 | 24      |
| games                                  | 1117            | 1277   | 1117   | 5117   | 125     |
| getRow                                 | 14771           | 15701  | 14771  | 26771  | 101     |
| move                                   | 640             | 15883  | 10349  | 94070  | 83      |
| setFee                                 | 2573            | 5024   | 5024   | 7475   | 2       |
| tokenURI                               | 267183          | 295531 | 270400 | 570652 | 29      |
| withdraw                               | 9498            | 9498   | 9498   | 9498   | 1       |
