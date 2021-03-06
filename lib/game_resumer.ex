defmodule Wargear.GameResumer do
  use GenServer
  alias Wargear.Daos.GamesInProgressDao, as: Dao
  require Logger

  def child_spec(opts \\ []) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :temporary
    }
  end

  def start_link(opts \\ []), do: GenServer.start_link(__MODULE__, opts)

  def init(_opts) do
    send(self(), :resume_games)
    {:ok, nil, 1000}
  end

  def handle_info(:resume_games, _) do
    Wargear.Daos.GamesInProgressDao.remove_all()
    |> Enum.map(&resume_game/1)

    {:stop, :normal, nil}
  end

  defp resume_game(%{game_id: game_id, total_fog: total_fog}) do
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
