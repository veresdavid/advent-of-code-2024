# Part 1 of the puzzle

defmodule MonkeyMarket do
  def solve do
    IO.read(:eof)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(fn input -> generate_nth_secret(input, 2000) end)
    |> Enum.sum()
  end

  defp generate_nth_secret(input, 0) do
    input
  end

  defp generate_nth_secret(input, number) do
    new_secret = generate_secret(input)
    generate_nth_secret(new_secret, number - 1)
  end

  defp generate_secret(input) do
    input
    |> first_calculation()
    |> second_calculation()
    |> third_calculation()
  end

  defp first_calculation(input) do
    (input * 64)
    |> mix(input)
    |> prune()
  end

  defp second_calculation(input) do
    input
    |> div(32)
    |> mix(input)
    |> prune()
  end

  defp third_calculation(input) do
    (input * 2048)
    |> mix(input)
    |> prune()
  end

  defp mix(input, into) do
    Bitwise.bxor(input, into)
  end

  defp prune(input) do
    rem(input, 16_777_216)
  end
end

MonkeyMarket.solve()
|> IO.inspect()
