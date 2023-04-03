defmodule Batcher5 do
  use GenServer

  def start_link(size) do
    GenServer.start_link(__MODULE__, %{size: size, tweets: []}, name: __MODULE__)
  end

  def init(args) do
    _x = :timer.send_after(5000, self(), :print)
    GenServer.cast(Aggregator5, {:gimme, Map.get(args, :size)})
    {:ok, args}
  end

  def handle_cast(info, state) do
    new_tweets = Map.get(state, :tweets) |> List.insert_at(-1, info)
    twt = if(length(new_tweets) >= Map.get(state, :size)) do
      IO.inspect(new_tweets)
      GenServer.cast(Aggregator5, {:gimme, Map.get(state, :size)})
      []
    else
      new_tweets
    end
    {:noreply, %{size: Map.get(state, :size), tweets: twt}}
  end

  def handle_info(:print, state) do
    IO.inspect(Map.get(state, :tweets))
    GenServer.cast(Aggregator5, {:gimme, Map.get(state, :size)})
    _x  = :timer.send_after(5000, self(), :print)
    {:noreply, %{size: Map.get(state, :size), tweets: []}}
  end
end
