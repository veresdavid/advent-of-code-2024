# Part 2 of the puzzle

defmodule ResonantCollinearity do
  def solve do
    input_lines =
      IO.read(:eof)
      |> String.split("\n", trim: true)

    map_size = {
      length(input_lines),
      String.length(hd(input_lines))
    }

    parsed_map =
      input_lines
      |> Enum.with_index()
      |> Enum.flat_map(&parse_line/1)
      |> Map.new()

    antenna_characters =
      parsed_map
      |> Map.values()
      |> Enum.filter(&is_antenna?/1)
      |> Enum.uniq()

    resonant_antinodes =
      antenna_characters
      |> Enum.flat_map(fn antenna_character ->
        find_possible_antinode_positions(antenna_character, parsed_map, map_size)
      end)
      |> Enum.uniq()

    antenna_antinodes =
      parsed_map
      |> Enum.filter(fn {_, character} -> is_antenna?(character) end)
      |> Enum.map(fn {key, _} -> key end)
      |> Enum.uniq()

    resonant_antinodes
    |> Enum.concat(antenna_antinodes)
    |> Enum.uniq()
    |> Enum.count()
  end

  defp parse_line({line, row}) do
    line
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.map(fn {character, col} -> {{row, col}, character} end)
  end

  defp is_antenna?(character) do
    character != "."
  end

  defp find_possible_antinode_positions(antenna_character, map, map_size) do
    antennas = Enum.filter(map, fn {_, character} -> character == antenna_character end)

    for a1 <- antennas do
      for a2 <- antennas do
        antinode_count = max_antinode_count(a1, a2, map_size)
        generate_antinode_positions(a1, a2, antinode_count)
      end
    end
    |> List.flatten()
  end

  defp max_antinode_count(a1, a2, _) when a1 == a2 do
    0
  end

  # count how many antinodes there can be in the line starting from a1 to a2,
  # considering the size of the map
  defp max_antinode_count(a1, a2, {num_rows, num_cols}) do
    max_row = num_rows - 1
    max_col = num_cols - 1

    {{a1_row, a1_col}, _} = a1
    {{a2_row, a2_col}, _} = a2

    v_row = a2_row - a1_row
    v_col = a2_col - a1_col

    d_row = if v_row < 0, do: 0 - a2_row, else: max_row - a2_row
    d_col = if v_col < 0, do: 0 - a2_col, else: max_col - a2_col

    min(
      div(d_row, v_row),
      div(d_col, v_col)
    )
  end

  defp generate_antinode_positions(_, _, antinode_count) when antinode_count == 0 do
    []
  end

  defp generate_antinode_positions(a1, a2, antinode_count) do
    for i <- 1..antinode_count do
      {{a1_row, a1_col}, _} = a1
      {{a2_row, a2_col}, _} = a2

      v_row = a2_row - a1_row
      v_col = a2_col - a1_col

      {a2_row + i * v_row, a2_col + i * v_col}
    end
  end
end

ResonantCollinearity.solve()
|> IO.inspect()
