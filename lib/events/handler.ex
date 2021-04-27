defmodule Wargear.Events.Handler do
  use GenServer
  alias Wargear.Events.Dao, as: EventsDao
  alias Wargear.ViewScreen
  alias Wargear.Daos.{LastViewedEventIdDao, CurrentTurnDao, DeadDao}
  require Logger

  # 1 second
  @interval_reg 1000
  @interval_total_fog 1000 * 60

  defmodule State do
    defstruct game_id: nil, total_fog: false
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(game_id: game_id, total_fog: total_fog) do
    Logger.info("Initializing #{__MODULE__} with game_id #{game_id}")

    if total_fog do
      Logger.info("#{__MODULE__} will notify players every #{@interval_total_fog / 1000} seconds")
    else
      Logger.info("#{__MODULE__} will notify players every #{@interval_reg / 1000} second(s)")
    end

    state = %State{game_id: game_id, total_fog: total_fog}
    schedule_work(state)
    {:ok, state}
  end

  def handle_info(:work_reg, %State{game_id: game_id} = state) do
    case EventsDao.get(game_id) do
      [] ->
        :noop

      events ->
        update_last_viewed_event(events, game_id)
        perform_view_screen_updates(game_id)
    end

    schedule_work(state)

    {:noreply, state}
  end

  def handle_info(:work_total_fog, %State{game_id: game_id} = state) do
    perform_view_screen_updates(game_id)

    schedule_work(state)

    {:noreply, state}
  end

  defp perform_view_screen_updates(game_id) do
    players = ViewScreen.get_players(game_id)

    current_player_update(players, game_id)
    eliminated_players_update(players, game_id)
    winner_winner_update(players, game_id)
  end

  def eliminated_players_update([], _), do: Logger.error("unable to update eliminated players")

  def eliminated_players_update(players, game_id) do
    current_dead = Enum.filter(players, & &1.eliminated)
    last_dead = DeadDao.get(game_id)

    case Enum.reject(current_dead, &(&1.name in last_dead)) do
      [] ->
        :noop

      newly_dead ->
        DeadDao.update(Enum.map(current_dead, & &1.name), game_id)
        Enum.each(newly_dead, fn d -> Wargear.Messenger.notify_newly_dead(d, game_id) end)
    end
  end

  defp current_player_update([], _), do: Logger.error("unable to update current player")

  defp current_player_update(players, game_id) do
    current_list = Enum.filter(players, & &1.current)
    last_current = CurrentTurnDao.get(game_id)

    should_update =
      length(current_list) == 1 and hd(current_list) |> Map.get(:name) != last_current

    if should_update do
      current = hd(current_list)
      Logger.info("Notifying #{current.name} of turn...")
      CurrentTurnDao.update(current.name, game_id)
      Wargear.Messenger.notify_of_turn(current, game_id)
    end
  end

  defp winner_winner_update([], _), do: Logger.error("unable to update winner")

  defp winner_winner_update(players, game_id) do
    case Enum.find(players, & &1.winner) do
      nil ->
        nil

      player ->
        Wargear.Messenger.announce_winner(player, game_id)
        Wargear.Daos.GamesInProgressDao.remove(game_id)
        DynamicSupervisor.terminate_child(GameSupervisor, self())
    end
  end

  defp schedule_work(%State{total_fog: false}),
    do: Process.send_after(self(), :work_reg, @interval_reg)

  defp schedule_work(%State{total_fog: true}),
    do: Process.send_after(self(), :work_total_fog, @interval_total_fog)

  defp update_last_viewed_event(events, game_id) do
    Enum.at(events, -1)
    |> Map.get(:id)
    |> (fn id ->
          id
        end).()
    |> LastViewedEventIdDao.update(game_id)
  end
end
