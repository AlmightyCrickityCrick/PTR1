defmodule UserEngagementWriter4 do
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

  def handle_info(_msg, _state) do
    {:noreply, nil}
  end

  def handle_cast(msg, _state) do
    m = Map.get(msg, :msg)
    user = Map.get(Map.get(Map.get(m, "message"), "tweet"), "user") |> Map.get("id")
    engagement = :ets.lookup(:users, user)
    engagement = if (length(engagement)!=0) do
      {_ , value} = List.first(engagement)
      Enum.sum(value) / length(value)
    else
      0
    end
   IO.inspect({user, "user_engagement", engagement})
   Process.sleep(trunc(Statistics.Distributions.Poisson.rand(5)))
    {:noreply, nil}
  end




end
