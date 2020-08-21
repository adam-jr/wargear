defmodule Wargear.Messenger do

  def notify_newly_dead(player_name, game_id) do
    %{text: 
        "<#{slack_name(player_name)}> died in http://www.wargear.net/games/view/#{game_id}"
      }
      |> post_to_slack()
  end

  def notify_of_turn(player_name, game_id) do
    %{text: "<#{slack_name(player_name)}>, you're up, ya jackass http://www.wargear.net/games/view/#{game_id}"}
    |> post_to_slack()
  end

  defp post_to_slack(body) do
    url = url(:post_message)
    headers = headers()
    channel = Application.get_env(:wargear, :slack_app)[:channel]

    body = 
      body
      |> Map.put(:channel, channel) 
      |> Poison.encode!()

    HTTPoison.post!(url, body, headers)
  end

  defp url(endpoint) do
    config = Application.get_env(:wargear, :slack_app)

    config[:base_url]
    |> Path.join(config[:endpoints][endpoint])
  end

  defp headers do
    token = Application.get_env(:wargear, :slack_app)[:auth_token]
    [{"Content-Type", "application/json"}, 
    {"Authorization", "Bearer #{token}"}]
  end


  defp slack_name(player_name) do
    case player_name do
      "adam jormp jomp"    -> "@atom.r"
      "pants off vant hof" -> "@cvanthof85"
      "Kyjygyfyf"          -> "@json"
      "Hesh"               -> "@heshman45"
      "dandodd"            -> "@dan"
      "Tallness"           -> "@zach"
      "ZachClash"          -> "@zachclash"
    end
  end

end