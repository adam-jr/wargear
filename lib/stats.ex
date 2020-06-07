defmodule Wargear.Stats do
  alias Wargear.Player

  @initialized_players %{
    "adam jormp jomp"    => %Player{name: "adam jormp jomp"},
    "pants off vant hof" => %Player{name: "pants off vant hof"},
    "Kyjygyfyf"          => %Player{name: "Kyjygyfyf"},
    "Hesh"               => %Player{name: "Hesh"},
    "dandodd"            => %Player{name: "dandodd"},
    "Tallness"           => %Player{name: "Tallness"},
    "ZachClash"          => %Player{name: "ZachClash"}
  }

  def get_standings do
    Enum.reduce(Wargear.Events.get(), @initialized_players, fn event, players -> 
      case event.type do
        :unit_receive -> add_units(players, event.player, event.bonus_units)
        :card_trade -> add_units(players, event.player, event.trade_units)
        :attack ->
          players
          |> kill_units(event.defender, event.dl)
          |> kill_units(event.attacker, event.al)
        :occupy ->
          players
          |> exchange_territory(event.attacker, event.defender)
        _ -> players
      end
    end)
  end

  defp add_units(%{} = players, player_name, num_units) do
    Map.update!(players, player_name, fn p ->
      Map.put(p, :units, p.units + num_units)
    end)
  end

  defp kill_units(%{} = players, nil, _num_units), do: players
  defp kill_units(%{} = players, player_name, num_units) do
    Map.update!(players, player_name, fn p ->
      Map.put(p, :units, p.units - num_units)
    end)
  end

  defp exchange_territory(%{} = players, attacker_name, nil) do
    players
    |> Map.update!(attacker_name, fn p -> Map.put(p, :territories, p.territories + 1) end)
  end

  defp exchange_territory(%{} = players, attacker_name, defender_name) do
    players
    |> Map.update!(attacker_name, fn p -> Map.put(p, :territories, p.territories + 1) end)
    |> Map.update!(defender_name, fn p -> Map.put(p, :territories, p.territories - 1) end)
  end

end