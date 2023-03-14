defmodule TweetSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    Process.flag(:trap_exit, true)
    children = [
      Supervisor.child_spec({Writer, :Writer1}, id: :writer1, restart: :permanent),
      Supervisor.child_spec({AnalWriter, :Writer2}, id: :writer2, restart: :permanent),
      Supervisor.child_spec({Reader, ["http://localhost:4000/tweets/1"]}, id: :reader1),
      Supervisor.child_spec({Reader, ["http://localhost:4000/tweets/2"]}, id: :reader2)
    ]
    Supervisor.init(children, [strategy: :one_for_one, max_restarts: 200])
  end


end
