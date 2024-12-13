# Part 1 of the puzzle

defmodule GardenGroups do
  @neighbour_directions [
    {0, -1},
    {1, 0},
    {0, 1},
    {-1, 0}
  ]

  def solve do
    garden =
      IO.read(:eof)
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.flat_map(&parse_line/1)
      |> Map.new()

    garden
    |> collect_groups()
    |> Enum.map(fn group -> calculate_area(group) * calculate_perimiter(group) end)
    |> Enum.sum()
  end

  defp parse_line({line, row}) do
    line
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.map(fn {character, col} -> {{row, col}, character} end)
  end

  defp flood_fill(garden, start) do
    do_flood_fill([start], garden, %{}, [])
  end

  defp do_flood_fill([], _, _, result) do
    result
  end

  defp do_flood_fill([head | tail], garden, visited, result) do
    {{p_row, p_col}, character} = head

    possible_targets =
      @neighbour_directions
      |> Enum.map(fn {d_row, d_col} -> {p_row + d_row, p_col + d_col} end)
      |> Enum.filter(fn t_pos -> !Map.has_key?(visited, t_pos) end)
      |> Enum.filter(fn t_pos -> Map.has_key?(garden, t_pos) end)
      |> Enum.filter(fn t_pos -> Map.get(garden, t_pos) == character end)
      |> Enum.map(fn t_pos -> {t_pos, character} end)

    updated_visited =
      Map.put(visited, {p_row, p_col}, character)

    do_flood_fill(possible_targets ++ tail, garden, updated_visited, [head | result])
  end

  defp collect_groups(garden) do
    {groups, _} =
      Enum.reduce(garden, {[], %{}}, fn elem, {groups, visited} ->
        {position, _} = elem

        if Map.has_key?(visited, position) do
          {groups, visited}
        else
          new_group = flood_fill(garden, elem)

          new_visited =
            Enum.reduce(new_group, visited, fn {pos, val}, acc -> Map.put(acc, pos, val) end)

          {[new_group | groups], new_visited}
        end
      end)

    groups
    |> Enum.map(&Map.new/1)
  end

  defp calculate_area(group) do
    map_size(group)
  end

  defp calculate_perimiter(group) do
    Map.keys(group)
    |> Enum.map(fn pos -> fence_count(pos, group) end)
    |> Enum.sum()
  end

  defp fence_count({p_row, p_col}, group) do
    @neighbour_directions
    |> Enum.map(fn {d_row, d_col} -> {p_row + d_row, p_col + d_col} end)
    |> Enum.count(fn neighbour -> !Map.has_key?(group, neighbour) end)
  end
end

GardenGroups.solve()
|> IO.inspect()
