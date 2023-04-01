defmodule EngagementWriter5 do
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
    favorites = Map.get(m, "favorite_count")
    retweets = Map.get(m, "retweet_count")
    followers = Map.get(m, "user") |> Map.get("followers_count")
    user = Map.get(m, "user") |> Map.get("id")
    engagement = if(followers != 0) do(favorites + retweets)/followers else 0 end
    _res = add_engagement(user, engagement)
    #IO.inspect({Map.get(msg, :hash), "engagement", engagement})
    GenServer.cast(Aggregator5, %{type: :eng, id: Map.get(msg, :hash), info: engagement})
    Process.sleep(trunc(Statistics.Distributions.Poisson.rand(5)))
    {:noreply, nil}
  end

  def add_engagement(user, engagement) do
  usr = :ets.lookup(:users, user)
  _usr = if (length(usr)!=0) do
    {_ , value} = List.first(usr)
    :ets.insert(:users, {user, List.insert_at(value, -1, engagement)})
  else
    :ets.insert(:users, {user, [engagement]})
  end
  :ok

end
end
