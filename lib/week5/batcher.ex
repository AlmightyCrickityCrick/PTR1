defmodule Batcher5 do
  use GenServer

  def start_link(size) do
    GenServer.start_link(__MODULE__, %{size: size, tweets: [], timer: 5000, last_time: 0}, name: __MODULE__)
  end

  def init(args) do
    x = :timer.send_after(5000, self(), :print)
    GenServer.cast(Aggregator5, {:gimme, Map.get(args, :size)})
    {:ok, %{size: Map.get(args, :size), tweets: Map.get(args, :tweets), timer: x, last_time: :os.system_time(:millisecond)}}
  end

  def handle_cast(info, state) do
    new_tweets = Map.get(state, :tweets) |> List.insert_at(-1, info)
    twt = if(length(new_tweets) >= Map.get(state, :size)) do
      #IO.puts("Full")
      #IO.inspect(new_tweets)
      try do
        send(DBWriter5, new_tweets)
        GenServer.cast(Aggregator5, {:gimme, Map.get(state, :size)})
        :timer.cancel(Map.get(state, :timer))
        []
      rescue
        _ ->
          IO.puts("No answer from DB")
          new_tweets
        end
    else
      new_tweets
    end
    {timer, elapsed}= if(length(twt) == 0) do  {:timer.send_after(5000, self(), :print), :os.system_time(:millisecond) } else{ Map.get(state, :timer), Map.get(state, :last_time)} end
    {:noreply, %{size: Map.get(state, :size), tweets: twt, timer: timer, last_time: elapsed}}
  end

  def handle_info(:print, state) do
    {t, e} = if((:os.system_time(:millisecond) - Map.get(state, :last_time) ) > 5000) do
      #IO.puts("Timed")
      try do
      send(DBWriter5, Map.get(state, :tweets))
      GenServer.cast(Aggregator5, {:gimme, Map.get(state, :size)})
      {[], :os.system_time(:millisecond)}
      rescue
        _ ->
          IO.puts("No answer from DB")
          {Map.get(state, :tweets),  Map.get(state, :last_time)}
      end
    else
      {Map.get(state, :tweets),  Map.get(state, :last_time)}
    end
    x  = :timer.send_after(5000, self(), :print)
    {:noreply, %{size: Map.get(state, :size), tweets: t, timer: x, last_time: e}}
  end
end
