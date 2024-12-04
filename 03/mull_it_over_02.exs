# Part 2 of the puzzle

defmodule MullItOver do
  @operations_regex ~r/mul\((?<op1>\d{1,3}),(?<op2>\d{1,3})\)|do\(\)|don't\(\)/

  def solve do
    input =
      IO.read(:eof)
      |> String.replace("\n", "")

    operation_list =
      @operations_regex
      |> Regex.scan(input)

    compute_operations(operation_list, :enabled, 0)
  end

  defp compute_operations([], _, sum) do
    sum
  end

  defp compute_operations([["do()"] | tail], _, sum) do
    compute_operations(tail, :enabled, sum)
  end

  defp compute_operations([["don't()"] | tail], _, sum) do
    compute_operations(tail, :disabled, sum)
  end

  defp compute_operations([head | tail], :enabled, sum) do
    compute_operations(tail, :enabled, sum + mul_on_capture(head))
  end

  defp compute_operations([_ | tail], :disabled, sum) do
    compute_operations(tail, :disabled, sum)
  end

  defp mul_on_capture(mul_capture) do
    mul_capture
    |> tl()
    |> Enum.map(&String.to_integer/1)
    |> Enum.product()
  end
end

MullItOver.solve()
|> IO.inspect()
