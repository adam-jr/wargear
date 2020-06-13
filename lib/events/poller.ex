defmodule Wargear.Events.Poller do
  use GenServer
  alias Wargear.Events
  require Logger

  @idle_interval  10 * 60 * 1000 # 10 minutes
  @active_interval 1 * 60 * 1000 # 1 minute
  @initial_state {:active, 0} # {mode, cycles}
  @idle_state    {:idle, 0}   # {mode, cycles}
  @active_cycle_limit 60

  def start_link({:run, run}) do
    GenServer.start_link(__MODULE__, run)
  end

  def init(false), do: {:ok, nil}
  def init(true) do
    Logger.info("Initializing Events Poller...")
    schedule_work(@initial_state)
    {:ok, @initial_state}
  end

  def handle_info(:work, state) do
    schedule_work(state)

    Logger.info("Polling for new events...")
    event_action = update_events()

    state = update(state, event_action)

    {:noreply, state}
  end

  defp schedule_work({:active, _any}), do: Process.send_after(self(), :work, @active_interval)
  defp schedule_work({:idle,   _any}), do: Process.send_after(self(), :work, @idle_interval)

  defp update_events do
    events = Events.get()
    Events.Dao.update(events)
  end

  defp update(state, event_action) do
    case {event_action, state} do
      {:update, _}           ->
        Logger.info("Event Poller Switching to active state!")
        @initial_state
      {:noop, {:active, @active_cycle_limit}} ->
        Logger.info("#{@active_cycle_limit} cycles with no new events. Event Poller Switching to idle state.")
        @idle_state
      {:noop, {:active, n}}  -> {:active, n + 1}
      {:noop, _idle_state}   -> @idle_state
    end
  end

end