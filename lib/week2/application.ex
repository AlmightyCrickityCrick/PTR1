defmodule TwitterApplication2 do
  use Application

  def start(_type, _args) do
    {_resp, pid}= TweetSupervisor2.start_link()
  end

end
