defmodule Wargear.Events.Handler do
  # watches stored events and triggers actions on receipt of new
  defmodule HandlerDao do
    alias Wargear.Dets
    @table :event_info
    @key :last_viewed_event_id
    def update(event_id), do: Dets.insert(@table, @key, event_id)
    def last_event_id, do: Dets.lookup(@table, @key, 0)
  end

  defmodule CurrentTurnDao do
    alias Wargear.Dets
    @table :turn_info
    @key :current_player
    def update(player), do: Dets.insert(@table, @key, player)
    def get, do: Dets.lookup(@table, @key, nil)
  end

  defmodule DeadDao do
    alias Wargear.Dets
    @table :turn_info
    @key :dead_players
    def update(players), do: Dets.insert(@table, @key, players)
    def get, do: Dets.lookup(@table, @key, [])
  end

  use GenServer
  alias Wargear.Events.Dao, as: EventsDao
  alias Wargear.ViewScreen

  @active_interval 1000 # 1 second
  @initial_state :active

  def start_link({:run, run}) do
    GenServer.start_link(__MODULE__, run)
  end

  def init(false), do: {:ok, nil}
  def init(true) do
    schedule_work(@initial_state)
    {:ok, @initial_state}
  end

  def handle_info(:work, state) do
    last_viewed_event_id = HandlerDao.last_event_id()

    case EventsDao.get(last_viewed_event_id + 1) do
      [] -> :noop
      events ->
        update_last_viewed_event(events)
        handle(events)
        perform_view_screen_updates()
    end
    
    schedule_work(state)

    {:noreply, state}
  end

  defp perform_view_screen_updates do
    players = ViewScreen.get_players()

    current_player_update(players)
    eliminated_players_update(players)
  end

  def eliminated_players_update(players) do
    current_dead = Enum.filter(players, &(&1.eliminated)) |> Enum.map(&(&1.name)) |> IO.inspect
    last_dead = DeadDao.get() |> IO.inspect

    case Enum.reject(current_dead, &(&1 in last_dead)) do
      [new_dead] ->
        DeadDao.update(current_dead)
        Wargear.Messenger.notify_newly_dead(new_dead)
      [] -> :noop
      multiple -> DeadDao.update(current_dead)
    end
  end

  defp current_player_update(players) do
    [current] = Enum.filter(players, &(&1.current))
    last_current = CurrentTurnDao.get()

    if current.name != last_current do
      CurrentTurnDao.update(current.name)
      Wargear.Messenger.notify_of_turn(current.name)
    end
  end

  defp schedule_work(:active), do: Process.send_after(self(), :work, @active_interval)

  defp handle(events) do
    # player =
    #   Enum.filter(events, &(&1.type == :turn_start))
    #   |> Enum.at(-1)
    #   |> Map.get(:player)

    # Wargear.Messenger.notify_of_turn(player)
    events
  end

  defp update_last_viewed_event(events) do
    Enum.at(events, -1)
    |> Map.get(:id)
    |> HandlerDao.update()
  end

end