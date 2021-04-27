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

  defmodule SlackCursorDao do
    alias Wargear.Dets
    @prefix "last_read_slack_timestamp"
    def key, do: @prefix
    def update(timestamp), do: Dets.insert(key(), timestamp)
    def get, do: Dets.lookup(key())
  end

  defmodule DiscordCursorDao do
    alias Wargear.Dets
    @prefix "last_read_discord_message_id"
    def key(channel_id), do: @prefix <> "_" <> to_string(channel_id)
    def update(message_id, channel_id), do: Dets.insert(key(channel_id), message_id)
    def get(channel_id), do: Dets.lookup(key(channel_id))
  end

  defmodule GamesInProgressDao do
    alias Wargear.Dets
    @prefix "games_in_progress"
    def key, do: @prefix

    def add(game) do
      games = get()
      Dets.insert(key(), [game | games])
    end

    def remove(game_id) do
      games = get() |> Enum.reject(fn g -> g.game_id == game_id end)
      Dets.insert(key(), games)
    end

    def get do
      case Dets.lookup(key()) do
        nil -> []
        games -> games
      end
    end
  end
end
