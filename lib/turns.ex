defmodule Wargear.Turns do

  defmodule Turn do
    defstruct id: nil, type: nil, player: nil, datetime: nil, seat: nil, action: nil, bonus_units: nil, trade_units: nil, attacker: nil, defender: nil, ad: nil, dd: nil, bmod: nil, al: nil, dl: nil
  end

  def get_current_player do
    %{body: body} = HTTPoison.get!("http://www.wargear.net/games/view/731327")

    Floki.parse_document!(body) 
    |> Floki.find("div#playerstats")
    |> get_player_rows()
    |> Enum.find(&current_turn?/1)
    |> current_player()
  end

  def get_player_rows(div) do
    [{"div", [{"id", "playerstats"}], table}] = div
    [{"table",  [{"class", "data ranking centered"}], tbody}] = table
    [{"tbody", [], [_hd|player_rows]}] = tbody
    player_rows
  end

  def current_turn?(tr) do
    {"tr", [], tds} = tr
    clock_td = Enum.at(tds, -2)

    case clock_td do
      {"td", [], [{"span", [{"id", _clock_num}], []}]} -> false
      _ -> true
    end
  end

  def current_player(tr) do
    {"tr", [], tds} = tr
    player_td = Enum.at(tds, 2)
    {"td", _, [{"a", _, [player_name]}]} = player_td
    player_name
  end

end