defmodule Wargear.Events.Dao do
  @table :event_info
  @events_key :events
  @filename 'events.txt'

  def update(events) do
    stored_latest_id = 
      get(0) 
      |> Enum.at(-1)
      |> Map.get(:id)

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

  def insert(events), do: dets_insert(@events_key, events)

  def get(start_id, limit \\ nil) do
    dets_lookup(@events_key, [])
    |> Enum.filter(&(&1.id >= start_id))
    |> (fn events -> 
      case limit do
        nil -> events
        val -> Enum.take(events, val)
      end
    end).()
  end

  defp dets_insert(key, val) do
    :dets.open_file(@table, [{:file, @filename}])
    :dets.insert(@table, {key, val})
    :dets.close(@table)
  end

  defp dets_lookup(key, default) do
    :dets.open_file(@table, [{:file, @filename}])

    val = 
      case :dets.lookup(@table, key) do
        [{^key, val}] -> val
        _ -> default
      end

    :dets.close(@table)

    val
  end

end
