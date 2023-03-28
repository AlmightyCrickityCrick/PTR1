defmodule EmotionWriter4 do
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
    exit(:kill)

  end

  def handle_info(_msg, _state) do
    {:noreply, nil}
  end

  def handle_cast(msg, _state) do
      m = Map.get(msg, :msg)
      tweet = Map.get(Map.get(Map.get(m, "message"), "tweet"), "text")
      words = String.split(tweet)
      values = for x <- words do
        emot = :ets.lookup(:emotion, x)
        if (length(emot)!=0) do
          {_ , value} = List.first(emot)
          String.to_integer(value)
        else
          0
        end
    end
    val = Enum.sum(values)
    score = val / length(values)
    Process.sleep(trunc(Statistics.Distributions.Poisson.rand(5)))
    IO.inspect({Map.get(msg, :hash), "emotion", score})
    {:noreply, nil}
  end

end
