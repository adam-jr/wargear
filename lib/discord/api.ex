defmodule Wargear.Discord.API do
  def new_messages(channel, cursor) do
    HTTPoison.get(url(channel), headers(channel), params: params(cursor))
  end

  defp url(channel) do
    config = Application.get_env(:wargear, :discord)

    config[:base_url]
    |> Path.join(config[:channel_ids][channel])
  end

  defp headers(channel) do
    token = Application.get_env(:wargear, :discord)[:auth_token][channel]
    [{"Content-Type", "application/json"}, {"authorization", token}]
  end

  defp params(cursor) when is_nil(cursor),
    do: %{limit: 50}

  defp params(cursor),
    do: %{after: cursor, limit: 50}
end
