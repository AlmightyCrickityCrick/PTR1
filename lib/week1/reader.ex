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
    send(:LB1, :kill)
    {:noreply, nil}
  end

  def handle_info(%HTTPoison.AsyncChunk{chunk: chunk}, _state) do
    "event: \"message\"\n\ndata: " <> message = chunk
    try do
        send(:LB1, message)
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
