# Part 1 of the puzzle

defmodule BridgeRepair do
  @single_number_regex ~r/^\d+$/
  @short_expression_regex ~r/(?<op1>\d+)(?<opr>\*|\+)(?<op2>\d+)/
  @operators ["+", "*"]

  def solve do
    IO.read(:eof)
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_input_line/1)
    |> Enum.filter(&can_be_made_true?/1)
    |> Enum.map(fn {result, _} -> result end)
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
  end

  defp parse_input_line(line) do
    [result, numbers] =
      line
      |> String.split(": ")

    {result, numbers}
  end

  defp can_be_made_true?({result, expression}) do
    do_can_be_made_true?([expression], result)
  end

  defp do_can_be_made_true?([], _) do
    false
  end

  defp do_can_be_made_true?([expression | tail], result) do
    unless String.contains?(expression, " ") do
      case evaluate_expression(expression) do
        ^result ->
          true

        _ ->
          do_can_be_made_true?(tail, result)
      end
    else
      new_states =
        @operators
        |> Enum.map(fn operator ->
          String.replace(expression, " ", operator, global: false)
        end)

      do_can_be_made_true?(new_states ++ tail, result)
    end
  end

  defp evaluate_expression(expression) do
    cond do
      Regex.match?(@single_number_regex, expression) ->
        expression

      [op1, opr, op2] = Regex.run(@short_expression_regex, expression, capture: :all_but_first) ->
        sub_result = evaluate_short_expression(op1, opr, op2)

        new_expression =
          expression
          |> String.replace("#{op1}#{opr}#{op2}", sub_result, global: false)

        evaluate_expression(new_expression)
    end
  end

  defp evaluate_short_expression(operand1, operator, operand2) do
    op1_int = operand1 |> String.to_integer()
    op2_int = operand2 |> String.to_integer()

    result =
      case operator do
        "+" ->
          op1_int + op2_int

        "*" ->
          op1_int * op2_int
      end

    result
    |> Integer.to_string()
  end
end

BridgeRepair.solve()
|> IO.inspect()