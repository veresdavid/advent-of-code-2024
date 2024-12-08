# Part 1 of the puzzle

defmodule ResonantCollinearity do
  def solve do
    parsed_map =
      IO.read(:eof)
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.flat_map(&parse_line/1)
      |> Map.new()

    antenna_characters =
      parsed_map
      |> Map.values()
      |> Enum.filter(&is_antenna?/1)
      |> Enum.uniq()

    antenna_characters
    |> Enum.flat_map(fn antenna_character ->
      find_antinode_candidates(antenna_character, parsed_map)
    end)
    |> Enum.filter(fn key -> Map.has_key?(parsed_map, key) end)
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

  defp find_antinode_candidates(antenna_character, map) do
    antennas = Enum.filter(map, fn {_, character} -> character == antenna_character end)

    for a1 = {{a1_row, a1_col}, _} <- antennas do
      for a2 = {{a2_row, a2_col}, _} <- antennas do
        unless a1 == a2 do
          v_row = a2_row - a1_row
          v_col = a2_col - a1_col

          {a2_row + v_row, a2_col + v_col}
        else
          {-1, -1}
        end
      end
    end
    |> List.flatten()
    |> Enum.filter(fn candidate -> candidate != {-1, -1} end)
  end
end

ResonantCollinearity.solve()
|> IO.inspect()
