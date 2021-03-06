defmodule Wargear.Events.Poller do
  use GenServer
  alias Wargear.Events
  require Logger

  # 10 minutes
  @idle_interval 10 * 60 * 1000
  # 1 minute
  @active_interval 1 * 60 * 1000
  @init_interval 1000

  @init {:init, 0}
  # {mode, num_cycles}
  @active {:active, 0}
  # {mode, num_cycles}
  @idle {:idle, 0}

  @active_cycle_limit 60

  defmodule State do
    defstruct game_id: nil, cycle: nil
  end

  def start_link(game_id: game_id, total_fog: total_fog) do
    unless total_fog, do: GenServer.start_link(__MODULE__, game_id)
  end

  def init(game_id) do
    Logger.info("Initializing #{__MODULE__} with game_id #{game_id}")

    Logger.info(
      "#{__MODULE__} will poll every #{@active_interval / 1000} seconds when active and every #{
        @idle_interval / (60 * 1000)
      } minutes when idle"
    )

    state = %State{game_id: game_id, cycle: @init}
    schedule_work(state)
    {:ok, state}
  end

  def handle_info(:work, %State{game_id: game_id} = state) do
    schedule_work(state)

    action =
      Events.get(game_id)
      |> Events.Service.insert_new(game_id)

    state = update(state, action)

    {:noreply, state}
  end

  defp schedule_work(%State{cycle: {:init, _any}}),
    do: Process.send_after(self(), :work, @init_interval)

  defp schedule_work(%State{cycle: {:active, _any}}),
    do: Process.send_after(self(), :work, @active_interval)

  defp schedule_work(%State{cycle: {:idle, _any}}),
    do: Process.send_after(self(), :work, @idle_interval)

  defp update(state, update) do
    case {update, state.cycle} do
      {:update, _} ->
        Map.put(state, :cycle, @active)

      {:noop, {:active, @active_cycle_limit}} ->
        Map.put(state, :cycle, @idle)

      {:noop, {:active, n}} ->
        Map.put(state, :cycle, {:active, n + 1})

      {:noop, _idle_or_init} ->
        Map.put(state, :cycle, @idle)
    end
  end
end
