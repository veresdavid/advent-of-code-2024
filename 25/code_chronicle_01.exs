# Part 1 of the puzzle

defmodule CodeChronicle do
  def solve do
    schemes =
      IO.read(:eof)
      |> String.split("\n\n")
      |> Enum.map(&parse_scheme/1)

    %{lock: locks, key: keys} =
      Enum.group_by(schemes, fn {type, _} -> type end, fn {_, heights} -> heights end)

    for lock <- locks, key <- keys do
      fits? =
        Enum.zip_with([lock, key], &Enum.sum/1)
        |> Enum.all?(fn val -> val <= 5 end)

      if fits?, do: 1, else: 0
    end
    |> Enum.sum()
  end

  defp parse_scheme(input) do
    scheme_type = if String.first(input) == "#", do: :lock, else: :key

    line_bits =
      input
      |> String.split("\n", trim: true)
      |> tl()
      |> Enum.reverse()
      |> tl()
      |> Enum.reverse()
      |> Enum.map(&map_line_to_bits/1)

    heights = Enum.zip_with(line_bits, &Enum.sum/1)

    {scheme_type, heights}
  end

  defp map_line_to_bits(line) do
    line
    |> String.graphemes()
    |> Enum.map(&map_char_to_bit/1)
  end

  defp map_char_to_bit(char) do
    case char do
      "." -> 0
      "#" -> 1
    end
  end
end

CodeChronicle.solve()
|> IO.inspect()
