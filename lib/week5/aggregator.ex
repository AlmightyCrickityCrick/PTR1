defmodule Aggregator5 do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_args) do
    {:ok, %{}}
  end

  def handle_cast({:gimme, nr}, state) do
    IO.puts("Gimme received")
    twt = Map.filter(state, fn{_key, val} -> Map.get(val, :state) == :done end)
    id_list = Map.keys(twt)
    to_send_list = for x <- 0 .. nr - 1 do
      Enum.at(id_list, x)
    end
    to_send_list = Enum.filter(to_send_list, fn i -> i != nil end)
    new_state = Map.filter(state, fn{key, _val} -> !Enum.member?(to_send_list, key) end)
    for x <- to_send_list do
      t = Map.get(twt, x)
      GenServer.cast(Batcher5, t)
    end
    {:noreply, new_state}
  end

  def handle_cast(%{type: type, id: id, info: info}, state) do
    new_state = if(Map.has_key?(state, id)) do
      twt = Map.get(state, id) |> Map.put(type, info)
      if(Enum.count(twt)< 3) do
        Map.put(state, id, twt)
      else
        t = Map.put(twt, :state, :done)
        Map.put(state, id, t)
      end
    else
      Map.put(state, id, %{type => info})
    end
    {:noreply, new_state}
  end



end
