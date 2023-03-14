defmodule Writer do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, [], name: args)
  end


  def init(_args) do
    Process.flag(:trap_exit, true)
    {:ok, nil}
  end

  def handle_info(:kill, _state) do
    IO.puts("Murder")
    exit(:kill)

  end

  def handle_info(msg, _state) do
    tweet = Map.get(Map.get(msg, "message"), "tweet")
    Process.sleep(trunc(Statistics.Distributions.Poisson.rand(50)))
    #IO.inspect(Map.get(tweet, "text"))
    #send(:LB1, {:finished, self()})
    {:noreply, nil}
  end

end
