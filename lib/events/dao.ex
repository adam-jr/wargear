defmodule Wargear.Events.Dao do
  alias Wargear.Dets
  require Logger

  @prefix "events"

  def key(game_id), do: @prefix <> "_" <> to_string(game_id)

  def update(events, game_id), do: Dets.insert(key(game_id), events)

  def get(game_id) do
    case Dets.lookup(key(game_id)) do
      nil -> []
      [_hd | _rest] = events -> events
    end
  end
end
