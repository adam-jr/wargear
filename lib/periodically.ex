defmodule Wargear.Periodically do
  use GenServer
  alias Wargear.Events

  @interval 1 * 60 * 1000 # 1 minute

  def start_link({:run, run}) do
    GenServer.start_link(__MODULE__, run)
  end

  def init(false), do: {:ok, false}
  def init(true) do
    schedule_work() # Schedule work to be performed at some point
    {:ok, true}
  end

  def handle_info(:work, state) do
    schedule_work() # Reschedule once more

    update_events()

    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, @interval)
  end

  defp update_events do
    Events.get()
    |> Events.Dao.insert()
  end

end