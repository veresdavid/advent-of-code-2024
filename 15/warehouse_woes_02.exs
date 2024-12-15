# Part 2 of the puzzle

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

    map_lines =
      map_input
      |> String.replace("#", "##")
      |> String.replace("O", "[]")
      |> String.replace(".", "..")
      |> String.replace("@", "@.")
      |> String.split("\n", trim: true)

    parsed_map =
      map_lines
      |> Enum.with_index()
      |> Enum.flat_map(&parse_map_line/1)
      |> Map.new()

    moves =
      move_input
      |> String.replace("\n", "")
      |> String.graphemes()

    moves
    |> Enum.reduce(parsed_map, fn move, map ->
      perform_moves(move, map)
    end)
    |> Enum.filter(fn {_, object} -> object == :box_left end)
    |> Enum.map(fn {{box_row, left_box_col}, _} -> box_row * 100 + left_box_col end)
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

        "[" ->
          {{row, col}, :box_left}

        "]" ->
          {{row, col}, :box_right}

        "@" ->
          {{row, col}, :robot}

        "." ->
          {{row, col}, :empty}
      end
    end)
  end

  defp find_robot(map) do
    Enum.find_value(map, fn
      {key, :robot} -> {key, :robot}
      _ -> nil
    end)
  end

  defp perform_moves(move, map) do
    {position = {p_row, p_col}, :robot} = find_robot(map)
    direction = {d_row, d_col} = Map.get(@move_vectors, move)
    target = {p_row + d_row, p_col + d_col}

    case Map.get(map, target) do
      :wall -> map
      box when box in [:box_left, :box_right] -> shift_box(map, position, target, move, direction)
      :empty -> move_robot(map, position, target)
    end
  end

  defp shift_box(map, position, target, move, direction) do
    case move do
      ">" ->
        shift_box_horizontally(map, position, target, direction)

      "v" ->
        shift_box_vertically(map, position, target, direction)

      "<" ->
        shift_box_horizontally(map, position, target, direction)

      "^" ->
        shift_box_vertically(map, position, target, direction)
    end
  end

  defp shift_box_horizontally(map, position, target, direction = {d_row, d_col}) do
    boxes = horizontal_consecutive_boxes(map, target, direction, [])
    {last_box_row, last_box_col} = hd(boxes)
    position_after_last_box = {last_box_row + d_row, last_box_col + d_col}

    case Map.get(map, position_after_last_box) do
      :wall -> map
      :empty -> do_shift_box_horizontally(boxes, map, position, target, direction)
    end
  end

  defp do_shift_box_horizontally(boxes, map, robot_position, target_position, {d_row, d_col}) do
    boxes
    |> Enum.reduce(map, fn {box_row, box_col}, acc ->
      object = Map.get(map, {box_row, box_col})
      Map.put(acc, {box_row + d_row, box_col + d_col}, object)
    end)
    |> Map.put(target_position, :robot)
    |> Map.put(robot_position, :empty)
  end

  defp horizontal_consecutive_boxes(
         map,
         position = {p_row, p_col},
         direction = {d_row, d_col},
         boxes
       ) do
    case Map.get(map, position) do
      box when box in [:box_left, :box_right] ->
        horizontal_consecutive_boxes(
          map,
          {p_row + d_row, p_col + d_col},
          direction,
          [position | boxes]
        )

      _ ->
        boxes
    end
  end

  defp shift_box_vertically(map, position, target, direction) do
    {d_row, d_col} = direction
    boxes = vertical_consecutive_boxes(map, target, direction)
    sorted_boxes = Enum.sort_by(boxes, fn {box_row, _} -> box_row * d_row end, :desc)

    can_shift? =
      sorted_boxes
      |> Enum.map(fn {box_row, box_col} -> {box_row + d_row, box_col + d_col} end)
      |> Enum.all?(fn t_key -> Map.get(map, t_key) in [:empty, :box_left, :box_right] end)

    if can_shift? do
      sorted_boxes
      |> Enum.reduce(map, fn {box_row, box_col}, acc ->
        object = Map.get(map, {box_row, box_col})

        acc
        |> Map.put({box_row + d_row, box_col + d_col}, object)
        |> Map.put({box_row, box_col}, :empty)
      end)
      |> Map.put(target, :robot)
      |> Map.put(position, :empty)
    else
      map
    end
  end

  defp vertical_consecutive_boxes(map, target, direction) do
    box_part_ahead = Map.get(map, target)
    {t_row, t_col} = target

    other_box_part =
      case box_part_ahead do
        :box_left -> {t_row, t_col + 1}
        :box_right -> {t_row, t_col - 1}
      end

    do_vertical_consecutive_boxes([target, other_box_part], map, direction, MapSet.new())
  end

  defp do_vertical_consecutive_boxes([], _, _, result) do
    result
  end

  defp do_vertical_consecutive_boxes([head | tail], map, direction, result) do
    {p_row, p_col} = head
    {d_row, d_col} = direction
    target = {t_row, t_col} = {p_row + d_row, p_col + d_col}

    connections_ahead =
      case Map.get(map, target) do
        :box_left -> [target, {t_row, t_col + 1}]
        :box_right -> [target, {t_row, t_col - 1}]
        _ -> []
      end

    do_vertical_consecutive_boxes(
      connections_ahead ++ tail,
      map,
      direction,
      MapSet.put(result, head)
    )
  end

  defp move_robot(map, robot_position, target_position) do
    map
    |> Map.put(robot_position, :empty)
    |> Map.put(target_position, :robot)
  end

  defp pretty_map(map) do
    map
    |> Enum.group_by(fn {{row, _}, _} -> row end)
    |> Enum.sort(fn {key1, _}, {key2, _} -> key1 < key2 end)
    |> Enum.map(fn {_, value} -> value end)
    |> Enum.map(fn list ->
      list
      |> Enum.sort(fn {{_, col1}, _}, {{_, col2}, _} -> col1 < col2 end)
      |> Enum.map(fn {_, object} ->
        case object do
          :wall -> "#"
          :box_left -> "["
          :box_right -> "]"
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
