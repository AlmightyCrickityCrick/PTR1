defmodule EngagementWriter5 do
  use GenServer

  def start_link(args) do
    IO.puts("#{args} starting")
    GenServer.start_link(__MODULE__, %{name: args}, name: args)
  end


  def init(args) do
    Process.flag(:trap_exit, true)
    {:ok, args}
  end

  def handle_info(:kill, _state) do
    IO.puts("Murder")
    exit(:kill)

  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  def handle_cast(msg, state) do
    m = Map.get(msg, :msg)
    favorites = Map.get(m, "favorite_count")
    retweets = Map.get(m, "retweet_count")
    followers = Map.get(m, "user") |> Map.get("followers_count")
    user = Map.get(m, "user") |> Map.get("id")
    engagement = if(followers != 0) do(favorites + retweets)/followers else 0 end
    _res = add_engagement(user, Map.get(msg, :hash), engagement)
    #IO.inspect({Map.get(msg, :hash), "engagement", engagement})
    GenServer.cast(Aggregator5, %{type: :eng, id: Map.get(msg, :hash), info: engagement})
    GenServer.cast(String.to_atom("userengwriter#{String.replace(Atom.to_string(Map.get(state, :name)), "engwriter", "")}"), %{hash: Map.get(msg, :hash), msg: Map.get(msg, :msg)})
    Process.sleep(trunc(Statistics.Distributions.Poisson.rand(5)))
    {:noreply, state}
  end

  def add_engagement(user, id, engagement) do
  usr = :ets.lookup(:users, user)
  _usr = if (length(usr)!=0) do
    {_ , value} = List.first(usr)
    :ets.insert(:users, {user, List.insert_at(value, -1, %{id => engagement})})
  else
    :ets.insert(:users, {user, [%{id => engagement}]})
  end
  :ok

end
end
