defmodule LoadBalancer do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, Map.get(args, :nr), name: Map.get(args, :name))
  end

  def init(nr) do
    writers = for i <- 0 .. nr - 1 do
      {i, 0}
    end
    {:ok, %{nr: nr, current: 0,  writers: writers}}
  end

  #Messages from writers about finishing
  def handle_info({:finished, pid}, state) do
    nr = WriterSupervisor.get_process(pid)
    writers_list = Map.get(state, :writers)
    new_list = Enum.reduce(writers_list, [], fn {x, y}, acc ->
      if(x == nr) do
        List.insert_at(acc, -1, {nr, y - 1})
      else
        List.insert_at(acc, -1, {x, y} )
      end
    end)
    {:noreply, %{nr: state[:nr], current: state[:current], writers: new_list}}
  end


  # #least-connected
  def handle_info(msg, state) do
    writers_list = Map.get(state, :writers)
    next_receiver =List.keysort(writers_list, 1) |> List.first()
    id =  next_receiver|> elem(0)
    nr = next_receiver |> elem(1)
    new_writers = List.delete(writers_list, next_receiver) |> List.insert_at(-1, {id, nr + 1})

    pid = WriterSupervisor.get_process(id)
    send(pid, msg)
    {:noreply,  %{nr: state[:nr], current: state[:current], writers: new_writers}}
  end

  # #round-robin
  # def handle_info(msg, state) do
  #   pid = WriterSupervisor.get_process(state[:current])
  #   next = rem(state[:current] + 1, state[:nr])
  #   send(pid, msg)
  #   {:noreply,  %{nr: state[:nr], current: next, writers: state[:writers]}}
  # end

end
