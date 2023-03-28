defmodule PoolSupervisor4 do
  use Supervisor

  def start_link(nr) do
    Supervisor.start_link(__MODULE__, nr, name: __MODULE__)
    # DynamicSupervisor.start_link(__MODULE__,[], name: __MODULE__)
  end

  def init(nr) do
    Process.flag(:trap_exit, true)
    children = for i <- 0 .. nr-1 do
      Supervisor.child_spec({WriterSupervisor4, i}, id: String.to_atom("ws#{i}"), restart: :permanent)
      end

    Supervisor.init(children, [strategy: :one_for_one, max_restarts: 200])
    #DynamicSupervisor.init(strategy:  :one_for_one, max_restarts: 2000)
  end

end
