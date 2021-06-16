defmodule Ejack do

  @spec connect(charlist) :: :ok
  def connect(player) do
    EjackScoreDb.ensure_table_bootstrapped()
    case EjackScoreDb.get_game(player) do
      :undefined ->
        {:ok, pid} = EjackEngineSrv.start()
        EjackScoreDb.add_game(player, pid)
      _pid ->
        :ok
    end
  end

  @spec hit(charlist) :: {:ok, {charlist, charlist} | {:fail, integer}}
                       | {:error, any}
  def hit(player) do
    fun =
      fn (pid) ->
        {:ok, card, game_score} = EjackEngineSrv.hit(pid)
        cond do
          game_score > 21 ->
            EjackEngineSrv.stop(pid)
            EjackScoreDb.remove_game_add_score(player, game_score)
            {:ok, {:fail, game_score}}
          game_score <= 21 ->
            {:ok, card}
        end
      end
    ensure_game_started(player, fun)
  end

  @spec stick(charlist) :: {:ok, integer} | {:error, any}
  def stick(player) do
    fun =
      fn (pid) ->
        {:ok, game_score} = EjackEngineSrv.stick(pid)
        EjackEngineSrv.stop(pid)
        EjackScoreDb.remove_game_add_score(player, game_score)
        {:ok, game_score}
      end
    ensure_game_started(player, fun)
  end

  @spec cards(charlist) :: {:ok, {charlist, charlist}, integer} | {:error, any}
  def cards(player) do
    fun = fn (pid) -> EjackEngineSrv.cards(pid) end
    ensure_game_started(player, fun)
  end

  @spec score(charlist) :: {:ok, charlist}
  def score(player) do
    {:ok, EjackScoreDb.get_score(player) |> inspect(charlists: :as_lists)}
  end

  ##----------------------------------------------------------------------------
  ## internal functions
  ##----------------------------------------------------------------------------
  defp ensure_game_started(player, success_fun) do
    case EjackScoreDb.get_game(player) do
      :undefined -> {:error, {:not_started, player}}
      pid        -> success_fun.(pid)
    end
  end
end
