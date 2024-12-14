# Part 1 of the puzzle

defmodule ClawContraption do
  @button_regex ~r/^Button .+: X\+(?<x>\d+), Y\+(?<y>\d+)$/
  @prize_regex ~r/^Prize: X=(?<x>\d+), Y=(?<y>\d+)$/
  @a_button_prize 3
  @b_button_prize 1

  def solve do
    IO.read(:eof)
    |> String.split("\n", trim: true)
    |> Enum.chunk_every(3)
    |> Enum.map(&parse_machine/1)
    |> Enum.map(&find_optimal_solution/1)
    |> Enum.map(&count_tokens/1)
    |> Enum.sum()
  end

  defp parse_machine([button_a, button_b, prize]) do
    %{"x" => a_x, "y" => a_y} = Regex.named_captures(@button_regex, button_a)
    %{"x" => b_x, "y" => b_y} = Regex.named_captures(@button_regex, button_b)
    %{"x" => prize_x, "y" => prize_y} = Regex.named_captures(@prize_regex, prize)

    %{
      button_a: {String.to_integer(a_x), String.to_integer(a_y)},
      button_b: {String.to_integer(b_x), String.to_integer(b_y)},
      prize: {String.to_integer(prize_x), String.to_integer(prize_y)}
    }
  end

  defp find_optimal_solution(machine) do
    %{
      button_a: {a_x, a_y},
      button_b: {b_x, b_y},
      prize: {prize_x, prize_y}
    } = machine

    # solve equation system to get B button press count
    dividend = prize_x * a_y - prize_y * a_x
    divisor = b_x * a_y - b_y * a_x

    # only accept it, if we get an integer result for B press count
    if rem(dividend, divisor) == 0 do
      # based on B press count, we can get A press count
      b_count = div(dividend, divisor)
      a_count = div(prize_x - b_count * b_x, a_x)

      {a_count, b_count}
    else
      nil
    end
  end

  defp count_tokens(solution) do
    case solution do
      nil ->
        0

      {a_count, b_count} ->
        a_count * @a_button_prize + b_count * @b_button_prize
    end
  end
end

ClawContraption.solve()
|> IO.inspect()
