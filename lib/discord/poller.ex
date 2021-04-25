defmodule Wargear.Discord.Poller do
  use GenServer
  require Logger

  alias Wargear.Daos

  @active_interval 15 * 1000
  @channel :trade_alerts

  def start_link(params) do
    GenServer.start_link(__MODULE__, params)
  end

  def init(_) do
    Logger.info("Initializing #{__MODULE__}")

    Logger.info("#{__MODULE__} will poll every #{@active_interval / 1000} seconds")

    Process.send_after(self(), :work, 1000)

    {:ok, nil}
  end

  def handle_info(:work, state) do
    if Wargear.Timex.trading_hours?(Timex.now("America/New_York")) do
      id = Daos.DiscordCursorDao.get(@channel)

      case Wargear.Discord.new_messages(channel: @channel, id: id) do
        [] ->
          :no_activity

        [latest | _rest] = messages ->
          # to parse into alerts, do:
          # messages |> Enum.filter(fn m -> String.contains?(m.content, "ALERT") end) |> Enum.map(&Wargear.Nishant.TradeAlert.from_message/1)
          Daos.DiscordCursorDao.update(latest.id, @channel)
      end
    end

    schedule_work()
    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.info("Unexpected Message: #{__MODULE__}: #{inspect(msg)}")
    {:noreply, state}
  end

  defp schedule_work,
    do: Process.send_after(self(), :work, @active_interval)
end
