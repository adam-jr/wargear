defmodule Wargear.Slack do
  alias Wargear.Slack.API
  require Logger

  defmodule Message do
    defstruct text: nil, user: nil, timestamp: nil

    def from_json(json) do
      %__MODULE__{
        text: json["text"],
        user: json["user"],
        timestamp: json["timestamp"]
      }
    end
  end

  def new_messages(params) do
    with {:ok, response} <- API.new_messages(params[:channel], params[:timestamp]),
         {:ok, body} <- Poison.decode(response.body),
         {:ok, messages} <- parse_messages(body) do
      messages
    else
      e ->
        Logger.error("Failed to get slack messages with #{inspect e}")
        []
    end
  end

  defp parse_messages(%{"ok" => false} = body), do: {:error, "Response not OK, body: #{inspect body}"}
  defp parse_messages(%{"ok" => true, "messages" => messages}), do: Enum.map(messages, &Message.from_json/1)
  defp parse_messages(%{"ok" => true} = body), do: {:error, "Unexpected response, body: #{body}"}
end
