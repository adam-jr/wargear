defmodule Wargear.Slack do
  alias Wargear.Slack.API

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

  def new_messages(channel, timestamp) do
    with {:ok, response} <- API.new_messages(channel, timestamp),
         {:ok, body} <- Poison.decode(response.body),
         messages <- Map.get(body, "messages", []) do
      Enum.map(messages, Message.from_json(&1))
    else
      e ->
        Logger.error("Failed to get slack messages with #{e}")
        []
    end
  end
end
