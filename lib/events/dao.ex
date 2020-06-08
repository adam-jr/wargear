defmodule Wargear.Events.Dao do
  alias Wargear.Dets

  @table :event_info
  @key :events

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
      insert(events)
      :update
    else
      :noop
    end
  end

  def insert(events), do: Dets.insert(@table, @key, events)

  def get(start_id, limit \\ nil) do
    Dets.lookup(@table, @key, [])
    |> Enum.filter(&(&1.id >= start_id))
    |> (fn events -> 
      case limit do
        nil -> events
        val -> Enum.take(events, val)
      end
    end).()
  end

end
