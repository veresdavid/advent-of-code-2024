# Part 1 of the puzzle

defmodule PlutonianPebbles do
  def solve do
    IO.read(:line)
    |> String.trim()
    |> String.split(" ")
    |> blink(25)
    |> Enum.count()
  end

  defp blink(numbers, 0) do
    numbers
  end

  defp blink(numbers, remaining) do
    new_numbers =
      Enum.reduce(numbers, [], fn number, acc ->
        sub_result =
          cond do
            number == "0" ->
              ["1"]

            has_even_digits?(number) ->
              {left, right} = String.split_at(number, div(String.length(number), 2))

              [left, right]
              |> Enum.map(&String.to_integer/1)
              |> Enum.map(&Integer.to_string/1)

            true ->
              new_number = String.to_integer(number) * 2024
              ["#{new_number}"]
          end

        acc ++ sub_result
      end)

    blink(new_numbers, remaining - 1)
  end

  defp has_even_digits?(number) do
    rem(String.length(number), 2) == 0
  end
end

PlutonianPebbles.solve()
|> IO.inspect()
