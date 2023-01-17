# Connectors

Just a friendly on-chain game of Connect Four. Your move anon.

<img src="images/board.svg">


### `Challenge`

> Creates a new game and mints an empty game board

- Challenge anyone to a game of Connect Four.
- Both players must pay a fee of **.0420** eth to play.
- Each new game mints an ERC-721 token of an empty game board.
- Follow along with the game on any [marketplace](https://testnets.opensea.io/collection/connectors-g7kowh40yu) that supports on-chain art.

### `Begin`

> Activates a new game and executes the first move on the game board

- Opponents must first begin the game before any moves can be made.
- Each board consists of **6** Rows and **7** Columns that are *zero-indexed*.
- The `row` values range from **0 - 5**.
- The `col` values range from **0 - 6**.

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
| `Connectors.sol`    | [0x0461736eEDd0A9f174340A0F8fD79A5fC1C25F9D](https://goerli.etherscan.io/address/0x0461736eEDd0A9f174340A0F8fD79A5fC1C25F9D) |
| `Metadata.sol`      | [0x024Bb80aAEBb550655fD9B3811D0c3A8b83dCeD8](https://goerli.etherscan.io/address/0x024Bb80aAEBb550655fD9B3811D0c3A8b83dCeD8) |


### Gas Report

| Connectors.sol                         |                 |        |        |         |         |
|----------------------------------------|-----------------|--------|--------|---------|---------|
| Deployment Cost                        | Deployment Size |        |        |         |         |
| 4157731                                | 20858           |        |        |         |         |
| Function Name                          | min             | avg    | median | max     | # calls |
| begin                                  | 597             | 53006  | 53677  | 53677   | 438     |
| challenge                              | 442             | 85139  | 95012  | 101812  | 868     |
| getColumn                              | 14570           | 14577  | 14570  | 26570   | 3045    |
| move                                   | 624             | 34029  | 38576  | 85847   | 2607    |
| setFee                                 | 2554            | 4043   | 4043   | 5533    | 2       |
| tokenURI                               | 550614          | 626845 | 571963 | 1368793 | 27      |
| withdraw                               | 7520            | 7520   | 7520   | 7520    | 1       |
