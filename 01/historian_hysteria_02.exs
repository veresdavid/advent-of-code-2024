# Part 2 of the puzzle

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

    for left <- left_list, right <- right_list do
      {left, right}
    end
    |> Enum.filter(fn {left, right} -> left === right end)
    |> Enum.map(fn {left, _} -> left end)
    |> Enum.sum()
  end
end

HistorianHysteria.solve()
|> IO.inspect()
