defmodule Wargear.SlackReader do
  use GenServer
  require Logger

  alias Wargear.Daos

  # 1 minute
  @idle_interval 60 * 1000
  # 1 second
  @active_interval 1000

  # {mode, num_cycles}
  @active {:active, 0}
  # {mode, num_cycles}
  @idle {:idle, 0}

  @active_cycle_limit 60 * 10

  defmodule State do
    defstruct cycle: nil
  end

  def start_link(params) do
    IO.inspect params, label: "what the fuck"
    GenServer.start_link(__MODULE__, params)
  end

  def init(_) do
    state = update(%State{}, :init)
    schedule_work(state)
    {:ok, state}
  end

  def handle_info(:work, state) do
    timestamp = Daos.LastReadSlackTimestampDao.get()

    message_status =
      case Wargear.Slack.new_messages(channel: :spitegear, timestamp: timestamp) do
        [] ->
          :no_activity

        [latest | _rest] = _messages ->
          Daos.LastReadSlackTimestampDao.update(latest.timestamp)
          # Slack.MessageQueue.enqueue(Enum.reverse(messages))
          :new_messages
      end

    schedule_work(state)
    {:noreply, update(state, message_status)}
  end

  defp schedule_work(%State{cycle: {:active, _any}}),
    do: Process.send_after(self(), :work, @active_interval)

  defp schedule_work(%State{cycle: {:idle, _any}}),
    do: Process.send_after(self(), :work, @idle_interval)

  defp update(state, status) do
    case {status, state.cycle} do
      {:new_messages, _} ->
        Logger.info("SlackReader is in active state!")
        Map.put(state, :cycle, @active)

      {:no_activity, {:active, @active_cycle_limit}} ->
        Logger.info(
          "#{@active_cycle_limit} cycles with no new events. SlackReader switching to idle state."
        )

        Map.put(state, :cycle, @idle)

      {:no_activity, {:active, n}} ->
        Map.put(state, :cycle, {:active, n + 1})

      {:no_activity, _idle_state} ->
        Map.put(state, :cycle, @idle)

      {:init, _} ->
        Logger.info("SlackReader initiating in active state!")
        Map.put(state, :cycle, @active)
    end
  end
end
