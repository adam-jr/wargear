defmodule Wargear.Resolver.Game do

  # defmodule GameDao do
  #   alias Wargear.Dets
  #   @table :game_info
  #   @key :game_id
  #   @initial_state nil
  #   def update(game_id), do: Dets.insert(@table, @key, game_id)
  #   def get, do: Dets.lookup(@table, @key, @initial_state)
  #   def reset, do: Dets.insert(@table, @key, @initial_state)
  # end
  
  def new(%{game_id: _game_id}, _info) do
    # poller_spec = { Wargear.Events.Poller, [game_id: 743165] }
    # handler_spec = { Wargear.Events.Handler, [game_id: 743165] }
    # {:ok, poller} = DynamicSupervisor.start_child(GameSupervisor, poller_spec)
    # # Dets insert Handlergame_id -> pid
    # {:ok, handler} = DynamicSupervisor.start_child(GameSupervisor, handler_spec)
    # # Dets insert game_id -> [poller, handler]
    {:ok, true}
  end

  def kill(%{game_id: _game_id}, _info) do
    # Dets.lookup 
    # handler = {Wargear.Events.Handler, {:run, Application.get_env(:wargear, :events_handler)[:run]} }
    {:ok, true}
  end
end