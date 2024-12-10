# Part 2 of the puzzle

defmodule HoofIt do
  @step_directions [
    {0, -1},
    {1, 0},
    {0, 1},
    {-1, 0}
  ]

  def solve do
    parsed_map =
      IO.read(:eof)
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.flat_map(&parse_line/1)
      |> Map.new()

    parsed_map
    |> Enum.filter(fn {_, height} -> height == 0 end)
    |> Enum.map(fn start -> get_rating(start, parsed_map) end)
    |> Enum.sum()
  end

  defp parse_line({line, row}) do
    line
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.map(fn
      {".", col} ->
        {{row, col}, -1}

      {char, col} ->
        {{row, col}, String.to_integer(char)}
    end)
  end

  defp get_rating({position, value}, map) do
    do_get_rating([{position, value, []}], map, [])
  end

  defp do_get_rating([], _, trails) do
    trails
    |> Enum.uniq()
    |> Enum.count()
  end

  defp do_get_rating([{_, 9, path} | tail], map, trails) do
    do_get_rating(tail, map, [path | trails])
  end

  defp do_get_rating([{position, height, path} | tail], map, trails) do
    next_positions =
      find_step_candidates({position, height}, map)
      |> Enum.map(fn {next_position, next_height} ->
        {next_position, next_height, [next_position | path]}
      end)

    do_get_rating(next_positions ++ tail, map, trails)
  end

  defp find_step_candidates({{p_row, p_col}, height}, map) do
    @step_directions
    |> Enum.map(fn {v_row, v_col} -> {p_row + v_row, p_col + v_col} end)
    |> Enum.filter(fn position -> Map.has_key?(map, position) end)
    |> Enum.map(fn position -> {position, Map.get(map, position)} end)
    |> Enum.filter(fn {_, target_height} -> target_height - height == 1 end)
  end
end

HoofIt.solve()
|> IO.inspect()
