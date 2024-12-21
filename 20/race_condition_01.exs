# Part 1 of the puzzle

defmodule RaceCondition do
  @direction_vectors [
    {0, 1},
    {1, 0},
    {0, -1},
    {-1, 0}
  ]

  @infinity 999_999_999

  def solve do
    # read and parse input
    map_input =
      IO.read(:eof)
      |> String.split("\n", trim: true)

    parsed_map =
      map_input
      |> Enum.with_index()
      |> Enum.flat_map(&parse_line/1)
      |> Map.new()

    # solve original problem, without cheating
    preprocessed_map =
      parsed_map
      |> eliminate_dead_ends()

    result_map =
      preprocessed_map
      |> dijkstra()

    {end_key, :end} =
      Enum.find(parsed_map, fn {_, object} -> object == :end end)

    {original_result, _} =
      Map.get(result_map, end_key)

    # count cheats which make the path shorter
    num_rows = length(map_input)
    num_cols = map_input |> hd() |> String.length()

    walls_inside_boundary =
      parsed_map
      |> Enum.filter(fn {{row, col}, _} ->
        row >= 1 and row <= num_rows - 2 and col >= 1 and col <= num_cols - 2
      end)
      |> Enum.filter(fn {_, object} -> object == :wall end)

    for wall <- walls_inside_boundary, direction <- @direction_vectors do
      {wall_position = {row, col}, :wall} = wall
      {d_row, d_col} = direction

      target = {row + d_row, col + d_col}
      t_object = Map.get(parsed_map, target)

      cond do
        t_object == :wall ->
          original_result

        true ->
          steps_with_cheat(result_map, original_result, wall_position, direction)
      end
    end
    |> Enum.count(fn val -> original_result - val >= 100 end)
  end

  defp steps_with_cheat(result_map, full_distance, wall_positon, cheat_direction) do
    {row, col} = wall_positon
    {d_row, d_col} = cheat_direction
    cheat_direction_inverse = {0 - d_row, 0 - d_col}

    # lowest before
    lowest_before =
      @direction_vectors
      |> Enum.filter(fn direction -> direction != cheat_direction end)
      |> Enum.map(fn {d_r, d_c} -> {row + d_r, col + d_c} end)
      |> Enum.filter(fn target -> Map.has_key?(result_map, target) end)
      |> Enum.map(fn target -> Map.get(result_map, target) end)
      |> Enum.map(fn {travel_length, _} -> travel_length end)
      |> Enum.min(fn -> @infinity end)

    # lowest after
    lowest_after =
      @direction_vectors
      |> Enum.filter(fn direction -> direction != cheat_direction_inverse end)
      |> Enum.map(fn {d_r, d_c} -> {row + d_r, col + d_c} end)
      |> Enum.filter(fn target -> Map.has_key?(result_map, target) end)
      |> Enum.map(fn target -> Map.get(result_map, target) end)
      |> Enum.map(fn {travel_length, _} -> travel_length end)
      |> Enum.min(fn -> @infinity end)

    # calculate
    lowest_before + 1 + 1 + (full_distance - lowest_after)
  end

  defp parse_line({line, row}) do
    line
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.map(fn {char, col} ->
      key = {row, col}
      object = parse_object(char)

      {key, object}
    end)
  end

  defp parse_object(char) do
    case char do
      "S" -> :start
      "E" -> :end
      "#" -> :wall
      "." -> :empty
    end
  end

  defp eliminate_dead_ends(map) do
    dead_end =
      Enum.find(map, nil, fn {{row, col}, object} ->
        object == :empty and dead_end_position?({row, col}, map)
      end)

    case dead_end do
      nil ->
        map

      {key, :empty} ->
        new_map = Map.put(map, key, :wall)
        eliminate_dead_ends(new_map)
    end
  end

  defp dead_end_position?({row, col}, map) do
    surrounding_wall_count =
      @direction_vectors
      |> Enum.map(fn {d_row, d_col} -> {row + d_row, col + d_col} end)
      |> Enum.map(fn key -> Map.get(map, key) end)
      |> Enum.count(fn object -> object == :wall end)

    surrounding_wall_count >= 3
  end

  defp dijkstra(map) do
    {start_position, :start} = find_start(map)

    available_nodes_map =
      map
      |> Enum.filter(fn {_, object} ->
        object in [:empty, :end]
      end)
      |> Enum.map(fn {key, _} -> {key, {@infinity, nil}} end)
      |> Map.new()

    node_map =
      available_nodes_map
      |> Map.put(start_position, {0, {0, 1}})

    do_dijkstra(node_map, %{})
  end

  defp do_dijkstra(nodes, result_map) when map_size(nodes) == 0 do
    result_map
  end

  defp do_dijkstra(nodes, result_map) do
    {key = {row, col}, {cost, direction}} =
      nodes
      |> Enum.sort_by(fn {_, {score, _}} -> score end, :asc)
      |> hd()

    updated_nodes = Map.delete(nodes, key)

    possible_targets =
      @direction_vectors
      |> Enum.map(fn {d_row, d_col} -> {row + d_row, col + d_col} end)
      |> Enum.filter(fn target -> Map.has_key?(updated_nodes, target) end)

    updated_nodes =
      Enum.reduce(possible_targets, updated_nodes, fn target = {t_row, t_col}, acc ->
        # calculate current cost
        travel_direction = {t_row - row, t_col - col}
        travel_cost = cost + 1

        # compare and update if needed
        {target_cost, _} = Map.get(acc, target)

        if travel_cost < target_cost do
          Map.put(acc, target, {travel_cost, travel_direction})
        else
          acc
        end
      end)

    updated_result_map = Map.put(result_map, key, {cost, direction})

    do_dijkstra(updated_nodes, updated_result_map)
  end

  defp find_start(map) do
    Enum.find(map, fn {_, object} -> object == :start end)
  end
end

RaceCondition.solve()
|> IO.inspect()
