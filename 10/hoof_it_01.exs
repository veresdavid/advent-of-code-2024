# Part 1 of the puzzle

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
    |> Enum.map(fn start -> get_trailhead_score(start, parsed_map) end)
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

  defp get_trailhead_score(start, map) do
    do_get_trailhead_score([start], map, [])
  end

  defp do_get_trailhead_score([], _, trailheads) do
    trailheads
    |> Enum.uniq()
    |> Enum.count()
  end

  defp do_get_trailhead_score([position = {_, 9} | tail], map, trailheads) do
    do_get_trailhead_score(tail, map, [position | trailheads])
  end

  defp do_get_trailhead_score([position | tail], map, trailheads) do
    next_positions = find_step_candidates(position, map)
    do_get_trailhead_score(next_positions ++ tail, map, trailheads)
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
