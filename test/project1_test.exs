defmodule Project1Test do
  use ExUnit.Case
  doctest Project1

  @tag timeout: :infinity
  test "start" do
    pid = spawn_monitor(TweetSupervisor, :start_link, [])
    Project1.supervisor_loop()
  end

end
