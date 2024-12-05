# Part 2 of the puzzle

defmodule PrintQueue do
  def solve do
    [rule_input, update_input] =
      IO.read(:eof)
      |> String.split("\n\n", trime: true)
      |> Enum.map(fn part -> String.split(part, "\n", trim: true) end)

    rule_map =
      rule_input
      |> Map.new(fn rule -> {rule, :ok} end)

    update_input
    |> Enum.map(fn update -> String.split(update, ",") end)
    |> Enum.filter(fn update -> !valid_update?(update, rule_map) end)
    |> Enum.map(fn invalid_update -> fix_update(invalid_update, rule_map) end)
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

  defp fix_update(invalid_update, rule_map) do
    [pivot | remaining] = invalid_update
    do_fix_update([], pivot, remaining, rule_map)
  end

  defp do_fix_update(fixed, pivot, [], _) do
    fixed ++ [pivot]
  end

  defp do_fix_update(fixed, pivot, remaining, rule_map) do
    [head | tail] = remaining

    case find_to_replace(pivot, [], remaining, rule_map) do
      {:nothing, _} ->
        do_fix_update(fixed ++ [pivot], head, tail, rule_map)

      {:found, {passed, problematic, tail}} ->
        do_fix_update(fixed, problematic, passed ++ [pivot] ++ tail, rule_map)
    end
  end

  defp find_to_replace(_, _, [], _) do
    {:nothing, nil}
  end

  defp find_to_replace(pivot, passed, remaining, rule_map) do
    [head | tail] = remaining
    key = "#{pivot}|#{head}"

    if !Map.has_key?(rule_map, key) do
      {:found, {passed, head, tail}}
    else
      find_to_replace(pivot, passed ++ [head], tail, rule_map)
    end
  end
end

PrintQueue.solve()
|> IO.inspect()
