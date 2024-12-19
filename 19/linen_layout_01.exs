# Part 1 of the puzzle

defmodule LinenLayout do
  def solve do
    [pattern_input, desired_input] =
      IO.read(:eof)
      |> String.split("\n\n")

    patterns =
      pattern_input
      |> String.split(", ")

    desired_designs =
      desired_input
      |> String.split("\n", trim: true)

    desired_designs
    |> Enum.filter(fn design -> is_possible_design?(design, patterns) end)
    |> length()
  end

  defp is_possible_design?(design, patterns) do
    do_is_possible_design?([""], design, patterns)
  end

  defp do_is_possible_design?([], _, _) do
    false
  end

  defp do_is_possible_design?([head | _], design, _) when head == design do
    true
  end

  defp do_is_possible_design?([head | tail], design, patterns) do
    possible_states =
      patterns
      |> Enum.map(fn pattern -> head <> pattern end)
      |> Enum.filter(fn candidate -> String.starts_with?(design, candidate) end)

    do_is_possible_design?(possible_states ++ tail, design, patterns)
  end
end

LinenLayout.solve()
|> IO.inspect()
