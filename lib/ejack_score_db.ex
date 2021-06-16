defmodule EjackScoreDb do
  @table :score_tbl

  @spec ensure_table_bootstrapped() :: atom
  def ensure_table_bootstrapped() do
    case :ets.whereis(@table) do
      :undefined -> new_table()
      _ref       -> @table
    end
  end

  @spec new_table() :: atom
  def new_table() do
    :ets.new(@table, [:set, :public, :named_table])
  end

  @spec add_game(charlist, pid) :: :ok
  def add_game(player, pid) do
    score = get_score(player)
    true  = :ets.insert(@table, {player, pid, score})
    :ok
  end

  @spec get_game(charlist) :: pid | :undefined
  def get_game(player) do
    case :ets.lookup(@table, player) do
      [{_, pid, _}] when pid !== :undefined -> pid
      _                                     -> :undefined
    end
  end

  @spec remove_game_add_score(charlist, integer) :: :ok
  def remove_game_add_score(player, new_score) do
    old_score = get_score(player)
    true = :ets.insert(@table, {player, :undefined, [new_score|old_score]})
    :ok
  end

  @spec get_score(charlist) :: [integer]
  def get_score(player) do
    case :ets.lookup(@table, player) do
      [{_, _, score}] -> score
      _               -> []
    end
  end
end
