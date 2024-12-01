# Part 1 of the puzzle

defmodule HistorianHysteria do
  def solve do
    [left_list, right_list] =
      IO.read(:eof)
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(&String.split/1)
      |> Enum.map(fn list -> Enum.map(list, &String.to_integer/1) end)
      |> Enum.reduce([[], []], fn [left, right], [left_list, right_list] ->
        [[left | left_list], [right | right_list]]
      end)
      |> Enum.map(&Enum.sort/1)

    do_pair(left_list, right_list, [])
    |> Enum.map(fn {a, b} -> abs(a - b) end)
    |> Enum.sum()
  end

  defp do_pair([], [], pairs) do
    pairs
  end

  defp do_pair([left | left_tail], [right | right_tail], pairs) do
    do_pair(left_tail, right_tail, [{left, right} | pairs])
  end
end

HistorianHysteria.solve()
|> IO.inspect()
