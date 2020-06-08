defmodule Wargear.Events.Handler do

  defmodule Dao do
    alias Wargear.Dets
    @table :event_info
    @key :last_viewed_event_id
    def update(event_id), do: Dets.insert(@table, @key, event_id)
    def get, do: Dets.lookup(@table, @key, 0)
  end

  defmodule CurrentTurnDao do
    alias Wargear.Dets
    @table :turn_info
    @key :current_player
    def update(player), do: Dets.insert(@table, @key, player)
    def get, do: Dets.lookup(@table, @key, nil)
  end

  use GenServer
  alias Wargear.Events.Dao, as: EventsDao
  alias Wargear.Turns

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
    last_viewed_event_id = Dao.get()

    case EventsDao.get(last_viewed_event_id + 1) do
      [] -> :noop
      events ->
        update_last_viewed_event(events)
        handle(events)
        notify_current_player()
    end
    
    # state = update(state, event_action)

    schedule_work(state)

    {:noreply, state}
  end

  defp notify_current_player do
    current = Turns.get_current_player()
    last_current = CurrentTurnDao.get()

    if current != last_current do
      CurrentTurnDao.update(current)
      Wargear.Messenger.notify_of_turn(current)
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
    |> Dao.update()
  end

end