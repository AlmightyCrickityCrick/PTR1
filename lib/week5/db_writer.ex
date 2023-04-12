defmodule DBWriter5 do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(args) do
    {:ok, args}
  end

  def handle_info(twt, state) do
    IO.inspect(twt)
    for t <- twt do
      {_, id_less_twt} =  Map.pop(t, :id)
      :ets.insert(:tweets, {Map.get(t, :id), id_less_twt})
    end
    {:noreply, state}
  end
end
