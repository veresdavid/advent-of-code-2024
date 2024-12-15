# Part 1 of the puzzle

defmodule RestroomRedoubt do
  @robot_rex ~r/^p=(?<pos_col>\d+),(?<pos_row>\d+) v=(?<vel_col>-?\d+),(?<vel_row>-?\d+)$/
  @space_rows 103
  @space_cols 101

  def solve do
    IO.read(:eof)
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_robot/1)
    |> simulate_seconds(100)
    |> robot_count_on_tiles()
    |> get_quadrant_robot_counts(@space_rows, @space_cols)
    |> Enum.product()
  end

  defp parse_robot(line) do
    %{
      "pos_col" => pos_col,
      "pos_row" => pos_row,
      "vel_col" => vel_col,
      "vel_row" => vel_row
    } =
      Regex.named_captures(@robot_rex, line)

    %{
      pos_row: String.to_integer(pos_row),
      pos_col: String.to_integer(pos_col),
      vel_row: String.to_integer(vel_row),
      vel_col: String.to_integer(vel_col)
    }
  end

  defp simulate_seconds(robots, seconds) do
    do_simulate_seconds(robots, [], seconds)
  end

  defp do_simulate_seconds(robots, [], 0) do
    robots
  end

  defp do_simulate_seconds([], new_state, 0) do
    new_state
  end

  defp do_simulate_seconds([], new_state, seconds) do
    do_simulate_seconds(new_state, [], seconds - 1)
  end

  defp do_simulate_seconds([robot | tail], new_state, seconds) do
    new_robot = simulate_robot(robot, @space_rows, @space_cols)

    do_simulate_seconds(tail, [new_robot | new_state], seconds)
  end

  defp simulate_robot(robot, num_rows, num_cols) do
    %{
      pos_row: pos_row,
      pos_col: pos_col,
      vel_row: vel_row,
      vel_col: vel_col
    } = robot

    new_row = step_with_overflow(pos_row, vel_row, num_rows)
    new_col = step_with_overflow(pos_col, vel_col, num_cols)

    %{
      pos_row: new_row,
      pos_col: new_col,
      vel_row: vel_row,
      vel_col: vel_col
    }
  end

  defp step_with_overflow(start, velocity, max) do
    new_value = start + velocity

    cond do
      new_value < 0 ->
        max + new_value

      new_value >= max ->
        new_value - max

      true ->
        new_value
    end
  end

  defp robot_count_on_tiles(robots) do
    for row <- 0..(@space_rows - 1) do
      for col <- 0..(@space_cols - 1) do
        robot_count_on_tile(robots, row, col)
      end
    end
  end

  defp robot_count_on_tile(robots, row, col) do
    Enum.reduce(robots, 0, fn robot, acc ->
      %{
        pos_row: pos_row,
        pos_col: pos_col
      } = robot

      if pos_row == row and pos_col == col do
        acc + 1
      else
        acc
      end
    end)
  end

  defp get_quadrant_robot_counts(robot_count, num_rows, num_cols) do
    quadrant_row_count = div(num_rows - 1, 2)
    quadrant_col_count = div(num_cols - 1, 2)

    [
      {0..(quadrant_row_count - 1), 0..(quadrant_col_count - 1)},
      {0..(quadrant_row_count - 1), (quadrant_col_count + 1)..(num_cols - 1)},
      {(quadrant_row_count + 1)..(num_rows - 1), 0..(quadrant_col_count - 1)},
      {(quadrant_row_count + 1)..(num_rows - 1), (quadrant_col_count + 1)..(num_cols - 1)}
    ]
    |> Enum.map(fn quadrant_ranges -> get_quadrant_robot_count(robot_count, quadrant_ranges) end)
  end

  defp get_quadrant_robot_count(robot_count, {quadrant_row_range, quadrant_col_range}) do
    robot_count
    |> Enum.slice(quadrant_row_range)
    |> Enum.map(fn sublist -> Enum.slice(sublist, quadrant_col_range) end)
    |> List.flatten()
    |> Enum.sum()
  end
end

RestroomRedoubt.solve()
|> IO.inspect()
