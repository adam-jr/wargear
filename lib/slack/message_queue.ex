defmodule Wargear.Slack.MessageQueue do
  use GenServer
  require Logger

  def start_link(params) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(default) do
    {:ok, default}
  end

  def enqueue(messages) do
    GenServer.call(self(), {:enqueue, messages})
  end

  def handle_call({:enqueue, messages}, state) do
    GenServer.call(self(), :dequeue)
    {:noreply, state ++ messages}
  end

  def handle_call(:dequeue, []), do: {:noreply, []}

  def handle_call(:dequeue, [hd | rest]) do
    # handle_message(hd)
    GenServer.call(self(), :dequeue)
    {:noreply, rest}
  end
end
