# Connectors

Just a friendly on-chain game of Connect Four. Your move anon.

<img src="images/board.svg">


### `Challenge`

> Challenges opponent to a new game and mints an empty game board

- Challenge anyone to a game of Connect Four.
- The fee to challenge an opponent is **.01** ETH.
- Each new game mints an ERC-721 token of an empty game board.
- Total supply of game boards is capped at **1000**.
- Follow along with the game on any [marketplace](https://opensea.io/collection/connectors) that supports on-chain art.


### `Move`

> Executes next placement on the game board

- Opponent makes the first move.
- Each board consists of **7** Columns that are *zero-indexed*.
- The `col` values range from **0 - 6**.
- There is a maximum number of **42** moves per game.
- Every move dynamically updates the metadata and SVG image of the NFT on-chain and in real time.
- Players can win by getting **4** in a row *horizontally*, *vertically* or *diagonally*.
- Winning player is transferred the final game board NFT.
- If the game ends in a draw, the NFT remains with the smart contract.


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
| 4080837                                | 20474           |        |        |         |         |
| Function Name                          | min             | avg    | median | max     | # calls |
| challenge                              | 440             | 85079  | 95038  | 101838  | 2023    |
| getColumn                              | 14570           | 14571  | 14570  | 26570   | 7104    |
| move                                   | 624             | 36188  | 38455  | 85491   | 7104    |
| setFee                                 | 2554            | 4043   | 4043   | 5533    | 2       |
| tokenURI                               | 576963          | 819771 | 723289 | 1368793 | 7       |
| withdraw                               | 7520            | 7520   | 7520   | 7520    | 1       |
