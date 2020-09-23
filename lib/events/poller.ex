defmodule Wargear.Events.Poller do
  use GenServer
  alias Wargear.Events
  require Logger

  @idle_interval  10 * 60 * 1000 # 10 minutes
  @active_interval 1 * 60 * 1000 # 1 minute

  @active {:active, 0} # {mode, num_cycles}
  @idle    {:idle, 0}  # {mode, num_cycles}

  @active_cycle_limit 60

  defmodule State do
    defstruct game_id: nil, cycle: nil
  end

  def start_link([game_id: game_id, total_fog: total_fog]) do
    if total_fog, do: GenServer.start_link(__MODULE__, game_id)
  end

  def init(game_id) do
    Logger.info("Initializing Events Poller...")
    state = %State{game_id: game_id, cycle: @active}
    schedule_work(state)
    {:ok, state}
  end

  def handle_info(:work, %State{game_id: game_id} = state) do
    schedule_work(state)

    Logger.info("Polling for new events...")

    update_action =
      Events.get(game_id)
      |> Events.Dao.update(game_id)

    state = update(state, update_action)

    {:noreply, state}
  end

  defp schedule_work(%State{cycle: {:active, _any}}), do: Process.send_after(self(), :work, @active_interval)
  defp schedule_work(%State{cycle: {:idle,   _any}}), do: Process.send_after(self(), :work, @idle_interval)

  defp update(state, update) do
    case {update, state.cycle} do
      {:update, _}           ->
        Logger.info("Event Poller Switching to active state!")
        Map.put(state, :cycle, @active)
      {:noop, {:active, @active_cycle_limit}} ->
        Logger.info("#{@active_cycle_limit} cycles with no new events. Event Poller Switching to idle state.")
        Map.put(state, :cycle, @idle)
      {:noop, {:active, n}}  -> Map.put(state, :cycle, {:active, n + 1})
      {:noop, _idle_state}   -> Map.put(state, :cycle, @idle)
    end
  end

end