# Part 2 of the puzzle

defmodule CeresSearch do
  @diagonals [
    [{-1, 1}, {1, -1}],
    [{1, 1}, {-1, -1}]
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
    |> Map.filter(fn {_, value} -> value == "A" end)
    |> Enum.filter(fn {pivot, _} -> x_mas?(pivot, input_map) end)
    |> Enum.reduce(0, fn _, acc -> acc + 1 end)
  end

  defp x_mas?(pivot, input_map) do
    @diagonals
    |> Enum.map(fn diagonal -> diagonal_to_string(pivot, diagonal, input_map) end)
    |> Enum.all?(&valid_diagonal_string?/1)
  end

  defp diagonal_to_string({x, y}, diagonal, input_map) do
    diagonal
    |> Enum.map(fn {dx, dy} -> {x + dx, y + dy} end)
    |> Enum.map(fn key -> Map.get(input_map, key, "") end)
    |> Enum.join()
  end

  defp valid_diagonal_string?(diagonal_string) do
    diagonal_string == "MS" || diagonal_string == "SM"
  end
end

CeresSearch.solve()
|> IO.inspect()
