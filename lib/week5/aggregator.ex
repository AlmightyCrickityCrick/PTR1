defmodule Aggregator5 do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_args) do
    {:ok, %{}}
  end

  #Did I have to have 3 functions for this? Absolutely not

  def handle_cast(%{type: type, id: id, info: info}, state) do
    new_state = if(Map.has_key?(state, id)) do
      twt = Map.get(state, id) |> Map.put(type, info)
      if(Enum.count(twt)< 3) do
        Map.put(state, id, twt)
      else
        GenServer.cast(Batcher5, twt)
        Map.delete(state, id)
      end
    else
      Map.put(state, id, %{type => info})
    end
    {:noreply, new_state}
  end



end
