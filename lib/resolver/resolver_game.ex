defmodule Wargear.Resolver.Game do
  def new(%{game_id: game_id, total_fog: total_fog}, _info) do
    poller_pid =
      if total_fog do
        nil
      else
        poller_spec = {Wargear.Events.Poller, [game_id: game_id, total_fog: total_fog]}
        {:ok, pid} = DynamicSupervisor.start_child(GameSupervisor, poller_spec)
        pid
      end

    handler_spec = {Wargear.Events.Handler, [game_id: game_id, total_fog: total_fog]}
    {:ok, handler_pid} = DynamicSupervisor.start_child(GameSupervisor, handler_spec)

    Wargear.Daos.GamesInProgressDao.add(%{
      game_id: game_id,
      total_fog: total_fog,
      poller: poller_pid,
      handler: handler_pid
    })

    {:ok, true}
  end

  def kill(%{game_id: _game_id}, _info) do
    # Dets.lookup 
    # handler = {Wargear.Events.Handler, {:run, Application.get_env(:wargear, :events_handler)[:run]} }
    {:ok, true}
  end
end
