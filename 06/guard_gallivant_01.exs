# Part 1 of the puzzle

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
    |> Enum.count(fn {_, character} -> character == "X" end)
  end

  defp line_to_coordinates({line, row_index}) do
    line
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.map(fn {character, column_index} -> {{row_index, column_index}, character} end)
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
end

GuardGallivant.solve()
|> IO.inspect()
