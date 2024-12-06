# Part 1 of the puzzle

defmodule PrintQueue do
  def solve do
    [rule_input, update_input] =
      IO.read(:eof)
      |> String.split("\n\n", trim: true)
      |> Enum.map(fn part -> String.split(part, "\n", trim: true) end)

    rule_map =
      rule_input
      |> Map.new(fn rule -> {rule, :ok} end)

    update_input
    |> Enum.map(fn update -> String.split(update, ",") end)
    |> Enum.filter(fn update -> valid_update?(update, rule_map) end)
    |> Enum.map(&middle_element/1)
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
  end

  defp valid_update?([], _) do
    true
  end

  defp valid_update?([head | tail], rule_map) do
    all_rule_matches =
      tail
      |> Enum.all?(fn element -> Map.has_key?(rule_map, "#{head}|#{element}") end)

    if all_rule_matches do
      valid_update?(tail, rule_map)
    else
      false
    end
  end

  defp middle_element(list) do
    middle_index =
      length(list)
      |> div(2)

    Enum.at(list, middle_index)
  end
end

PrintQueue.solve()
|> IO.inspect()
