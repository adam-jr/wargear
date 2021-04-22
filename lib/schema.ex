defmodule Wargear.Schema do
  use Absinthe.Schema

  query do
  end

  mutation do
    field :new_game, type: :boolean do
      arg(:game_id, non_null(:string))
      arg(:total_fog, non_null(:boolean))
      resolve(&Wargear.Resolver.Game.new/2)
    end

    field :kill_game, type: :boolean do
      arg(:game_id, non_null(:string))
      resolve(&Wargear.Resolver.Game.kill/2)
    end
  end
end
