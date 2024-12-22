# Part 1 of the puzzle

defmodule KeypadConundrum do
  @numeric_transitions %{
    {{"1", "4"}, "^"},
    {{"0", "A"}, ">"},
    {{"0", "8"}, "^^^"},
    {{"2", "8"}, "^^"},
    {{"1", "1"}, ""},
    {{"A", "4"}, "^^<<"},
    {{"1", "5"}, ">^"},
    {{"A", "A"}, ""},
    {{"2", "7"}, "<^^"},
    {{"6", "3"}, "v"},
    {{"8", "2"}, "vv"},
    {{"3", "1"}, "<<"},
    {{"8", "7"}, "<"},
    {{"A", "9"}, "^^^"},
    {{"2", "2"}, ""},
    {{"4", "3"}, "v>>"},
    {{"8", "0"}, "vvv"},
    {{"9", "7"}, "<<"},
    {{"1", "0"}, ">v"},
    {{"4", "8"}, ">^"},
    {{"3", "8"}, "<^^"},
    {{"8", "3"}, "vv>"},
    {{"9", "6"}, "v"},
    {{"7", "5"}, "v>"},
    {{"6", "A"}, "vv"},
    {{"3", "3"}, ""},
    {{"0", "4"}, "^^<"},
    {{"8", "A"}, "vvv>"},
    {{"4", "5"}, ">"},
    {{"4", "4"}, ""},
    {{"5", "2"}, "v"},
    {{"4", "A"}, ">>vv"},
    {{"A", "0"}, "<"},
    {{"7", "6"}, "v>>"},
    {{"2", "9"}, ">^^"},
    {{"1", "7"}, "^^"},
    {{"A", "3"}, "^"},
    {{"7", "0"}, ">vvv"},
    {{"9", "A"}, "vvv"},
    {{"0", "3"}, ">^"},
    {{"2", "4"}, "<^"},
    {{"7", "2"}, "vv>"},
    {{"5", "9"}, ">^"},
    {{"6", "2"}, "v<"},
    {{"1", "3"}, ">>"},
    {{"8", "4"}, "v<"},
    {{"0", "2"}, "^"},
    {{"9", "2"}, "vv<"},
    {{"A", "6"}, "^^"},
    {{"A", "5"}, "<^^"},
    {{"1", "9"}, ">>^^"},
    {{"6", "1"}, "v<<"},
    {{"0", "5"}, "^^"},
    {{"4", "0"}, ">vv"},
    {{"2", "5"}, "^"},
    {{"1", "6"}, ">>^"},
    {{"3", "0"}, "v<"},
    {{"A", "8"}, "<^^^"},
    {{"0", "0"}, ""},
    {{"A", "1"}, "^<<"},
    {{"6", "9"}, "^"},
    {{"4", "1"}, "v"},
    {{"9", "3"}, "vv"},
    {{"3", "A"}, "v"},
    {{"6", "7"}, "<<^"},
    {{"7", "3"}, "vv>>"},
    {{"9", "4"}, "v<<"},
    {{"7", "4"}, "v"},
    {{"A", "7"}, "^^^<<"},
    {{"5", "3"}, "v>"},
    {{"7", "1"}, "vv"},
    {{"5", "5"}, ""},
    {{"8", "8"}, ""},
    {{"9", "8"}, "<"},
    {{"3", "9"}, "^^"},
    {{"6", "4"}, "<<"},
    {{"A", "2"}, "<^"},
    {{"3", "2"}, "<"},
    {{"5", "6"}, ">"},
    {{"0", "1"}, "^<"},
    {{"9", "1"}, "vv<<"},
    {{"6", "5"}, "<"},
    {{"6", "6"}, ""},
    {{"3", "6"}, "^"},
    {{"1", "2"}, ">"},
    {{"2", "6"}, ">^"},
    {{"8", "1"}, "vv<"},
    {{"7", "A"}, ">>vvv"},
    {{"4", "2"}, "v>"},
    {{"2", "1"}, "<"},
    {{"8", "5"}, "v"},
    {{"7", "9"}, ">>"},
    {{"0", "7"}, "^^^<"},
    {{"9", "0"}, "vvv<"},
    {{"0", "9"}, ">^^^"},
    {{"4", "6"}, ">>"},
    {{"1", "A"}, ">>v"},
    {{"9", "9"}, ""},
    {{"1", "8"}, ">^^"},
    {{"6", "0"}, "vv<"},
    {{"4", "9"}, ">>^"},
    {{"5", "0"}, "vv"},
    {{"5", "7"}, "<^"},
    {{"7", "8"}, ">"},
    {{"2", "3"}, ">"},
    {{"3", "7"}, "<<^^"},
    {{"5", "4"}, "<"},
    {{"6", "8"}, "<^"},
    {{"8", "6"}, "v>"},
    {{"9", "5"}, "v<"},
    {{"2", "0"}, "v"},
    {{"2", "A"}, "v>"},
    {{"5", "1"}, "v<"},
    {{"3", "5"}, "<^"},
    {{"7", "7"}, ""},
    {{"5", "8"}, "^"},
    {{"5", "A"}, "vv>"},
    {{"3", "4"}, "<<^"},
    {{"4", "7"}, "^"},
    {{"0", "6"}, ">^^"},
    {{"8", "9"}, ">"}
  }

  @directional_transitions %{
    {{"<", "<"}, ""},
    {{"<", ">"}, ">>"},
    {{"<", "A"}, ">>^"},
    {{"<", "^"}, ">^"},
    {{"<", "v"}, ">"},
    {{">", "<"}, "<<"},
    {{">", ">"}, ""},
    {{">", "A"}, "^"},
    {{">", "^"}, "<^"},
    {{">", "v"}, "<"},
    {{"A", "<"}, "v<<"},
    {{"A", ">"}, "v"},
    {{"A", "A"}, ""},
    {{"A", "^"}, "<"},
    {{"A", "v"}, "v<"},
    {{"^", "<"}, "v<"},
    {{"^", ">"}, "v>"},
    {{"^", "A"}, ">"},
    {{"^", "^"}, ""},
    {{"^", "v"}, "v"},
    {{"v", "<"}, "<"},
    {{"v", ">"}, ">"},
    {{"v", "A"}, ">^"},
    {{"v", "^"}, "^"},
    {{"v", "v"}, ""}
  }

  @numeric_keypad %{
    "7" => {0, 0},
    "8" => {0, 1},
    "9" => {0, 2},
    "4" => {1, 0},
    "5" => {1, 1},
    "6" => {1, 2},
    "1" => {2, 0},
    "2" => {2, 1},
    "3" => {2, 2},
    "0" => {3, 1},
    "A" => {3, 2}
  }

  @directional_keypad %{
    "^" => {0, 1},
    "A" => {0, 2},
    "<" => {1, 0},
    "v" => {1, 1},
    ">" => {1, 2}
  }

  @direction_vectors [
    {0, 1},
    {0, -1},
    {-1, 0},
    {1, 0}
  ]

  @direction_symbols %{
    {0, 1} => ">",
    {0, -1} => "<",
    {-1, 0} => "^",
    {1, 0} => "v"
  }

  @infinity 999_999_999

  def solve do
    # read input
    inputs =
      IO.read(:eof)
      |> String.split("\n", trim: true)

    # pre-processing
    numeric_map = @numeric_transitions
    directional_map = @directional_transitions

    # solve
    inputs
    |> Enum.map(fn input -> get_shortest_input_sequence(input, numeric_map, directional_map) end)
    |> Enum.map(fn {input, result} ->
      input_number =
        input
        |> String.replace("A", "")
        |> String.to_integer()

      result_length = String.length(result)

      {input_number, result_length}
    end)
    |> Enum.map(fn {input_number, result_length} -> input_number * result_length end)
    |> Enum.sum()
  end

  defp are_vectors_parallel?({v1_row, v1_col}, {v2_row, v2_col}) do
    abs(v1_row) == abs(v2_row) and abs(v1_col) == abs(v2_col)
  end

  defp vector_pair_score(v1, v2) do
    parallel_score = if are_vectors_parallel?(v1, v2), do: 0, else: 1

    100 + 10 * parallel_score
  end

  defp build_transition_map(symbol_map) do
    for from_key <- Map.keys(symbol_map), to_key <- Map.keys(symbol_map) do
      from = Map.get(symbol_map, from_key)
      to = Map.get(symbol_map, to_key)

      {_, _, result_path} =
        symbol_map
        |> dijkstra(from)
        |> Map.get(to)

      shortest_transition =
        result_path
        |> Enum.reverse()
        |> Enum.chunk_every(2, 1, :discard)
        |> Enum.map(&coordinate_diffs/1)
        |> Enum.map(fn direction -> Map.get(@direction_symbols, direction) end)
        |> Enum.join()

      {{from_key, to_key}, shortest_transition}
    end
    |> Map.new()
  end

  defp get_input_sequence(input, symbol_map, start_symbol) do
    (start_symbol <> input)
    |> String.graphemes()
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [from, to] -> {from, to} end)
    |> Enum.map(fn key -> Map.get(symbol_map, key) end)
    |> Enum.map(fn part -> part <> "A" end)
    |> Enum.join()
  end

  defp get_shortest_input_sequence(input, numeric_transition_map, directional_transition_map) do
    sequence_1 = get_input_sequence(input, numeric_transition_map, "A")
    sequence_2 = get_input_sequence(sequence_1, directional_transition_map, "A")
    sequence_3 = get_input_sequence(sequence_2, directional_transition_map, "A")

    {input, sequence_3}
  end

  defp dijkstra(map, from) do
    {from_char, _} = Enum.find(map, fn {_, pos} -> pos == from end)

    search_map =
      Enum.map(map, fn {char, pos} ->
        {pos, {char, @infinity, []}}
      end)
      |> Map.new()
      |> Map.put(from, {from_char, 0, [from]})

    do_dijkstra(search_map, Map.new())
  end

  defp do_dijkstra(search_map, visited) when map_size(search_map) == 0 do
    visited
  end

  defp do_dijkstra(search_map, visited) do
    {key = {row, col}, val = {_, _, path}} =
      search_map
      |> Enum.sort_by(fn {_, {_, cost, _}} -> cost end)
      |> hd()

    popped_search_map = Map.delete(search_map, key)

    possible_targets =
      @direction_vectors
      |> Enum.map(fn {d_row, d_col} -> {row + d_row, col + d_col} end)
      |> Enum.filter(fn target -> Map.has_key?(search_map, target) end)

    new_search_map =
      Enum.reduce(possible_targets, popped_search_map, fn target, acc ->
        {t_char, t_cost, _} = Map.get(acc, target)

        candidate_path = [target | path] |> IO.inspect()
        new_cost = path_cost(candidate_path) |> IO.inspect()

        if new_cost <= t_cost do
          Map.put(acc, target, {t_char, new_cost, candidate_path})
        else
          acc
        end
      end)

    new_visited = Map.put(visited, key, val)

    do_dijkstra(new_search_map, new_visited)
  end

  defp path_cost(path) do
    number_of_steps = length(path) - 1

    number_of_direction_changes =
      path
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(&coordinate_diffs/1)
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [v1, v2] ->
        if are_vectors_parallel?(v1, v2), do: 0, else: 1
      end)
      |> Enum.sum()

    1000 * number_of_steps + 10 * number_of_direction_changes
  end

  defp coordinate_diffs([{f_row, f_col}, {t_row, t_col}]) do
    {t_row - f_row, t_col - f_col}
  end
end

KeypadConundrum.solve()
|> IO.inspect()
