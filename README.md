# Connectors

Just a friendly on-chain game of Connect Four. Your move anon.

<img src="images/board.svg">


### `Challenge`

> Creates a new game and mints an empty game board

- Challenge anyone to a game of Connect Four.
- Both players are required to pay a fee of **0** ETH to play.
- Each new game mints an ERC-721 token of an empty game board.
- Follow along with the game on any [marketplace](https://opensea.io/collection/connectors) that supports on-chain art.

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

| Name                | Address                                                                                                               |
| ---------------     | --------------------------------------------------------------------------------------------------------------------- |
| `Connectors.sol`    | [0x2CCa24975eb9A8F7B42c07C965133ddabc742610](https://etherscan.io/address/0x2CCa24975eb9A8F7B42c07C965133ddabc742610) |
| `Generator.sol`     | [0xbA3ec062961e011050e2cBA16ab2A00feE04E786](https://etherscan.io/address/0xbA3ec062961e011050e2cBA16ab2A00feE04E786) |


### Goerli Contracts

| Name                | Address                                                                                                                      |
| ---------------     | ---------------------------------------------------------------------------------------------------------------------------- |
| `Connectors.sol`    | [0x0461736eEDd0A9f174340A0F8fD79A5fC1C25F9D](https://goerli.etherscan.io/address/0x0461736eEDd0A9f174340A0F8fD79A5fC1C25F9D) |
| `Generator.sol`     | [0x024Bb80aAEBb550655fD9B3811D0c3A8b83dCeD8](https://goerli.etherscan.io/address/0x024Bb80aAEBb550655fD9B3811D0c3A8b83dCeD8) |


### Gas Report

| Connectors.sol                         |                 |        |        |         |         |
|----------------------------------------|-----------------|--------|--------|---------|---------|
| Deployment Cost                        | Deployment Size |        |        |         |         |
| 4156331                                | 20851           |        |        |         |         |
| Function Name                          | min             | avg    | median | max     | # calls |
| begin                                  | 575             | 52987  | 53658  | 53658   | 438     |
| challenge                              | 420             | 85117  | 94990  | 101790  | 868     |
| getColumn                              | 14570           | 14577  | 14570  | 26570   | 3045    |
| move                                   | 624             | 33963  | 38502  | 85664   | 2607    |
| setFee                                 | 2619            | 4108   | 4108   | 5598    | 2       |
| tokenURI                               | 550614          | 628149 | 579508 | 1368793 | 27      |
| withdraw                               | 7498            | 7498   | 7498   | 7498    | 1       |
