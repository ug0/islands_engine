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

  test "guess a island hit or miss" do
    {:ok, hit_coordinate} = Coordinate.new(1, 1)
    {:ok, island} = Island.new(:square, hit_coordinate)
    {:ok, miss_coordinate} = Coordinate.new(3, 3)

    assert :miss = Island.guess(island, miss_coordinate)
    assert {:hit, updated_island} = Island.guess(island, hit_coordinate)
    assert MapSet.member?(updated_island.hit_coordinates, hit_coordinate)
  end

  test "judge if an island is forested" do
    {:ok, coordinate} = Coordinate.new(1, 1)
    {:ok, island} = Island.new(:square, coordinate)
    coordinates = for r <- 1..2, c <- 1..2 do
      {:ok, coordinate} = Coordinate.new(r, c)
      coordinate
    end
    updated_island = Enum.reduce(coordinates, island, fn coordinate, updated_island ->
      refute Island.forested?(updated_island)
      {:hit, updated_island} = Island.guess(updated_island, coordinate)
      updated_island
    end)
    assert Island.forested?(updated_island)
  end
end
