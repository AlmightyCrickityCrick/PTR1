defmodule LoadBalancer4 do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, Map.get(args, :nr), name: Map.get(args, :name))
  end

  def init(nr) do
    writers = for i <- 0 .. nr - 1 do
      {i, 0}
    end

        Process.sleep(10)
    {:ok, %{nr: nr, current: 0,  pools: writers}}
  end

  # def handle_info({:reset, pid}, state) do
  #   nr = WriterSupervisor4.get_process(pid)
  #   writers_list = Map.get(state, :pools)
  #   new_list = Enum.reduce(writers_list, [], fn {x, y}, acc ->
  #     if(x == nr) do
  #       List.insert_at(acc, -1, {x, 0})
  #     else
  #       List.insert_at(acc, -1, {x, y} )
  #     end
  #   end)
  #   {:noreply, %{nr: state[:nr], current: state[:current], writers: new_list}}
  # end

  # #Messages from writers about finishing
  # def handle_info({:finished, pid}, state) do
  #   nr = WriterSupervisor4.get_process(pid)
  #   writers_list = Map.get(state, :writers)
  #   new_list = Enum.reduce(writers_list, [], fn {x, y}, acc ->
  #     if(x == String.to_atom("writer#{nr}")) do
  #       List.insert_at(acc, -1, {x, y - 1})
  #     else
  #       List.insert_at(acc, -1, {x, y} )
  #     end
  #   end)
  #   {:noreply, %{nr: state[:nr], current: state[:current], writers: new_list}}
  # end

  # def handle_info(:balance, state) do
  #   # {_, messages} = Process.info(self(), :message_queue_len)
  #   writers = Map.get(state, :writers)
  #   messages = Enum.reduce(writers, 0, fn {_, val}, acc -> acc + val end)
  #   avg = messages / length(writers)

  #   writer_list = cond do
  #     (avg > 6) ->
  #     DynamicSupervisor.start_child(WriterSupervisor4, Supervisor.child_spec({Writer4, String.to_atom("writer#{length(writers)}")}, id: String.to_atom("writer#{length(writers)}")))
  #     IO.puts("New worker")
  #     List.insert_at(writers, -1, {String.to_atom("writer#{length(writers)}"), 0})
  #     (avg < 4 and (length(writers) > 3)) ->
  #       _st = WriterSupervisor4.kill_child()
  #       tmp = for i <- 0 .. length(writers) - 1 do
  #         if(elem(Enum.at(writers, i), 0) != String.to_atom("writer#{length(writers) - 1}")) do
  #           Enum.at(writers, i)
  #         else
  #           0
  #         end
  #       end
  #       tmp = List.delete(tmp, 0)
  #       tmp
  #     true ->
  #       writers
  #   end
  #   IO.inspect(writer_list)
  #   :timer.send_after(3000, self(), :balance)

  #   {:noreply,  %{nr: length(writer_list), current: state[:current], writers: writer_list}}
  # end

    #round-robin
    def handle_info(:kill, state) do
      id = state[:current]
      next = rem(state[:current] + 1, state[:nr])
      GenServer.cast(String.to_atom("simplewriter#{id}"), :kill)
      {:noreply,  %{nr: state[:nr], current: next, writers: state[:writers]}}
    end


    def handle_info(msg, state) do
      id = state[:current]
      next = rem(state[:current] + 1, state[:nr])
      hashed_msg = :crypto.hash(:sha256, msg)
      {_, decodedjson} = Poison.decode(msg)
      GenServer.cast(String.to_atom("simplewriter#{id}"), %{hash: hashed_msg, msg: decodedjson})
      GenServer.cast(String.to_atom("emowriter#{id}"), %{hash: hashed_msg, msg: decodedjson})
      GenServer.cast(String.to_atom("engwriter#{id}"), %{hash: hashed_msg, msg: decodedjson})
      GenServer.cast(String.to_atom("userengwriter#{id}"), %{hash: hashed_msg, msg: decodedjson})

      {:noreply,  %{nr: state[:nr], current: next, writers: state[:writers]}}
    end

  # #least-connected
  # def handle_info(msg, state) do
  #   writers_list = Map.get(state, :writers)
  #   next_receiver =List.keysort(writers_list, 1)
  #   hashed_msg = :crypto.hash(:sha256, msg)
  #   {_, decodedjson} = Poison.decode(msg)
  #   new_writers =
  #     for i <- 0 ..length(writers_list) -1 do
  #         x  = Enum.at(next_receiver, i)
  #         id =  x|> elem(0)
  #         nr = x |> elem(1)
  #       if(i < 3) do
  #         GenServer.cast(id, %{hash: hashed_msg, msg: decodedjson})
  #         {id, nr + 1}
  #       else
  #         {id, nr}
  #       end

  #   end
  #   {:noreply,  %{nr: length(new_writers), current: state[:current], writers: new_writers}}
  # end


end
