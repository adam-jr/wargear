defmodule Wargear do
  use Application
  require Logger

  def start(_, _) do
    Logger.info("Starting Wargear <3")

    children = [
      Wargear.Endpoint,
      Wargear.Discord.Poller,
      Wargear.GameResumer,
      {DynamicSupervisor, name: GameSupervisor, strategy: :one_for_one},
    ]

    opts = [strategy: :one_for_one, name: Wargear.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
