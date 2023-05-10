defmodule CdcAdapter do
  use GenServer

  def start_link(_arg) do
    GenServer.start_link(__MODULE__, [], name: String.to_atom("cdc"))
  end

  def init(_args) do
    {:ok, []}
  end

  def handle_cast({:save, tweet}, state) do
    m = format_tweet_to_message(tweet)
    GenServer.cast(:project1, {:publish, m})
    {:noreply, state}
  end

  def format_tweet_to_message(tweet) do
    %{topic: "tweets", content: tweet, id: Enum.random(1..999999)}
  end

end
