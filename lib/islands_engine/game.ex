defmodule IslandsEngine.Game do
  use GenServer, start: {__MODULE__, :start_link, []}, restart: :transient

  alias IslandsEngine.{Board, Guesses, Rules, Island, Coordinate}

  @players [:player1, :player2]
  @timeout 60*60*24*1000 # 1 day

  def start_link(name) when is_binary(name) do
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  def add_player(game, name) when is_binary(name) do
    GenServer.call(game, {:add_player, name})
  end

  def position_island(game, player, key, row, col) when player in @players do
    GenServer.call(game, {:position_island, player, key, row, col})
  end

  def set_islands(game, player) when player in @players do
    GenServer.call(game, {:set_islands, player})
  end

  def guess_coordinate(game, player, row, col) when player in @players do
    GenServer.call(game, {:guess_coordinate, player, row, col})
  end

  def via_tuple(name), do: {:via, Registry, {Registry.Game, name}}

  def init(name) do
    player1 = %{name: name, board: Board.new(), guesses: Guesses.new()}
    player2 = %{name: nil, board: Board.new(), guesses: Guesses.new()}
    {:ok, %{player1: player1, player2: player2, rules: Rules.new()}, @timeout}
  end

  def handle_call({:add_player, name}, _from, state) do
    with {:ok, rules} <- Rules.check(state.rules, :add_player) do
      state
      |> update_player2_name(name)
      |> update_rules(rules)
      |> reply_success(:ok)
    else
      :error -> {:reply, :error, state}
    end
  end

  def handle_call({:position_island, player, key, row, col}, _from, state) do
    with {:ok, rules} <- Rules.check(state.rules, {:position_islands, player}),
         {:ok, coordinate} <- Coordinate.new(row, col),
         {:ok, island} <- Island.new(key, coordinate),
         %{} = board <- Board.position_island(player_board(state, player), key, island) do
      state
      |> update_board(player, board)
      |> update_rules(rules)
      |> reply_success(:ok)
    else
      :error -> {:reply, :error, state}
      {:error, :invalid_coordinate} -> reply_error(state, :invalid_coordinate)
      {:error, :invalid_island_type} -> reply_error(state, :invalid_island_type)
      {:error, :overlapping_island} -> reply_error(state, :overlapping_island)
    end
  end

  def handle_call({:set_islands, player}, _from, state) do
    with {:ok, rules} <- Rules.check(state.rules, {:set_islands, player}),
         true <- Board.all_islands_positioned?(board = player_board(state, player)) do
      state
      |> update_rules(rules)
      |> reply_success({:ok, board})
    else
      :error -> reply_error(state)
      false -> reply_error(state, :not_all_islands_positioned)
    end
  end

  def handle_call({:guess_coordinate, player, row, col}, _from, state) do
    opponent = opponent(player)
    opponent_board = player_board(state, opponent)

    with {:ok, rules} <- Rules.check(state.rules, {:guess_coordinate, player}),
    {:ok, coordinate} <- Coordinate.new(row, col),
    {hit_or_miss, forested_island, win_status, opponent_board} <- Board.guess(opponent_board, coordinate),
    {:ok, rules} <- Rules.check(rules, {:win_check, win_status}) do
      state
      |> update_board(opponent, opponent_board)
      |> update_guesses(player, hit_or_miss, coordinate)
      |> update_rules(rules)
      |> reply_success({hit_or_miss, forested_island, win_status})
    else
      :error -> reply_error(state)
      {:error, :invalid_coordinate} -> reply_error(state, :invalid_coordinate)
    end
  end

  def handle_info(:timeout, state) do
    {:stop, {:shutdown, :timeout}, state}
  end

  defp player_board(state, player), do: Map.get(state, player).board
  defp opponent(:player1), do: :player2
  defp opponent(:player2), do: :player1

  defp update_player2_name(state, name) do
    put_in(state.player2.name, name)
  end

  defp update_board(state, player, board) do
    Map.update!(state, player, &%{&1 | board: board})
  end

  defp update_guesses(state, player, hit_or_miss, coordinate) do
    update_in(state[player].guesses, &Guesses.add(&1, hit_or_miss, coordinate))
  end

  defp update_rules(state, rules), do: %{state | rules: rules}

  defp reply_success(state, reply), do: {:reply, reply, state, @timeout}
  defp reply_error(state), do: {:reply, :error, state, @timeout}
  defp reply_error(state, reason), do: {:reply, {:error, reason}, state, @timeout}
end
