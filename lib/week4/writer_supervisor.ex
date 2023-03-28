defmodule WriterSupervisor4 do
  use Supervisor

  def start_link(nr) do
    Supervisor.start_link(__MODULE__, nr, name: String.to_atom("writersup#{nr}"))
    # DynamicSupervisor.start_link(__MODULE__,[], name: __MODULE__)
  end

  def init(nr) do
    Process.flag(:trap_exit, true)
    children =[
         Supervisor.child_spec({Writer4, String.to_atom("simplewriter#{nr}")}, id: String.to_atom("simplewriter#{nr}"), restart: :permanent),
         Supervisor.child_spec({EmotionWriter4, String.to_atom("emowriter#{nr}")}, id: String.to_atom("emowriter#{nr}"), restart: :permanent),
         Supervisor.child_spec({EngagementWriter4, String.to_atom("engwriter#{nr}")}, id: String.to_atom("engwriter#{nr}"), restart: :permanent),
         Supervisor.child_spec({UserEngagementWriter4, String.to_atom("userengwriter#{nr}")}, id: String.to_atom("userengwriter#{nr}"), restart: :permanent),

    ]
    #   for i <- 1 .. nr do
    #     Supervisor.child_spec({Writer, String.to_atom("Writer#{i}")}, id: String.to_atom("writer#{i}"), restart: :permanent)
    #   end

    Supervisor.init(children, [strategy: :one_for_one, max_restarts: 200])
    #DynamicSupervisor.init(strategy:  :one_for_one, max_restarts: 2000)
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


end
