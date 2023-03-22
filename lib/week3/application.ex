defmodule TwitterApplication3 do
  use Application

  def start(_type, _args) do
    json = File.read!("lib/week3/swearwords.json")
    {:ok, swear_list} = Poison.decode(json)
    semaphore = Semaphore.createSemaphore()
    :ets.new(:app, [:named_table, :set, :public])
    :ets.insert(:app, {:swear_list, swear_list})
    :ets.insert(:app, {:semaphore, semaphore})
    :ets.new(:messages, [:named_table, :set, :public])


    {_resp, pid}= TweetSupervisor3.start_link()
  end

end
