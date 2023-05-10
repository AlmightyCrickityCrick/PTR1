defmodule PoolSupervisor5 do
  use Supervisor

  def start_link(nr) do
    Supervisor.start_link(__MODULE__, nr, name: __MODULE__)
    # DynamicSupervisor.start_link(__MODULE__,[], name: __MODULE__)
  end

  def init(nr) do
    Process.flag(:trap_exit, true)
    children = [
      Supervisor.child_spec({WriterSupervisor5, %{nr: nr, type: :emo, id: 0}}, id: String.to_atom("ws#{0}"), restart: :permanent),
      Supervisor.child_spec({WriterSupervisor5, %{nr: nr, type: :eng, id: 1}}, id: String.to_atom("ws#{1}"), restart: :permanent),
      Supervisor.child_spec({WriterSupervisor5, %{nr: nr, type: :user_eng, id: 2}}, id: String.to_atom("ws#{2}"), restart: :permanent),
      Supervisor.child_spec({WriterSupervisor5, %{nr: nr, type: :simple, id: 3}}, id: String.to_atom("ws#{3}"), restart: :permanent),
    ]

    Supervisor.init(children, [strategy: :one_for_one, max_restarts: 200])
    #DynamicSupervisor.init(strategy:  :one_for_one, max_restarts: 2000)
  end

end
