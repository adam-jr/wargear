defmodule Wargear.Events.Handler do
  use GenServer
  alias Wargear.Events.Dao, as: EventsDao
  alias Wargear.ViewScreen
  alias Wargear.Daos.{HandlerDao, CurrentTurnDao, DeadDao}
  require Logger

  @interval 1000 # 1 second

  defmodule State do
    defstruct game_id: nil
  end

  def start_link([game_id: game_id]) do
    GenServer.start_link(__MODULE__, game_id)
  end

  def init(game_id) do
    Logger.info("Initializing event store watcher, polling every #{@interval / 1000} second(s)...")
    schedule_work()
    {:ok, %State{game_id: game_id}}
  end

  def handle_info(:work, %State{game_id: game_id} = state) do
    last_viewed_event_id = HandlerDao.last_event_id(game_id)

    case EventsDao.get(last_viewed_event_id + 1, nil, game_id) do
      [] -> :noop
      events ->
        update_last_viewed_event(events, game_id)
        perform_view_screen_updates(game_id)
    end
    
    schedule_work()

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

  defp schedule_work, do: Process.send_after(self(), :work, @interval)

  defp update_last_viewed_event(events, game_id) do
    Enum.at(events, -1)
    |> Map.get(:id)
    |> (fn id ->
      Logger.info("Setting last viewed event id = #{id}...")
      id
    end).()
    |> HandlerDao.update(game_id)
  end

end