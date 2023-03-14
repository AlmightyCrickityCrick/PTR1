defmodule TwitterApplication do
  use Application

  def start(_type, _args) do
    {_resp, pid}=TweetSupervisor.start_link()
  end

end
