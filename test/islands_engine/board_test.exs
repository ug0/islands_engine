defmodule IslandsEngine.BoardTest do
  use ExUnit.Case
  doctest IslandsEngine.Board

  alias IslandsEngine.{Board, Island, Coordinate}

  setup do
    board = Board.new()
    {:ok, square_coordinate} = Coordinate.new(1, 1)
    {:ok, square} = Island.new(:square, square_coordinate)

    board = Board.position_island(board, :square, square)
    {:ok, %{board: board}}
  end

  test "postion new island", %{board: board} do
    {:ok, dot_coordinate} = Coordinate.new(3, 3)
    {:ok, dot} = Island.new(:dot, dot_coordinate)

    assert %{
      square: %Island{},
      dot: %Island{},
    } = Board.position_island(board, :dot, dot)

  end

  test "can not position island overlaps", %{board: board} do
    {:ok, dot_coordinate} = Coordinate.new(1, 1)
    {:ok, dot} = Island.new(:dot, dot_coordinate)

    assert {:error, :overlapping_island} = Board.position_island(board, :dot, dot)
  end

  test "make guesses", %{board: board} do
    {:ok, dot_coordinate} = Coordinate.new(5, 5)
    {:ok, dot} = Island.new(:dot, dot_coordinate)
    board = Board.position_island(board, :dot, dot)

    {:ok, guess_coordinate} = Coordinate.new(10, 10)
    assert {:miss, :none, :no_win, board} = Board.guess(board, guess_coordinate)

    {:ok, guess_coordinate} = Coordinate.new(1, 1)
    assert {:hit, :none, :no_win, board} = Board.guess(board, guess_coordinate)

    {:ok, guess_coordinate} = Coordinate.new(1, 2)
    assert {:hit, :none, :no_win, board} = Board.guess(board, guess_coordinate)

    {:ok, guess_coordinate} = Coordinate.new(2, 1)
    assert {:hit, :none, :no_win, board} = Board.guess(board, guess_coordinate)

    {:ok, guess_coordinate} = Coordinate.new(2, 2)
    assert {:hit, :square, :no_win, board} = Board.guess(board, guess_coordinate)

    {:ok, guess_coordinate} = Coordinate.new(5, 5)
    assert {:hit, :dot, :win, board} = Board.guess(board, guess_coordinate)
  end
end
