defmodule IslandsEngine.IslandTest do
  use ExUnit.Case
  doctest IslandsEngine.Island

  alias IslandsEngine.{Coordinate, Island}

  test "detect two islands are whether overlaps or not" do
    {:ok, coordinate} = Coordinate.new(1, 1)
    {:ok, square} = Island.new(:square, coordinate)
    {:ok, coordinate} = Coordinate.new(2, 2)
    {:ok, dot} = Island.new(:dot, coordinate)
    {:ok, coordinate} = Coordinate.new(3, 1)
    {:ok, l_shape} = Island.new(:l_shape, coordinate)

    assert Island.overlaps?(square, dot)
    refute Island.overlaps?(square, l_shape)
  end
end
