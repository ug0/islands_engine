defmodule IslandsEngine.CoordinateTest do
  use ExUnit.Case
  doctest IslandsEngine.Coordinate

  alias IslandsEngine.Coordinate

  test "new valid coordinate" do
    assert IslandsEngine.hello() == :world
    for row <- 1..10, col <- 1..10 do
      assert {:ok, %Coordinate{row: ^row, col: ^col}} = Coordinate.new(row, col)
    end
  end

  test "invalid coordinate" do
    assert {:error, :invalid_coordinate} == Coordinate.new(nil, nil)
    assert {:error, :invalid_coordinate} == Coordinate.new(0, 1)
    assert {:error, :invalid_coordinate} == Coordinate.new(1, 11)
  end
end
