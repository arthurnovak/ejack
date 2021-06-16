defmodule EjackEngineSrv do
  use GenServer

  def start() do
    GenServer.start(__MODULE__, [])
  end

  def stop(pid) do
    GenServer.cast(pid, :stop)
  end

  @spec hit(pid) :: {:ok, {charlist, charlist}, integer}
  def hit(pid) do
    GenServer.call(pid, :hit)
  end

  @spec stick(pid) :: {:ok, integer}
  def stick(pid) do
    GenServer.call(pid, :stick)
  end

  @spec cards(pid) :: {:ok, [{charlist, charlist}], integer}
  def cards(pid) do
    GenServer.call(pid, :cards)
  end

  ##----------------------------------------------------------------------------
  ## gen_server callbacks
  ##----------------------------------------------------------------------------
  def init(_opts) do
    state = %{:deck  => init_deck(),
              :hand  => [],
              :score => 0}
    {:ok, state}
  end

  def handle_call(:hit, _from, %{:deck  => [card|deck],
                                 :hand  => hand,
                                 :score => score}) do
    new_score = score + get_value(card)
    new_state = %{:deck  => deck ++ [card],
                  :hand  => [card|hand],
                  :score => new_score}
    {:reply, {:ok, card, new_score}, new_state}
  end

  def handle_call(:stick, _from, %{:score => score} = state) do
    {:reply, {:ok, score}, state}
  end

  def handle_call(:cards, _from, %{:hand  => hand,
                                   :score => score} = state) do
    {:reply, {:ok, hand, score}, state}
  end

  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end

  ##----------------------------------------------------------------------------
  ## internal functions
  ##----------------------------------------------------------------------------
  defp init_deck() do
    pile  = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
    suits = ["club", "spade", "heart", "diamond"]
    shuffle(for card <- pile,
                suit <- suits, do: {card, suit})
  end

  defp shuffle(list) do
    for {_, x} <- Enum.sort(for x <- list, do: {:rand.uniform(), x}), do: x
  end

  defp get_value({card, _}), do: get_value(card)
  defp get_value("J"),       do: 10
  defp get_value("Q"),       do: 10
  defp get_value("K"),       do: 10
  defp get_value("A"),       do: 1
  defp get_value(other),     do: String.to_integer(other)
end
