# Part 1 of the puzzle

defmodule RamRun do
  @max_row 70
  @max_col 70
  @simulation_limit 1024
  @infinity 999_999_999
  @direction_vectors [
    {0, 1},
    {1, 0},
    {0, -1},
    {-1, 0}
  ]

  def solve do
    falling_bytes =
      IO.read(:eof)
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_falling_byte/1)

    empty_map = generate_empty_map(@max_row, @max_col)

    map =
      falling_bytes
      |> Enum.slice(0..(@simulation_limit - 1))
      |> Enum.reduce(empty_map, fn key, acc -> Map.put(acc, key, :wall) end)
      |> Map.put({0, 0}, :start)
      |> Map.put({@max_row, @max_col}, :goal)

    find_shortest_path(map)
    |> Map.get({@max_row, @max_col})
  end

  defp parse_falling_byte(line) do
    [col, row] =
      line
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    {row, col}
  end

  defp generate_empty_map(max_row, max_col) do
    for row <- 0..max_row do
      for col <- 0..max_col do
        {row, col}
      end
    end
    |> List.flatten()
    |> Enum.reduce(%{}, fn key, acc -> Map.put(acc, key, :empty) end)
  end

  defp find_shortest_path(map) do
    {start_position, :start} =
      Enum.find(map, fn {_, object} -> object == :start end)

    queue =
      map
      |> Enum.reduce(%{}, fn {key, object}, acc -> Map.put(acc, key, {object, @infinity, nil}) end)
      |> Map.put(start_position, {:start, 0, nil})

    do_find_shortest_path(queue, MapSet.new())
  end

  defp do_find_shortest_path(queue, result) when map_size(queue) == 0 do
    result
  end

  defp do_find_shortest_path(queue, result) do
    {popped_key = {p_row, p_col}, popped_value = {_, cost, _}} =
      queue
      |> Enum.sort_by(fn {_, {_, cost, _}} -> cost end, :asc)
      |> hd()

    popped_queue = Map.delete(queue, popped_key)

    possible_targets =
      @direction_vectors
      |> Enum.map(fn {d_row, d_col} -> {p_row + d_row, p_col + d_col} end)
      |> Enum.filter(fn target -> Map.has_key?(popped_queue, target) end)
      |> Enum.filter(fn target ->
        {object, _, _} = Map.get(popped_queue, target)
        object in [:empty, :start, :goal]
      end)

    updated_queue =
      Enum.reduce(possible_targets, popped_queue, fn target, acc ->
        {target_object, target_cost, target_prev} = Map.get(acc, target)

        updated_target =
          if cost + 1 < target_cost do
            {target_object, cost + 1, popped_key}
          else
            {target_object, target_cost, target_prev}
          end

        Map.put(acc, target, updated_target)
      end)

    updated_result = Map.put(result, popped_key, popped_value)

    do_find_shortest_path(updated_queue, updated_result)
  end

  defp pretty_map(map) do
    map
    |> Enum.group_by(fn {{row, _}, _} -> row end)
    |> Map.values()
    |> Enum.map(fn list ->
      list
      |> Enum.sort(fn {{_, col1}, _}, {{_, col2}, _} -> col1 < col2 end)
      |> Enum.map(fn {_, object} ->
        case object do
          :wall -> "#"
          :empty -> "."
          :start -> "S"
          :goal -> "G"
        end
      end)
      |> Enum.join()
    end)
    |> Enum.join("\n")
  end
end

RamRun.solve()
|> IO.inspect()
