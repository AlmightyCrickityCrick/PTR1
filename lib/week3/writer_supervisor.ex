defmodule WriterSupervisor3 do
  use DynamicSupervisor

  def start_link(nr) do
    # Supervisor.start_link(__MODULE__, nr, name: __MODULE__)
    DynamicSupervisor.start_link(__MODULE__,[], name: __MODULE__)
  end

  def init(nr) do
    Process.flag(:trap_exit, true)
    # children =
    #   for i <- 1 .. nr do
    #     Supervisor.child_spec({Writer, String.to_atom("Writer#{i}")}, id: String.to_atom("writer#{i}"), restart: :permanent)
    #   end

    # Supervisor.init(children, [strategy: :one_for_one, max_restarts: 200])
    DynamicSupervisor.init(strategy:  :one_for_one, max_restarts: 2000)
  end

  def get_process(nr) when is_integer(nr) do
    Supervisor.which_children(__MODULE__)
    |> Enum.at(nr)
    |> elem(1)
  end

  def get_process(pid) do
    Supervisor.which_children(__MODULE__)
    |> Enum.find_index(fn x ->
      Tuple.to_list(x) |>
      Enum.member?(pid) end)
  end

  def kill_child() do
    pid = DynamicSupervisor.which_children(WriterSupervisor3)
    |> Enum.at(-1)
    |> elem(1)

    DynamicSupervisor.terminate_child(WriterSupervisor3, pid)
  end


end
