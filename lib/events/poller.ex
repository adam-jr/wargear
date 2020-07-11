defmodule Wargear.Events.Poller do
  use GenServer
  alias Wargear.Events
  require Logger

  @idle_interval  10 * 60 * 1000 # 10 minutes
  @active_interval 1 * 60 * 1000 # 1 minute
  @initial_state {:active, 0} # {mode, cycles}
  @idle_state    {:idle, 0}   # {mode, cycles}

  def start_link({:run, run}) do
    GenServer.start_link(__MODULE__, run)
  end

  def init(false), do: {:ok, nil}
  def init(true) do
    schedule_work(@initial_state)
    {:ok, @initial_state}
  end

  def reset do
    Events.Dao.reset()
    Events.Handler.HandlerDao.reset()
    Events.Handler.CurrentTurnDao.reset()
    Events.Handler.DeadDao.reset()
  end

  def handle_info(:work, state) do
    Logger.info("Polling for new events...")
    event_action = update_events()

    state = update(state, event_action)

    schedule_work(state)

    {:noreply, state}
  end

  defp schedule_work({:active, _any}), do: Process.send_after(self(), :work, @active_interval)
  defp schedule_work({:idle,   _any}), do: Process.send_after(self(), :work, @idle_interval)

  defp update_events do
    events = Events.get()
    players = Warger.ViewScreen.get_players()
    Events.Dao.update(events)
  end

  defp update(state, event_action) do
    case {event_action, state} do
      {:update, _}           -> @initial_state
      {:noop, {:active, 60}} -> @idle_state
      {:noop, {:active, n}}  -> {:active, n + 1}
      {:noop, _idle_state}   -> @idle_state
    end
  end

end