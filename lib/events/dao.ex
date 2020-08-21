defmodule Wargear.Events.Dao do
  alias Wargear.Dets
  require Logger

  @table :events
  @initial_state []

  def update(events, game_id) do
    stored_latest_id = 
      case get(0, nil, game_id) do
        [] -> 0
        stored -> Enum.at(stored, -1) |> Map.get(:id)
      end

    incoming_latest_id =
      events
      |> Enum.at(-1)
      |> Map.get(:id)

    if incoming_latest_id > stored_latest_id do
      Logger.info("New events! Inserting to event store...")
      insert(events, game_id)
      :update
    else
      Logger.info("No new events.")
      :noop
    end
  end

  def insert(events, game_id), do: Dets.insert(@table, game_id, events)

  def get(start_id, limit, game_id) do
    Dets.lookup(@table, game_id, @initial_state)
    |> Enum.filter(&(&1.id >= start_id))
    |> (fn events -> 
      case limit do
        nil -> events
        val -> Enum.take(events, val)
      end
    end).()
  end

  def reset(game_id), do: insert(@initial_state, game_id)

end
