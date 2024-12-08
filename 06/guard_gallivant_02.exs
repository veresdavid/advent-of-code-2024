# Part 2 of the puzzle

defmodule GuardGallivant do
  @move_vectors %{
    "^" => {-1, 0},
    ">" => {0, 1},
    "v" => {1, 0},
    "<" => {0, -1}
  }

  @rotate_transitions %{
    "^" => ">",
    ">" => "v",
    "v" => "<",
    "<" => "^"
  }

  def solve do
    area =
      IO.read(:eof)
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.flat_map(&line_to_coordinates/1)
      |> Map.new()

    guard =
      area
      |> Enum.find(fn {_, character} -> character == "^" end)

    guard
    |> traverse_area(area)
    |> Enum.filter(fn {key, character} -> character == "X" and key != elem(guard, 0) end)
    |> Enum.map(fn {position, _} -> place_obstruction(area, position) end)
    |> Enum.filter(fn area_with_obstruction -> contains_loop?(guard, area_with_obstruction) end)
    |> Enum.count()
  end

  defp line_to_coordinates({line, row_index}) do
    line
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.map(fn {character, column_index} ->
      {{row_index, column_index}, character}
    end)
  end

  defp traverse_area({{p_row, p_col}, direction}, area) do
    {v_row, v_col} = Map.get(@move_vectors, direction)
    target_position = {p_row + v_row, p_col + v_col}

    case Map.get(area, target_position, "Q") do
      "Q" ->
        area
        |> Map.put({p_row, p_col}, "X")

      "#" ->
        new_direction = Map.get(@rotate_transitions, direction)
        traverse_area({{p_row, p_col}, new_direction}, area)

      _ ->
        new_area =
          area
          |> Map.put({p_row, p_col}, "X")
          |> Map.put(target_position, direction)

        traverse_area({target_position, direction}, new_area)
    end
  end

  defp place_obstruction(area, position) do
    area
    |> Map.put(position, "O")
  end

  defp contains_loop?(guard, area) do
    do_contains_loop?(guard, area, [])
  end

  defp do_contains_loop?({{p_row, p_col}, direction}, area, met_obstructions) do
    {v_row, v_col} = Map.get(@move_vectors, direction)
    target_position = {p_row + v_row, p_col + v_col}

    target_char = Map.get(area, target_position, "Q")

    case target_char do
      "Q" ->
        false

      character when character in ["#", "O"] ->
        new_direction = Map.get(@rotate_transitions, direction)
        hit_obstruction_from = {target_position, direction}

        if Enum.member?(met_obstructions, hit_obstruction_from) do
          true
        else
          do_contains_loop?({{p_row, p_col}, new_direction}, area, [
            hit_obstruction_from | met_obstructions
          ])
        end

      _ ->
        do_contains_loop?({target_position, direction}, area, met_obstructions)
    end
  end
end

GuardGallivant.solve()
|> IO.inspect()
