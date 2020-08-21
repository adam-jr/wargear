defmodule Wargear.Dets do

  def insert(table, key, val) do
    atom_key = String.to_atom(to_string(key))
    :dets.open_file(table, [{:file, "#{table}.txt" |> String.to_charlist() }])
    :dets.insert(table, {atom_key, val})
    :dets.close(table)
  end

  def lookup(table, key, default) do
    :dets.open_file(table, [{:file, "#{table}.txt" |> String.to_charlist()}])

    atom_key = String.to_atom(to_string(key))

    val = 
      case :dets.lookup(table, atom_key) do
        [{^key, val}] -> val
        _ -> default
      end

    :dets.close(table)

    val
  end
end