defmodule Wargear.Slack.API do
  def new_messages(channel, timestamp) do
    HTTPoison.get(url(:read_channel), headers(),
      params: %{channel: channel_id(channel), oldest: timestamp}
    )
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
