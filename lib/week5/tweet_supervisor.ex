defmodule TweetSupervisor5 do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args[:nr], name: __MODULE__)
  end

  def init(args) do
    Process.flag(:trap_exit, true)
    children = [
      Supervisor.child_spec({PoolSupervisor5, args}, id: String.to_atom("ps"), restart: :permanent),
      Supervisor.child_spec({LoadBalancer5, %{:name => :LB1, :nr => args }}, id: :lb, restart: :permanent),
      Supervisor.child_spec({Reader5, ["http://localhost:4000/tweets/1"]}, id: :reader1),
      Supervisor.child_spec({Reader5, ["http://localhost:4000/tweets/2"]}, id: :reader2),
      Supervisor.child_spec({Aggregator5, []}, id: :aggregator),
      Supervisor.child_spec({Batcher5, 3}, id: :batcher),
      Supervisor.child_spec({DBWriter5, []}, id: :db_writer)
    ]
    Supervisor.init(children, [strategy: :one_for_one, max_restarts: 200])
  end


end
