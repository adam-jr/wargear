defmodule Wargear.Events.Dao do
  alias Wargear.Dets
  require Logger

  @prefix "events"

  def key(game_id), do: @prefix <> "_" <> to_string(game_id)

  def update(events, game_id) do
    stored_latest_id =
      case get(game_id) do
        [] -> 0
        stored -> Enum.at(stored, -1) |> Map.get(:id)
      end

    incoming_latest_id =
      events
      |> Enum.at(-1, %{})
      |> Map.get(:id, 0)

    if incoming_latest_id > stored_latest_id do
      Logger.info("New events! Inserting to event store...")
      insert(events, game_id)
      :update
    else
      Logger.info("No new events.")
      :noop
    end
  end

  def insert(events, game_id), do: Dets.insert(key(game_id), events)

  def get(game_id) do
    case Dets.lookup(key(game_id)) do
      nil -> []
      [_hd | _rest] = events -> events
    end
  end
end
