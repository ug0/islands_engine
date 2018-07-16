defmodule IslandsEngine.GuessesTest do
  use ExUnit.Case
  doctest IslandsEngine.Guesses

  alias IslandsEngine.{Coordinate, Guesses}

  setup do
    {:ok, coordinate} = Coordinate.new(1, 1)
    {:ok, guesses: Guesses.new(), coordinate: coordinate}
  end

  test "add hit coordinate", %{guesses: guesses, coordinate: coordinate} do
    new_guesses = Guesses.add(guesses, :hit, coordinate)
    assert MapSet.member?(new_guesses.hits, coordinate)
  end

  test "add missed coordinate", %{guesses: guesses, coordinate: coordinate} do
    new_guesses = Guesses.add(guesses, :miss, coordinate)
    assert MapSet.member?(new_guesses.misses, coordinate)
  end
end
