# Part 1 of the puzzle

defmodule MullItOver do
  @mul_regex ~r/mul\((?<op1>\d{1,3}),(?<op2>\d{1,3})\)/

  def solve do
    IO.read(:eof)
    |> String.split("\n", trim: true)
    |> Enum.map(&sum_mul_operations/1)
    |> Enum.sum()
  end

  defp sum_mul_operations(input) do
    @mul_regex
    |> Regex.scan(input)
    |> Enum.map(&mul_on_capture/1)
    |> Enum.sum()
  end

  defp mul_on_capture(mul_capture) do
    tl(mul_capture)
    |> Enum.map(&String.to_integer/1)
    |> Enum.product()
  end
end

MullItOver.solve()
|> IO.inspect()
