defmodule Writer4 do
  use GenServer

  def start_link(args) do
    IO.puts("#{args} starting")
    GenServer.start_link(__MODULE__, [], name: args)
  end


  def init(_args) do
    Process.flag(:trap_exit, true)
    {:ok, nil}
  end

  def handle_info(_msg, _state) do
    {:noreply, nil}
  end

  def handle_cast(:kill, _state) do
    IO.puts("Murder")
    exit(:kill)
  end

  def handle_cast(msg, _state) do
      m = Map.get(msg, :msg)
      tweet = Map.get(Map.get(Map.get(m, "message"), "tweet"), "text")
      swears = :ets.lookup(:app, :swear_list)
      swears = if (length(swears)!=0) do
      {_ , value} = List.first(swears)
      value
    end
    censored_tweet = tweet
    |> String.split(" ")
    |> Enum.map(fn x -> if x in swears do
        String.duplicate("*",String.length(x))
        else x
        end end)
      |> Enum.join(" ")
    Process.sleep(trunc(Statistics.Distributions.Poisson.rand(5)))
    if(String.contains?(censored_tweet, "*")) do IO.inspect(censored_tweet) end
    {:noreply, nil}
  end


end
