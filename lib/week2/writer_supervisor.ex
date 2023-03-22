defmodule WriterSupervisor do
  use Supervisor

  def start_link(nr) do
    Supervisor.start_link(__MODULE__, nr, name: __MODULE__)
  end

  def init(nr) do
    Process.flag(:trap_exit, true)
    children =
      for i <- 1 .. nr do
        Supervisor.child_spec({Writer, String.to_atom("writer#{i}")}, id: String.to_atom("writer#{i}"), restart: :permanent)
      end

    Supervisor.init(children, [strategy: :one_for_one, max_restarts: 200])
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
    |>IO.inspect()
  end



end
