defmodule Wargear.Events.Service do
  alias Wargear.Events.Dao
  require Logger

  def insert_new(events, game_id) do
    case newest_id(events) - newest_id(Dao.get(game_id)) do
      num when num > 0 ->
        Logger.info("#{__MODULE__}: Received #{num} new event(s), inserting")
        Dao.update(events, game_id)
        :update

      _ ->
        :noop
    end
  end

  defp newest_id(events),
    do: Enum.at(events, -1, %{}) |> Map.get(:id, 0)
end
