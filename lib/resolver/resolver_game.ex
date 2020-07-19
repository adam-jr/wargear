defmodule Wargear.Resolver.Game do
  alias Wargear.Events
  
  def new_game(%{game_id: id}, _info) do
      Events.set_game(id)
      Events.Poller.reset()
      {:ok, true}
  end
end