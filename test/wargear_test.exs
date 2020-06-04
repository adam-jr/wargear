defmodule WargearTest do
  use ExUnit.Case
  doctest Wargear

  test "greets the world" do
    assert Wargear.hello() == :world
  end
end
