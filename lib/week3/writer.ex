defmodule Writer3 do
  use GenServer

  def start_link(args) do
    IO.puts("#{args} starting")
    GenServer.start_link(__MODULE__, [], name: args)
  end


  def init(_args) do
    Process.flag(:trap_exit, true)
    {:ok, nil}
  end

  def handle_info(:kill, _state) do
    IO.puts("Murder")
    send(:LB1, {:reset, self()})
    exit(:kill)

  end

  def handle_info(hash, _state) do
    sem =:ets.lookup(:app, :semaphore)
    semaph = if (length(sem)!=0) do
      {_ , value} = List.first(sem)
      value
    end

    _ = Semaphore.acquire(semaph)
    m = :ets.lookup(:messages, hash)
    msg = if (length(m)!=0) do
      {_ , value} = List.first(m)
      value
    else
      nil
    end
    if(msg != nil)do
      _ = :ets.delete(:messages, hash)
      Semaphore.release(semaph)
      tweet = Map.get(Map.get(Map.get(msg, "message"), "tweet"), "text")
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
      else
      Semaphore.release(semaph)
  end
    send(:LB1, {:finished, self()})
    {:noreply, nil}
  end

end
