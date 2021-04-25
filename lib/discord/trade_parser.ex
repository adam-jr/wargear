defmodule Wargear.TradeParser do
  alias Wargear.Discord.API
  require Logger

  defmodule Message do
    defstruct id: nil, content: nil

    def from_json(json) do
      %__MODULE__{
        id: json["id"],
        content: json["content"]
      }
    end
  end

  def new_messages(params) do
    with {:ok, response} <- API.new_messages(params[:channel], params[:id]),
         {:ok, body} <- Poison.decode(response.body),
         {:ok, messages} <- parse_messages(body) do
      messages
    else
      e ->
        Logger.error("Failed to get discord messages with #{inspect(e)}")
        []
    end
  end

  defp parse_messages(messages),
    do: {:ok, Enum.map(messages, &Message.from_json/1)}
end
