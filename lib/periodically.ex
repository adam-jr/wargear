defmodule Wargear.Periodically do
  use GenServer
  alias Wargear.Turns
  alias Turns.Turn

  @table :turn_start
  @key :last_turn_start
  @filename 'turn_start.txt'
  @interval 120 * 1000 #seconds

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work() # Schedule work to be performed at some point
    {:ok, state}
  end

  def handle_info(:work, state) do
    schedule_work() # Reschedule once more

    last = Turns.latest_turn_start()

    :dets.open_file(@table, [{:file, @filename}])

    dets =  
      case :dets.lookup(@table, @key) do
        [{@key, %Turn{} = turn}] -> turn
        _ -> %Turn{}
      end

    if (last.id != dets.id) do
      IO.inspect "updating dets, notifying player"
      :dets.insert(@table, {@key, last})
    end

    :dets.close(@table)

    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, @interval)
  end

end