# Part 1 of the puzzle

defmodule CeresSearch do
  @xmas_directions [
    [{0, 0}, {0, 1}, {0, 2}, {0, 3}],
    [{0, 0}, {1, 1}, {2, 2}, {3, 3}],
    [{0, 0}, {1, 0}, {2, 0}, {3, 0}],
    [{0, 0}, {1, -1}, {2, -2}, {3, -3}],
    [{0, 0}, {0, -1}, {0, -2}, {0, -3}],
    [{0, 0}, {-1, -1}, {-2, -2}, {-3, -3}],
    [{0, 0}, {-1, 0}, {-2, 0}, {-3, 0}],
    [{0, 0}, {-1, 1}, {-2, 2}, {-3, 3}]
  ]

  def solve do
    input_map =
      IO.read(:eof)
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, first_index} ->
        line
        |> String.graphemes()
        |> Enum.with_index(fn element, second_index ->
          {{first_index, second_index}, element}
        end)
      end)
      |> Map.new()

    input_map
    |> Map.filter(fn {_, value} -> value == "X" end)
    |> Enum.map(fn entry -> count_xmas_starting_from(entry, input_map) end)
    |> Enum.sum()
  end

  defp count_xmas_starting_from({pivot, "X"}, input_map) do
    @xmas_directions
    |> Enum.map(fn direction -> word_for_direction(pivot, direction, input_map) end)
    |> Enum.filter(fn word -> word == "XMAS" end)
    |> Enum.reduce(0, fn _, acc -> acc + 1 end)
  end

  defp count_xmas_starting_from(_, _) do
    0
  end

  defp word_for_direction({x, y}, direction, input_map) do
    direction
    |> Enum.map(fn {dx, dy} -> {x + dx, y + dy} end)
    |> Enum.map(fn key -> Map.get(input_map, key, "") end)
    |> Enum.join()
  end
end

CeresSearch.solve()
|> IO.inspect()
