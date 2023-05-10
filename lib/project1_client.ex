defmodule Project1Client do
  use GenServer
  def start_link(_args) do
    GenServer.start_link(__MODULE__, "project1", name: String.to_atom("project1"))
  end

  def init(name) do
    register(name)
    {:ok, socket} = :gen_tcp.connect(:broker, 5000, [:binary, packet: :line, active: false])
    Task.start_link(fn -> listening_loop(socket, name) end)
    {:ok, %{name: name, socket: socket}}
  end

  def register(name) do
    {:ok, socket} = :gen_tcp.connect(:broker, 4040, [:binary, packet: :raw, active: false])
    IO.puts("Starting #{name}")
    Process.sleep(100)
    msg = %{type: "producer", action: "register", name: name}
    msg_to_send = Poison.encode!(msg)
    resp = :gen_tcp.send(socket, msg_to_send <> "/q\n")
    r = :gen_tcp.shutdown(socket, :read_write)
  end


  def listening_loop(socket, name) do
    resp = read_message(socket, "")
    IO.puts(resp)
    listening_loop(socket, name)
  end

  def handle_cast({:publish, message}, state) do
    m = Map.put(message, "producer", Map.get(state, :name)) |> Poison.encode!()
    resp = :gen_tcp.send(Map.get(state, :socket), m <> "/q\n")
    {:noreply, state}
  end

  defp read_message(socket, message) do
    case :gen_tcp.recv(socket, 0) do
    {:ok, data} ->
      if (String.contains?(data, "/q")) do
        String.replace(data, "/q", "")
      else
        read_message(socket, message <> data)
      end
      {:error, _} ->
        ""
    end
  end

end
