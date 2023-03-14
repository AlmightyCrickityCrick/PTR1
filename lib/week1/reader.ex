defmodule Reader do
  use GenServer

  def start_link(url) do
    GenServer.start_link(__MODULE__, url)
  end
  def init(url)do
    HTTPoison.get!(url, [], [recv_timeout: :infinity, stream_to: self()])
    {:ok, nil}
  end

  #"event: \"message\"\n\ndata: {\"message\": panic}\n\n"

  def handle_info(%HTTPoison.AsyncChunk{chunk: "event: \"message\"\n\ndata: {\"message\": panic}\n\n"}, _state) do
    send(:Writer1, :kill)
    {:noreply, nil}
  end

  def handle_info(%HTTPoison.AsyncChunk{chunk: chunk}, _state) do
    "event: \"message\"\n\ndata: " <> message = chunk
    try do
      {status, decodedjson} = Poison.decode(message)
      if(status == :ok) do
        send(:Writer1, decodedjson)
        send(:Writer2, decodedjson)
      end
    rescue
      _ ->
        IO.inspect(message)
    end


    {:noreply, nil}
  end

  def handle_info(_msg, _status)do
  {:noreply, nil}
  end


end
