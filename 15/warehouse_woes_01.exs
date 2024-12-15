# Part 1 of the puzzle

defmodule WarehouseWoes do
  @move_vectors %{
    ">" => {0, 1},
    "v" => {1, 0},
    "<" => {0, -1},
    "^" => {-1, 0}
  }

  def solve do
    [map_input, move_input] =
      IO.read(:eof)
      |> String.split("\n\n")

    parsed_map =
      map_input
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.flat_map(&parse_map_line/1)
      |> Map.new()

    robot =
      Enum.find_value(parsed_map, fn
        {key, :robot} -> {key, :robot}
        _ -> nil
      end)

    moves =
      move_input
      |> String.replace("\n", "")
      |> String.graphemes()

    moves
    |> perform_moves(parsed_map, robot)
    |> Enum.filter(fn {_, object} -> object == :box end)
    |> Enum.map(fn {{box_row, box_col}, _} -> 100 * box_row + box_col end)
    |> Enum.sum()
  end

  defp parse_map_line({line, row}) do
    line
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.map(fn {character, col} ->
      case character do
        "#" ->
          {{row, col}, :wall}

        "O" ->
          {{row, col}, :box}

        "@" ->
          {{row, col}, :robot}

        "." ->
          {{row, col}, :empty}
      end
    end)
  end

  defp perform_moves([], map, _) do
    map
  end

  defp perform_moves([move | tail], map, robot) do
    {position = {p_row, p_col}, :robot} = robot
    direction = {d_row, d_col} = Map.get(@move_vectors, move)
    target = {p_row + d_row, p_col + d_col}

    case Map.get(map, target) do
      :wall ->
        perform_moves(tail, map, robot)

      :box ->
        boxes = consecutive_boxes(map, target, direction, [])
        {last_box_row, last_box_col} = hd(boxes)
        position_after_last_box = {last_box_row + d_row, last_box_col + d_col}

        case Map.get(map, position_after_last_box) do
          :wall ->
            perform_moves(tail, map, robot)

          :empty ->
            new_map = shift_boxes_with_robot(boxes, map, position, target, direction)

            perform_moves(tail, new_map, {target, :robot})
        end

      :empty ->
        new_map = move_robot(map, position, target)

        perform_moves(tail, new_map, {target, :robot})
    end
  end

  defp move_robot(map, robot_position, target_position) do
    map
    |> Map.put(robot_position, :empty)
    |> Map.put(target_position, :robot)
  end

  defp shift_boxes_with_robot(boxes, map, robot_position, target_position, {d_row, d_col}) do
    boxes
    |> Enum.reduce(map, fn {box_row, box_col}, acc ->
      Map.put(acc, {box_row + d_row, box_col + d_col}, :box)
    end)
    |> Map.put(target_position, :robot)
    |> Map.put(robot_position, :empty)
  end

  defp consecutive_boxes(map, position = {p_row, p_col}, direction = {d_row, d_col}, boxes) do
    case Map.get(map, position) do
      :box ->
        consecutive_boxes(map, {p_row + d_row, p_col + d_col}, direction, [position | boxes])

      _ ->
        boxes
    end
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
          :box -> "O"
          :robot -> "@"
          :empty -> "."
        end
      end)
      |> Enum.join()
    end)
    |> Enum.join("\n")
  end
end

WarehouseWoes.solve()
|> IO.inspect()
