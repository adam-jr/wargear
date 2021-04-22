defmodule Wargear.ViewScreen do
  def get_players(game_id) do
    case HTTPoison.get("http://www.wargear.net/games/view/#{game_id}") do
      {:ok, %{body: body}} ->
        Floki.parse_document!(body)
        |> Floki.find("div#playerstats")
        |> get_player_rows()
        |> Enum.map(&Player.from_table_row/1)

      _ ->
        []
    end
  end

  def get_player_rows([]), do: []

  def get_player_rows(div) do
    [{"div", [{"id", "playerstats"}], table}] = div
    [{"table", [{"class", "data ranking centered"}], tbody}] = table
    [{"tbody", [], [_hd | player_rows]}] = tbody
    player_rows
  end
end
