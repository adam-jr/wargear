defmodule Wargear.Daos do

  defmodule HandlerDao do
    alias Wargear.Dets
    @table :last_viewed_event_id
    @initial_state 0
    def update(event_id, game_id) do
      IO.inspect(event_id)
      Dets.insert(@table, game_id, event_id)
    end
    def last_event_id(game_id), do: Dets.lookup(@table, game_id, @initial_state)
  end

  defmodule CurrentTurnDao do
    alias Wargear.Dets
    @table :current_player
    @initial_state nil
    def update(player, game_id), do: Dets.insert(@table, game_id, player)
    def get(game_id), do: Dets.lookup(@table, game_id, @initial_state)
  end

  defmodule DeadDao do
    alias Wargear.Dets
    @table :dead_players
    @initial_state []
    def update(players, game_id), do: Dets.insert(@table, game_id, players)
    def get(game_id), do: Dets.lookup(@table, game_id, @initial_state)
  end
  
end