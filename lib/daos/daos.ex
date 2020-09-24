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
    def update(event_id, game_id), do: Dets.insert(key(game_id), event_id)
    def get(game_id), do: Dets.lookup(key(game_id))
  end

  defmodule DeadDao do
    alias Wargear.Dets
    @prefix "dead_players"
    def key(game_id), do: @prefix <> "_" <> to_string(game_id)
    def update(event_id, game_id), do: Dets.insert(key(game_id), event_id)
    def get(game_id) do
      case Dets.lookup(key(game_id)) do
        nil -> []
        dead -> dead
      end
    end
  end
  
end