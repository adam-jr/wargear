defmodule Wargear.Timex do
  def trading_hours?(datetime) do
    weekday?(datetime) and between_0930_and_1600?(datetime)
  end

  def weekday?(datetime) do
    to_end_of_week =
      datetime
      |> Timex.to_date()
      |> Timex.days_to_end_of_week()

    to_end_of_week >= 2 and to_end_of_week <= 6
  end

  def between_0930_and_1600?(datetime) do
    time_0930 = Timex.set(datetime, hour: 9, minute: 30, second: 0) |> DateTime.truncate(:second)
    time_1600 = Timex.set(datetime, hour: 16, minute: 0, second: 0) |> DateTime.truncate(:second)

    Timex.between?(datetime, time_0930, time_1600)
  end
end
