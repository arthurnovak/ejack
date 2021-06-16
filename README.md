# ejack

An Elixir GenServer that allows players to connect and play a game of blackjack.

ejack implements simple interface for playing the game in `Ejack` module.

For each player ejack spawns new process and tracks its progress in GenServer state.

ejack also tracks player's score and stores results in ETS table.
