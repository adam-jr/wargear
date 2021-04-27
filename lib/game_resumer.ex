defmodule Wargear.GameResumer do
  use GenServer
  alias Wargear.Daos.GamesInProgressDao, as: Dao
  require Logger

  def start_link(_), do: GenServer.start_link(__MODULE__, nil)

  def init(_) do
    send(self(), :resume_games)
    {:ok, nil}
  end

  def handle_info(:resume_games, _) do
    Wargear.Daos.GamesInProgressDao.remove_all()
    |> Enum.map(&resume_game/1)

    {:stop, "done", nil}
  end

  defp resume_game(%{game_id: game_id, total_fog: total_fog} = game) do
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
  end
end
