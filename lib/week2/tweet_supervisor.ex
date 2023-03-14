defmodule TweetSupervisor2 do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    Process.flag(:trap_exit, true)
    children = [
      Supervisor.child_spec({WriterSupervisor, 3}, id: :ws, restart: :permanent),
      Supervisor.child_spec({LoadBalancer, %{:name => :LB1, :nr => 3 }}, id: :lb, restart: :permanent),
      Supervisor.child_spec({Reader, ["http://localhost:4000/tweets/1"]}, id: :reader1),
      Supervisor.child_spec({Reader, ["http://localhost:4000/tweets/2"]}, id: :reader2)
    ]
    Supervisor.init(children, [strategy: :one_for_one, max_restarts: 200])
  end


end
