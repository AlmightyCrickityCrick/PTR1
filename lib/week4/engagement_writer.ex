defmodule EngagementWriter4 do
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
    favorites = Map.get(Map.get(Map.get(m, "message"), "tweet"), "favorite_count")
    retweets = Map.get(Map.get(Map.get(m, "message"), "tweet"), "retweet_count")
    followers = Map.get(Map.get(Map.get(m, "message"), "tweet"), "user") |> Map.get("followers_count")
    user = Map.get(Map.get(Map.get(m, "message"), "tweet"), "user") |> Map.get("id")
    engagement = if(followers != 0) do(favorites + retweets)/followers else 0 end
    _res = add_engagement(user, engagement)
    IO.inspect({Map.get(msg, :hash), "engagement", engagement})
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
