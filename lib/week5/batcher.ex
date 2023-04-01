defmodule Batcher5 do
  use GenServer

  def start_link(size) do
    GenServer.start_link(__MODULE__, %{size: size, tweets: []}, name: __MODULE__)
  end

  def init(args) do
    _x = :timer.send_after(50000, self(), :print)
    {:ok, args}
  end

  def handle_cast(info, state) do
    new_tweets = Map.get(state, :tweets) |> List.insert_at(-1, info)
    twt = if(length(new_tweets) >= Map.get(state, :size)) do
      IO.inspect(new_tweets)
      []
    else
      new_tweets
    end
    {:noreply, %{size: Map.get(state, :size), tweets: twt}}
  end

  def handle_info(:print, state) do
    IO.inspect(Map.get(state, :tweets))
    _x  = :timer.send_after(50000, self(), :print)
    {:noreply, %{size: Map.get(state, :size), tweets: []}}
  end
end
