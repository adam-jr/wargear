defmodule Wargear.Dets do

  @table :wargear
  @filename 'wargear_data.txt'

  def insert(key, val) do
    :dets.open_file(@table, [{:file, @filename}])
    :dets.insert(@table, {key, val})
    :dets.close(@table)
  end

  def lookup(key) do
    :dets.open_file(@table, [{:file, @filename}])

    val = 
      case :dets.lookup(@table, key) do
        [{^key, val}] -> val
        [] -> nil
      end

    :dets.close(@table)

    val
  end
end