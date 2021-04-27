defmodule Wargear.Resolver.Game do
  def new(%{game_id: game_id, total_fog: total_fog}, _info) do
    unless total_fog do
      poller_spec = {Wargear.Events.Poller, [game_id: game_id, total_fog: total_fog]}

      {:ok, _poller} =
        DynamicSupervisor.start_child(GameSupervisor, poller_spec) |> IO.inspect(label: "poller")
    end

    handler_spec = {Wargear.Events.Handler, [game_id: game_id, total_fog: total_fog]}

    {:ok, _handler} =
      DynamicSupervisor.start_child(GameSupervisor, handler_spec) |> IO.inspect(label: "handler")

    Wargear.Daos.GamesInProgressDao.add(%{game_id: game_id, total_fog: total_fog})
    {:ok, true}
  end

  def kill(%{game_id: _game_id}, _info) do
    # Dets.lookup 
    # handler = {Wargear.Events.Handler, {:run, Application.get_env(:wargear, :events_handler)[:run]} }
    {:ok, true}
  end
end
