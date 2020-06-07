defmodule Wargear do
  use Application

  def start(_,_) do
    import Supervisor.Spec
    
    children = [
      # supervisor(Wargear.Repo, []),
      # supervisor(Wargear.Endpoint, []),
      worker(Wargear.Periodically, [run: Application.get_env(:wargear, :periodically)[:run]])
    ]
    
    opts = [strategy: :one_for_one, name: Wargear.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
