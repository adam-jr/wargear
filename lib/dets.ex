defmodule Wargear.Dets do

  @filename 'events.txt'

  def insert(table, key, val) do
    :dets.open_file(table, [{:file, @filename}])
    :dets.insert(table, {key, val})
    :dets.close(table)
  end

  def lookup(table, key, default) do
    :dets.open_file(table, [{:file, @filename}])

    val = 
      case :dets.lookup(table, key) do
        [{^key, val}] -> val
        _ -> default
      end

    :dets.close(table)

    val
  end
end