defmodule Wargear.Events.Handler do

  defmodule Dao do
    alias Wargear.Dets
    @table :event_info
    @key :last_viewed_event_id
    def update(event_id), do: Dets.insert(@table, @key, event_id)
    def get, do: Dets.lookup(@table, @key, 0)
  end

  use GenServer
  alias Wargear.Events.Dao, as: EventsDao

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
    end
    
    # state = update(state, event_action)

    schedule_work(state)

    {:noreply, state}
  end

  defp schedule_work(:active), do: Process.send_after(self(), :work, @active_interval)

  defp handle(events) do
    player =
      Enum.filter(events, &(&1.type == :turn_start))
      |> Enum.at(-1)
      |> Map.get(:player)

    Wargear.Messenger.notify_of_turn(player)
  end

  defp update_last_viewed_event(events) do
    Enum.at(events, -1)
    |> Map.get(:id)
    |> Dao.update()
  end

end