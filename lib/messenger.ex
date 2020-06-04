defmodule Wargear.Messenger do

  def notify_of_turn(player_name) do
    url = "https://hooks.slack.com/services/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"
    headers = [{"Content-Type", "application/json"}]
    body = Poison.encode!(%{text: "<#{slack_name(player_name)}>, it's your turn"})
    HTTPoison.post!(url, body, headers)
  end

  def slack_name(player_name) do
    case player_name do
      "adam jormp jomp"    -> "@atom.r"
      "pants off vant hof" -> "@cvanthof85"
      "Kyjygyfyf"          -> "@json"
      "Hesh"               -> "@heshman45"
      "dandodd"            -> "@dan"
      "Tallness"           -> "@zach"
      "ZachClash"          -> "@zachclash"
    end
  end

end