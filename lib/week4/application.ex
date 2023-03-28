defmodule TwitterApplication4 do
  use Application

  def start(_type, _args) do
    json = File.read!("lib/week3/swearwords.json")
    :ets.new(:emotion, [:named_table, :set, :public])
    emotion_list = HTTPoison.get!("http://localhost:4000/emotion_values").body |> String.replace("\t", ":")|> String.replace("\r\n", ", ")|> String.split(", ")
    for x <- emotion_list do
      [word | val] = String.split(x, ":")
      :ets.insert(:emotion, {word, Enum.at(val, 0)})
    end
    {:ok, swear_list} = Poison.decode(json)
    :ets.new(:app, [:named_table, :set, :public])
    :ets.insert(:app, {:swear_list, swear_list})
    :ets.new(:users, [:named_table, :set, :public])

    {_resp, pid}= TweetSupervisor4.start_link(%{nr: 3})
  end

end
