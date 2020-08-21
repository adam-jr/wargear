defmodule Wargear.Dets do

  def insert(table, key, val) do
    :dets.open_file(table, [{:file, "#{table}.txt"}])
    :dets.insert(table, {key, val})
    :dets.close(table)
  end

  def lookup(table, key, default) do
    :dets.open_file(table, [{:file, "#{table}.txt"}])

    val = 
      case :dets.lookup(table, key) do
        [{^key, val}] -> val
        _ -> default
      end

    :dets.close(table)

    val
  end
end