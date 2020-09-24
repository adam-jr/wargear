defmodule Wargear.ViewScreen do

  defmodule Player do
    defstruct name: nil, current: false, eliminated: false
  end

  def get_players(game_id) do
    %{body: body} = HTTPoison.get!("http://www.wargear.net/games/view/#{game_id}")

    Floki.parse_document!(body) 
    |> Floki.find("div#playerstats")
    |> get_player_rows()
    |> Enum.map(&to_player/1)
  end

  def to_player(tr) do
    %Player{
      name: player_name(tr),
      current: current_turn?(tr),
      eliminated: eliminated?(tr)
    }
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