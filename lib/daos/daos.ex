defmodule Wargear.Daos do
  defmodule LastViewedEventIdDao do
    alias Wargear.Dets
    @prefix "last_event_id"
    def key(game_id), do: @prefix <> "_" <> to_string(game_id)
    def update(event_id, game_id), do: Dets.insert(key(game_id), event_id)

    def get(game_id) do
      case Dets.lookup(key(game_id)) do
        nil -> 0
        id -> id
      end
    end
  end

  defmodule CurrentTurnDao do
    alias Wargear.Dets
    @prefix "current_turn"
    def key(game_id), do: @prefix <> "_" <> to_string(game_id)
    def update(current_turn, game_id), do: Dets.insert(key(game_id), current_turn)
    def get(game_id), do: Dets.lookup(key(game_id))
  end

  defmodule DeadDao do
    alias Wargear.Dets
    @prefix "dead_players"
    def key(game_id), do: @prefix <> "_" <> to_string(game_id)
    def update(dead_player_names, game_id), do: Dets.insert(key(game_id), dead_player_names)

    def get(game_id) do
      case Dets.lookup(key(game_id)) do
        nil -> []
        dead -> dead
      end
    end
  end

  defmodule LastReadSlackTimestampDao do
    alias Wargear.Dets
    @prefix "last_read_slack_timestamp"
    def key, do: @prefix
    def update(timestamp), do: Dets.insert(key(), timestamp)
    def get, do: Dets.lookup(key())
  end
end
