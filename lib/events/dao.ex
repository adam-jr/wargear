defmodule Wargear.Events.Dao do
  alias Wargear.Dets
  require Logger

  @table :event_info
  @key :events
  @initial_state []

  def update(events) do
    stored_latest_id = 
      case get(0) do
        [] -> 0
        stored -> Enum.at(stored, -1) |> Map.get(:id)
      end

    incoming_latest_id =
      events
      |> Enum.at(-1)
      |> Map.get(:id)

    if incoming_latest_id > stored_latest_id do
      Logger.info("New events! Inserting to event store...")
      insert(events)
      :update
    else
      Logger.info("No new events.")
      :noop
    end
  end

  def insert(events), do: Dets.insert(@table, @key, events)

  def get(start_id, limit \\ nil) do
    Dets.lookup(@table, @key, @initial_state)
    |> Enum.filter(&(&1.id >= start_id))
    |> (fn events -> 
      case limit do
        nil -> events
        val -> Enum.take(events, val)
      end
    end).()
  end

  def reset, do: insert(@initial_state)

end
