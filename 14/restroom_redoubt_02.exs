# Part 2 of the puzzle

defmodule RestroomRedoubt do
  @robot_rex ~r/^p=(?<pos_col>\d+),(?<pos_row>\d+) v=(?<vel_col>-?\d+),(?<vel_row>-?\d+)$/
  @space_rows 103
  @space_cols 101

  def solve do
    robots =
      IO.read(:eof)
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_robot/1)

    # run the algorithm based on an idea, to find potential christmas tree formations
    # see more details below
    # find_christmas_tree(robots, 0)

    # we can analyze the formation by pretty printing a state based on the elapsed seconds
    robots
    |> fast_simulate_seconds(8006)
    |> robot_count_on_tiles()
    |> prettify_robot_count_on_tiles()
    |> IO.puts()
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

  # updated simulation function, to count new robot positions faster
  defp fast_simulate_seconds(robots, seconds) do
    Enum.map(robots, fn robot ->
      %{
        pos_row: pos_row,
        pos_col: pos_col,
        vel_row: vel_row,
        vel_col: vel_col
      } = robot

      unbounded_pos_row = pos_row + seconds * vel_row
      unbounded_pos_col = pos_col + seconds * vel_col

      bounded_pos_row = rem(unbounded_pos_row, @space_rows)
      bounded_pos_col = rem(unbounded_pos_col, @space_cols)

      new_row =
        if bounded_pos_row < 0 do
          @space_rows + bounded_pos_row
        else
          bounded_pos_row
        end

      new_col =
        if bounded_pos_col < 0 do
          @space_cols + bounded_pos_col
        else
          bounded_pos_col
        end

      %{
        pos_row: new_row,
        pos_col: new_col,
        vel_row: vel_row,
        vel_col: vel_col
      }
    end)
  end

  # algorithm that works on the following idea:
  # the robots form a christmas tree, when all of them are located on a unique position
  # it can happen in multiple cases
  # we should analyze the input to see if they indeed form a christmas tree
  defp find_christmas_tree(robots, seconds_passed) do
    if all_robots_on_unique_positions?(robots) do
      IO.puts(seconds_passed)
    end

    new_robots = fast_simulate_seconds(robots, 1)

    find_christmas_tree(new_robots, seconds_passed + 1)
  end

  defp all_robots_on_unique_positions?(robots) do
    do_all_robots_on_unique_positions?(robots, MapSet.new())
  end

  defp do_all_robots_on_unique_positions?([], _) do
    true
  end

  defp do_all_robots_on_unique_positions?([robot | tail], position_set) do
    %{
      pos_row: pos_row,
      pos_col: pos_col
    } = robot

    position = {pos_row, pos_col}

    if MapSet.member?(position_set, position) do
      false
    else
      new_position_set = MapSet.put(position_set, position)

      do_all_robots_on_unique_positions?(tail, new_position_set)
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

  defp prettify_robot_count_on_tiles(robot_counts) do
    robot_counts
    |> Enum.map(fn row ->
      Enum.map(row, fn count ->
        if count > 0 do
          "X"
        else
          " "
        end
      end)
      |> Enum.join()
    end)
    |> Enum.join("\n")
  end
end

RestroomRedoubt.solve()
# |> IO.inspect()
