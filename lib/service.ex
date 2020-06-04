defmodule Wargear.Service do  
  
  # def run do
  #   players = Map.values(get_players())
  #   text = build_text(players)
  #   # %{body: body} = HTTPoison.post!(
  #   #   "https://hooks.slack.com/services/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",
  #   #   "{\"body\": \"test\"}", 
  #   #   [{"Content-Type", "application/json"}
  #   #   )
  # end

  # cell lengths
  @left 22
  @mid 14
  @right 16

  def build_text(players) do
    header = "|" <> center("player", @left) <> "|" <> 
                center("units", @mid) <> "|" <> center("territories", @right) <> "|"
    rows = Enum.map(players, &build_line/1)
    [header|rows] |> Enum.join("\n")
  end

  def build_line(player) do
    first_cell = "|#{String.pad_trailing("  " <> player.name, @left)}|"
    second_cell = "#{center("#{player.units}", @mid)}|"
    third_cell = "#{center("#{player.territories}", @right)}|"
    first_cell <> second_cell <> third_cell
  end

  def center(text, length) do
    rem = length - String.length(text)
    left = Integer.floor_div(rem, 2)
    String.pad_leading(text, left + String.length(text))
    |> String.pad_trailing(length)
  end
end