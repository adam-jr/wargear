defmodule Wargear.Periodically do
  use GenServer
  alias Wargear.Turns

  @table :periodical_values
  @lookup_key :last_notified_turn_id
  @filename 'periodically.txt'
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

    do_work()

    {:noreply, state}
  end

  defp do_work do
    turns = Turns.get(0, nil)
    focus = Enum.at(turns, -2)

    if (focus.type == :turn_start and is_overdue?(focus.datetime) and not already_notified?(focus.id)) do
      send_notification(focus)
    end
  end

  def send_notification(turn) do
    :dets.open_file(@table, [{:file, @filename}])
    :dets.insert(@table, {@lookup_key, turn.id})
    :dets.close(@table)
    Wargear.Messenger.notify_of_turn(turn.player)
  end

  def is_overdue?(datetime) do
    horizon = 
      NaiveDateTime.utc_now()
      |> Timex.to_datetime() 
      |> Timex.shift(hours: -4) #-4 hours for utc shift...

    case Timex.parse(datetime, "%B %-d, %Y %-I:%M %p", :strftime) do
      {:ok, naive} -> Timex.to_datetime(naive) |> Timex.before?(horizon)
      {:error, _err} -> false
    end
  end

  def already_notified?(current_id) do
    :dets.open_file(@table, [{:file, @filename}])

    dets_id =  
      case :dets.lookup(@table, @lookup_key) do
        [{@lookup_key, turn_id}] -> turn_id
        _ -> nil
      end

    :dets.close(@table)

    current_id == dets_id
  end

  defp schedule_work() do
    Process.send_after(self(), :work, @interval)
  end

end