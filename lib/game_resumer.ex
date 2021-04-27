defmodule Wargear.GameResumer do
  use GenServer
  alias Wargear.Daos.GamesInProgressDao, as: Dao
  require Logger

  def start_link(_), do: GenServer.start_link(__MODULE__, nil)

  def init(_) do
    Logger.info("Initializing #{__MODULE__}")
    send(self(), :resume_games)
    {:ok, nil, 1000}
  end

  def handle_info(:resume_games, _) do
    Wargear.Daos.GamesInProgressDao.remove_all()
    |> Enum.map(&resume_game/1)

    {:stop, "done", nil} |> IO.inspect
  end

  defp resume_game(%{game_id: game_id, total_fog: total_fog} = game) do
    Logger.info("#{__MODULE__} resuming game #{game_id}")

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

    Dao.add(%{
      game_id: game_id,
      total_fog: total_fog,
      poller: poller_pid,
      handler: handler_pid
    })
  end
end
