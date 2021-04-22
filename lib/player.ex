defmodule Wargear.Player do
  defstruct name: nil, current: false, eliminated: false, slack_name: nil, slack_id: nil

  def from_table_row(tr) do
    name = player_name(tr)

    %__MODULE__{
      name: name,
      current: current_turn?(tr),
      eliminated: eliminated?(tr),
      slack_name: slack_name(name),
      slack_id: slack_id(name)
    }
  end

  defp slack_name(player_name) do
    case player_name do
      "adam jormp jomp" -> "@atom.r"
      "pants off vant hof" -> "@cvanthof85"
      "Kyjygyfyf" -> "@json"
      "Hesh" -> "@heshman45"
      "dandodd" -> "@dan"
      "Tallness" -> "@zach"
      "ZachClash" -> "@zachclash"
    end
  end

  def slack_id(player_name) do
    case player_name do
      "adam jormp jomp" -> "U1LBVMGUU"
      "pants off vant hof" -> "U1LKV0HBP"
      "Kyjygyfyf" -> ""
      "Hesh" -> "U1LL0GQN6"
      "dandodd" -> "U1LDNSKFE"
      "Tallness" -> "U1LHW86EQ"
      "ZachClash" -> ""
    end
  end

  def current_turn?(tr) do
    {"tr", [], tds} = tr
    clock_td = Enum.at(tds, -2)

    case clock_td do
      {"td", [], [{"span", [{"id", _clock_num}], [_hd | _tl]}]} ->
        true

      {"td", [], [{"span", [{"id", _clock_num}], []}]} ->
        false

      {"td", [],
       [
         {"span", [{"title", "AutoBoot Pending"}, {"class", "boot_pending"}], [" "]},
         {"span", [{"id", _clock_num}], []}
       ]} ->
        false

      _ ->
        IO.inspect("Unexpected current turn tr shape #{__MODULE__}:")
        IO.inspect(tr)
        false
    end
  end

  def eliminated?(tr) do
    {"tr", [], tds} = tr
    eliminated_td = Enum.at(tds, -3)

    case eliminated_td do
      {"td", [], ["Eliminated"]} -> true
      _ -> false
    end
  end

  def player_name(tr) do
    {"tr", [], tds} = tr
    player_td = Enum.at(tds, 2)
    {"td", _, [{"a", _, [player_name]}]} = player_td
    player_name
  end
end
