# Part 1 of the puzzle

defmodule ReindeerMaze do
  @direction_vectors [
    {0, 1},
    {1, 0},
    {0, -1},
    {-1, 0}
  ]

  @infinity 999_999_999

  def solve do
    parsed_map =
      IO.read(:eof)
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.flat_map(&parse_line/1)
      |> Map.new()

    preprocessed_map =
      parsed_map
      |> eliminate_dead_ends()

    result_map =
      preprocessed_map
      |> dijkstra()

    {end_key, :end} =
      Enum.find(parsed_map, fn {_, object} -> object == :end end)

    Map.get(result_map, end_key)
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
      "S" -> :reindeer
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
    {start_position, :reindeer} = find_reindeer(map)

    available_nodes_map =
      map
      |> Enum.filter(fn {_, object} -> object in [:empty, :end] end)
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
        travel_cost = cost + travel_cost(key, target, direction)

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

  defp travel_cost(source, target, direction) do
    1 + 1000 * rotation_count(source, target, direction)
  end

  defp rotation_count({s_row, s_col}, {t_row, t_col}, direction) do
    target_direction = {t_row - s_row, t_col - s_col}

    if target_direction == direction, do: 0, else: 1
  end

  defp find_reindeer(map) do
    Enum.find(map, fn {_, object} -> object == :reindeer end)
  end
end

ReindeerMaze.solve()
|> IO.inspect()
