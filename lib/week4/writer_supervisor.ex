defmodule WriterSupervisor4 do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: String.to_atom("writersup#{Map.get(args, :id)}"))
    # DynamicSupervisor.start_link(__MODULE__,[], name: __MODULE__)
  end

  def init(args) do
    Process.flag(:trap_exit, true)
    nr = Map.get(args, :nr)
    type = Map.get(args, :type)
    children = for i <- 0 .. nr - 1 do
      cond do
        type == :emo ->
          Supervisor.child_spec({EmotionWriter4, String.to_atom("emowriter#{i}")}, id: String.to_atom("emowriter#{i}"), restart: :permanent)
        type == :eng ->
          Supervisor.child_spec({EngagementWriter4, String.to_atom("engwriter#{i}")}, id: String.to_atom("engwriter#{i}"), restart: :permanent)
        type == :user_eng ->
          Supervisor.child_spec({UserEngagementWriter4, String.to_atom("userengwriter#{i}")}, id: String.to_atom("userengwriter#{i}"), restart: :permanent)
        true ->
          Supervisor.child_spec({Writer4, String.to_atom("simplewriter#{i}")}, id: String.to_atom("simplewriter#{i}"), restart: :permanent)
      end
    end

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
