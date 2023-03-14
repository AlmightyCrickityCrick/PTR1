defmodule AnalWriter do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, %{hashtags: %{}}, name: args)
  end


  def init(state) do
    Process.flag(:trap_exit, true)
    :timer.send_after(5000, self(), :print)
    {:ok, state}
  end

  def handle_info(:print, state) do
    tmp = Map.to_list(Map.get(state, :hashtags))
    ranked_hashtags = List.keysort(tmp, 1)
    IO.puts("Most popular hashtag #{inspect(List.last(ranked_hashtags))}")
    :timer.send_after(5000, self(), :print)
    {:noreply, %{hashtags: %{}}}
  end

  def handle_info(:kill, _state) do
    IO.puts("Murder")
    exit(:kill)
  end

  def handle_info(msg, state) do
    tweet = Map.get(Map.get(msg, "message"), "tweet")
    hashtag_data = Map.get(Map.get(tweet, "entities"), "hashtags")
    current_hashtags = Map.get(state, :hashtags)
    if length(hashtag_data) > 0 do
      hashtag_update = Enum.reduce(hashtag_data, current_hashtags, fn hash, acc ->
        h = Map.get(hash, "text")
        Map.put(acc, h, Map.get(acc, h, 0) + 1)
      end )
      {:noreply, %{hashtags: hashtag_update}}
    else
    {:noreply, state}
    end
  end

end
