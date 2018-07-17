defmodule IslandsEngine.RulesTest do
  use ExUnit.Case
  doctest IslandsEngine.Rules

  alias IslandsEngine.Rules

  setup do
    {:ok, rules: Rules.new()}
  end

  test "check action :add_player", %{rules: rules} do
    assert {:ok, %Rules{state: :players_set}} = Rules.check(rules, :add_player)
    assert :error == Rules.check(%Rules{rules | state: :players_set }, :add_player)
  end

  test "check action :position_islands", %{rules: rules} do
    assert :error == Rules.check(rules, {:position_islands, :player1})
    rules = %Rules{rules | state: :players_set, player2: :islands_set}
    assert {:ok, rules} == Rules.check(rules, {:position_islands, :player1})
    assert :error == Rules.check(rules, {:position_islands, :player2})
  end

  test "check action :set_islands", %{rules: rules} do
    rules = %Rules{rules | state: :players_set}
    assert {:ok, rules = %Rules{rules | player1: :islands_set}} == Rules.check(rules, {:set_islands, :player1})
    assert {:ok, %Rules{rules | state: :player1_turn, player2: :islands_set}} == Rules.check(rules, {:set_islands, :player2})
  end

  test "through the whole game", %{rules: rules} do
    assert {:ok, %Rules{state: :players_set} = rules} = Rules.check(rules, :add_player)
    assert {:ok, %Rules{
      state: :players_set,
      player1: :islands_not_set,
      player2: :islands_not_set
    } = rules} = Rules.check(rules, {:position_islands, :player1})

    assert {:ok, %Rules{
      state: :players_set,
      player1: :islands_not_set,
      player2: :islands_not_set
    } = rules} = Rules.check(rules, {:position_islands, :player2})

    assert {:ok, %Rules{
      state: :players_set,
      player1: :islands_set,
      player2: :islands_not_set
    } = rules} = Rules.check(rules, {:set_islands, :player1})

    assert {:ok, %Rules{
      state: :players_set,
      player1: :islands_set,
      player2: :islands_not_set
    } = rules} = Rules.check(rules, {:position_islands, :player2})

    assert {:ok, %Rules{
      state: :player1_turn,
      player1: :islands_set,
      player2: :islands_set
    } = rules} = Rules.check(rules, {:set_islands, :player2})

    assert :error == Rules.check(rules, {:guess_coordinate, :player2})
    assert {:ok, %Rules{state: :player2_turn} = rules} = Rules.check(rules, {:guess_coordinate, :player1})
    assert :error == Rules.check(rules, {:guess_coordinate, :player1})
    assert {:ok, %Rules{state: :player1_turn} = rules} = Rules.check(rules, {:guess_coordinate, :player2})
    assert {:ok, rules} = Rules.check(rules, {:win_check, :no_win})
    assert {:ok, %Rules{state: :player2_turn} = rules} = Rules.check(rules, {:guess_coordinate, :player1})
    assert {:ok, %Rules{state: :game_over} = rules} = Rules.check(rules, {:win_check, :win})
    assert :error  == Rules.check(rules, {:guess_coordinate, :player1})
    assert :error  == Rules.check(rules, {:guess_coordinate, :player2})
  end

  test "invalid action is unpermitted", %{rules: rules} do
    assert :error == Rules.check(rules, :invalid_action)
  end
end
