defmodule Wargear do
  use Application
  require Logger

  def start(_,_) do
    import Supervisor.Spec

    Logger.info("Starting Wargear!!!")
    
    children = [
      # supervisor(Wargear.Repo, []),
      supervisor(Wargear.Endpoint, []),
      {DynamicSupervisor, name: GameSupervisor, strategy: :one_for_one},
      # worker(Wargear.Events.Poller, [run: Application.get_env(:wargear, :events_poller  )[:run]]),
      # worker(Wargear.Events.Handler, [run: Application.get_env(:wargear, :events_handler)[:run]])
    ]
    
    opts = [strategy: :one_for_one, name: Wargear.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
