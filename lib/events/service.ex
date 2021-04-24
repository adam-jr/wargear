defmodule Wargear.Events.Service do
  alias Wargear.Events.Dao
  require Logger

  def insert_new(events, game_id) do
    newest_new = newest_id(events)
    newest_known = newest_id(Dao.get(game_id))

    if newest_new > newest_known do
      Logger.info("#{__MODULE__}: Received #{newest_new - newest_known} new event(s), inserting")
      Dao.update(events, game_id)
      :update
    else
      :noop
    end
  end

  defp newest_id(events),
    do: Enum.at(events, -1, %{}) |> Map.get(:id, 0)
end
