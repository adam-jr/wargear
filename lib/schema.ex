defmodule Wargear.Schema do
  use Absinthe.Schema
  
  query do
  end
  
  mutation do
    field :new_game, type: :boolean do
      arg :game_id, non_null(:string)

      resolve &Wargear.Resolver.Game.new_game/2
    end
  end
  
end