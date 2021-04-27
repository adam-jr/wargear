defmodule Wargear.Messenger do
  def notify_newly_dead(player, game_id) do
    %{text: "<#{player.slack_name}> died in http://www.wargear.net/games/view/#{game_id}"}
    |> post_to_slack()
  end

  def notify_of_turn(player, game_id) do
    url = "http://www.wargear.net/games/view/#{game_id}"

    text =
      case player.slack_name do
        _ -> "<#{player.slack_name}>, I wuv you 🧸💕, it's your turn #{url}"
      end

    %{text: text}
    |> post_to_slack()
  end

  def announce_winner(player, game_id) do
    text =
      case player.slack_name do
        _ ->
          "<#{player.slack_name}> won game ##{game_id}, yay #{winning_gif(player.slack_name)} <@channel>"
      end

    %{text: text}
    |> post_to_slack()
  end

  def winning_gif(slack_name) do
    case slack_name do
      # great success
      "@atom.r" -> "https://media.giphy.com/media/a0h7sAqON67nO/giphy.gif"
      # spongebob bullshit
      "@cvanthof85" -> "https://media.giphy.com/media/qL2kQFdyzApRS/giphy.gif"
      "@json" -> "https://media.giphy.com/media/5XPb0FvIqylqg/giphy.gif"
      "@heshman45" -> "https://media.giphy.com/media/5XPb0FvIqylqg/giphy.gif"
      "@dan" -> "https://media.giphy.com/media/5XPb0FvIqylqg/giphy.gif"
      "@zach" -> "https://media.giphy.com/media/5XPb0FvIqylqg/giphy.gif"
      "@zachclash" -> "https://media.giphy.com/media/5XPb0FvIqylqg/giphy.gif"
    end
  end

  def list_channels do
    url = url(:list_channels)
    headers = headers()

    HTTPoison.get!(url, headers)
  end

  def list_users do
    url = url(:list_users)
    headers = headers()

    HTTPoison.get!(url, headers)
  end

  def open_conversation(user \\ :adam) do
    url = url(:open_conversation)
    headers = headers()
    user = Application.get_env(:wargear, :slack_app)[:user_ids][user]
    body = Poison.encode!(%{users: user})

    HTTPoison.post!(url, body, headers)
  end

  def read_channel(channel, timestamp) do
    url = url(:read_channel)
    channel_id = channel_id(channel)
    headers = headers()

    HTTPoison.get!(url, headers, params: %{channel: channel_id, oldest: timestamp})
  end

  def post_to_slack(body, channel \\ :spitegear) do
    url = url(:post_message)
    headers = headers()
    channel = Application.get_env(:wargear, :slack_app)[:channel_ids][channel]

    body =
      body
      |> Map.put(:channel, channel)
      |> Poison.encode!()

    HTTPoison.post!(url, body, headers)
  end

  def post_dm(text, recipient) do
    url = url(:post_message)
    headers = headers()
    channel = Application.get_env(:wargear, :slack_app)[:dm_ids][recipient]

    body =
      %{}
      |> Map.put(:text, text)
      |> Map.put(:channel, channel)
      |> Poison.encode!()

    HTTPoison.post!(url, body, headers)
  end

  def channel_id(channel) do
    config = Application.get_env(:wargear, :slack_app)

    config[:channel_ids][channel]
  end

  def url(endpoint) do
    config = Application.get_env(:wargear, :slack_app)

    config[:base_url]
    |> Path.join(config[:endpoints][endpoint])
  end

  def headers do
    token = Application.get_env(:wargear, :slack_app)[:auth_token]
    [{"Content-Type", "application/json"}, {"Authorization", "Bearer #{token}"}]
  end
end
