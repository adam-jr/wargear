defmodule Wargear.Events.Handler do
  use GenServer
  alias Wargear.Events.Dao, as: EventsDao
  alias Wargear.ViewScreen
  alias Wargear.Daos.{LastViewedEventIdDao, CurrentTurnDao, DeadDao}
  require Logger

  @interval_reg 1000 # 1 second
  @interval_total_fog 1000 * 60

  defmodule State do
    defstruct game_id: nil, total_fog: false
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init([game_id: game_id, total_fog: total_fog]) do
    Logger.info("Initializing event handler...")
    state = %State{game_id: game_id, total_fog: total_fog}
    schedule_work(state)
    {:ok, state}
  end

  def handle_info(:work_reg, %State{game_id: game_id} = state) do
    case EventsDao.get(game_id) do
      [] -> :noop
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
  end

  def eliminated_players_update(players, game_id) do
    current_dead = Enum.filter(players, &(&1.eliminated)) |> Enum.map(&(&1.name))
    last_dead = DeadDao.get(game_id)

    case Enum.reject(current_dead, &(&1 in last_dead)) do
      [new_dead] ->
        Logger.info("Notifying of #{current_dead}'s death... :('")
        DeadDao.update(current_dead, game_id)
        Wargear.Messenger.notify_newly_dead(new_dead, game_id)
      [] -> :noop
      _multiple -> DeadDao.update(current_dead, game_id)
    end
  end

  defp current_player_update(players, game_id) do
    [current] = Enum.filter(players, &(&1.current))
    last_current = CurrentTurnDao.get(game_id)

    if current.name != last_current do
      Logger.info("Notifying #{current.name} of turn...")
      CurrentTurnDao.update(current.name, game_id)
      Wargear.Messenger.notify_of_turn(current.name, game_id)
    end
  end

  defp schedule_work(%State{total_fog: false}), do: Process.send_after(self(), :work_reg, @interval_reg)
  defp schedule_work(%State{total_fog: true}), do: Process.send_after(self(), :work_total_fog, @interval_total_fog)

  defp update_last_viewed_event(events, game_id) do
    Enum.at(events, -1)
    |> Map.get(:id)
    |> (fn id ->
      id
    end).()
    |> LastViewedEventIdDao.update(game_id)
  end

end