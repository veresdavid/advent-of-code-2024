# Part 1 of the puzzle

defmodule RamRun do
  @max_row 70
  @max_col 70
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
      empty_map
      |> Map.put({0, 0}, :start)
      |> Map.put({@max_row, @max_col}, :goal)

    first_blocking_index =
      find_first_blocking_byte(map, falling_bytes)

    {y, x} =
      falling_bytes
      |> Enum.at(first_blocking_index)

    "#{x},#{y}"
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

  defp find_first_blocking_byte(map, falling_bytes) do
    low = 0
    high = length(falling_bytes) - 1

    do_find_first_blocking_byte(map, falling_bytes, low, high) + 1
  end

  defp do_find_first_blocking_byte(_, _, low, high) when low >= high do
    div(low + high, 2)
  end

  defp do_find_first_blocking_byte(map, falling_bytes, low, high) do
    bytes_to_take = div(low + high, 2)

    falling_bytes_map =
      falling_bytes
      |> Enum.slice(0..bytes_to_take)
      |> Enum.reduce(map, fn key, acc -> Map.put(acc, key, :wall) end)

    {:goal, cost, _} =
      find_shortest_path(falling_bytes_map)
      |> Map.get({@max_row, @max_col})

    if cost != @infinity do
      do_find_first_blocking_byte(map, falling_bytes, bytes_to_take + 1, high)
    else
      do_find_first_blocking_byte(map, falling_bytes, low, bytes_to_take - 1)
    end
  end
end

RamRun.solve()
|> IO.inspect()
