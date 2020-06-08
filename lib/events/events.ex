defmodule Wargear.Player do
  defstruct name: nil, units: 33, territories: 11
end

defmodule Wargear.Events do

  defmodule Event do
    defstruct id: nil, type: nil, player: nil, datetime: nil, seat: nil, action: nil, bonus_units: nil, trade_units: nil, attacker: nil, defender: nil, ad: nil, dd: nil, bmod: nil, al: nil, dl: nil
  end

  def get do
    %{body: body} = HTTPoison.get!("http://www.wargear.net/games/log/731327")

    Floki.parse_document!(body) 
    |> Floki.find("tr.row_dark")
    |> Enum.map(&to_event/1)
  end

  defp get_type(action) do
    case action do
      {_, _, [_, " attacked ", _, _]}       -> :attack
      {_, _, [_, " awarded " <> _rest]}     -> :card_award
      {_, _, [_, " captured " <> _rest, _]} -> :card_capture
      {_, _, [_, " traded " <> _rest]}      -> :card_trade
      {_, _, [_, " eliminated ", _]}        -> :elimination
      {_, _, ["Game won by " <> _p]}        -> :game_won
      {_, _, [_, " occupied ", _, _]}       -> :occupy
      {_, _, [_, " ended " <> _rest]}       -> :turn_end
      {_, _, [_, " started " <> _rest]}     -> :turn_start
      {_, _, [_, " fortified " <> _rest]}   -> :unit_fortify
      {_, _, [_, " placed " <> _rest]}      -> :unit_place
      {_, _, [_, " received " <> _rest]}    -> :unit_receive
      {_, _, [_, " transferred " <> _rest]} -> :unit_transfer
      _ ->
        IO.inspect action
        nil
    end
  end

  defp to_event({"tr", [{"class", "row_dark"}], children}) do
    [[id], [dt], [seat], [action], ad, dd, bmod, al, dl, _] = Enum.map(children, fn {_, _, val} -> val end)

    {att, def} = get_sides(action)

    %Event{
      id: String.to_integer(id),
      type: get_type(action),
      player: get_player(action),
      datetime: dt,
      seat: String.to_integer(seat),
      action: action,
      bonus_units: get_bonus_units(action),
      trade_units: get_trade_units(action),
      attacker: att,
      defender: def,
      ad: get_hd(ad),
      dd: get_hd(dd),
      bmod: bmod,
      al: get_hd(al) |> String.to_integer(),
      dl: get_hd(dl) |> String.to_integer()
    }
  end

  defp get_player(action) do
    case action do
      {_, _, [{_, _, [name]}, _]}    -> name
      {_, _, [{_, _, [name]}, _, _]} -> name
      {_, _, [{_, _, [name]}, _, _, _]} -> name
      _ -> nil
    end
  end

  defp get_trade_units(action) do
    case action do
      {_, _, [{_, _, [_name]}, " traded cards " <> rest]} ->
        rest
        |> String.split(" ")
        |> Enum.at(2)
        |> String.to_integer
      _ -> nil
    end
  end

  defp get_bonus_units(action) do
    case action do
      {_, _, [{_, _, [_name]}, " received elimination bonus of " <> rest]} ->
        rest
        |> String.split(" ")
        |> hd
        |> String.to_integer
      {_, _, [{_, _, [_name]}, " received " <> rest]} ->
        rest
        |> String.split(" ")
        |> hd
        |> String.to_integer
      _ -> nil
    end 
  end

  defp get_sides({_, _, [{_, _, [attacker]}, " attacked ", {_, _, [defender]}, _]}), do: {attacker, defender}
  defp get_sides({_, _, [{_, _, [attacker]}, " attacked ", _, _]}), do: {attacker, nil}
  defp get_sides({_, _, [{_, _, [attacker]}, " occupied ", {_, _, [defender]}, _]}), do: {attacker, defender}
  defp get_sides({_, _, [{_, _, [attacker]}, " occupied ", _, _]}), do: {attacker, nil}
  defp get_sides(_), do: {nil, nil}

  defp get_hd([]), do: "0"
  defp get_hd([el]), do: el
end