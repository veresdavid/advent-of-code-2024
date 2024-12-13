# Part 2 of the puzzle

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
    |> Enum.map(fn group -> calculate_area(group) * count_sides(group) end)
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

  defp count_sides(group) do
    %{left: left, right: right, top: top, bottom: bottom} =
      group
      |> Map.keys()
      |> Enum.flat_map(fn position -> get_side_vectors(position, group) end)
      |> Enum.group_by(fn {_, _, side} -> side end)

    col_selector = fn {_, col, _} -> col end
    row_selector = fn {row, _, _} -> row end

    left_count = count_specific_side(left, col_selector, row_selector)
    right_count = count_specific_side(right, col_selector, row_selector)
    top_count = count_specific_side(top, row_selector, col_selector)
    bottom_count = count_specific_side(bottom, row_selector, col_selector)

    left_count + right_count + top_count + bottom_count
  end

  defp count_specific_side(side_group, groupper_function, mapper_function) do
    side_group
    |> Enum.group_by(groupper_function)
    |> Map.values()
    |> Enum.map(fn sub_group -> Enum.map(sub_group, mapper_function) end)
    |> Enum.map(&count_fragments/1)
    |> Enum.sum()
  end

  defp count_fragments(list) do
    sorted = Enum.sort(list)

    {_, count} =
      Enum.reduce(sorted, {hd(sorted), 0}, fn elem, {prev, count} ->
        case elem - prev do
          1 ->
            {elem, count}

          _ ->
            {elem, count + 1}
        end
      end)

    count
  end

  defp get_side_vectors({p_row, p_col}, group) do
    vertical_fences =
      [-1, 1]
      |> Enum.filter(fn d_col -> !Map.has_key?(group, {p_row, p_col + d_col}) end)
      |> Enum.map(fn d_col ->
        side = if d_col == -1, do: :left, else: :right
        {p_row, p_col, side}
      end)

    horizontal_fences =
      [-1, 1]
      |> Enum.filter(fn d_row -> !Map.has_key?(group, {p_row + d_row, p_col}) end)
      |> Enum.map(fn d_row ->
        side = if d_row == -1, do: :top, else: :bottom
        {p_row, p_col, side}
      end)

    vertical_fences ++ horizontal_fences
  end
end

GardenGroups.solve()
|> IO.inspect()
