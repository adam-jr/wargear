defmodule Wargear.Events.Dao do
  @table :event_info
  @events_key :events
  @filename 'events.txt'

  def insert!(events) do
    {:ok, events} = insert(events)
    events
  end

  def insert(events) do
    case dets_insert(@events_key, events) do
      :ok -> {:ok, events}
      {:error, reason} -> {:error, reason}
    end
  end

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
