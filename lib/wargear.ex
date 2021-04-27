defmodule Wargear do
  use Application
  require Logger

  def start(_, _) do
    import Supervisor.Spec

    Logger.info("Starting Wargear <3")

    children = [
      supervisor(Wargear.Endpoint, []),
      worker(Wargear.Discord.Poller, run: true),
      worker(Wargear.GameResumer, run: true),
      {DynamicSupervisor, name: GameSupervisor, strategy: :one_for_one}
    ]

    opts = [strategy: :one_for_one, name: Wargear.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
