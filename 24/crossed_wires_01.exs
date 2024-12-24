# Part 1 of the puzzle

defmodule CrossedWires do
  def solve do
    [wire_input, operation_input] =
      IO.read(:eof)
      |> String.split("\n\n")

    wires =
      wire_input
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_wire_input/1)
      |> Map.new()

    operations =
      operation_input
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_operation_input/1)
      |> Map.new()

    solve_operations(operations, wires)
    |> Enum.filter(fn {wire, _} -> String.starts_with?(wire, "z") end)
    |> Enum.sort_by(fn {wire, _} -> wire end, :desc)
    |> Enum.map(fn {_, bit} -> bit end)
    |> Enum.join()
    |> String.to_integer(2)
  end

  defp parse_wire_input(input) do
    [wire, value] =
      input
      |> String.split(": ")

    {wire, String.to_integer(value)}
  end

  defp parse_operation_input(input) do
    [left, operation, right, output] =
      input
      |> String.replace(" -> ", " ")
      |> String.split(" ")

    operation_key = left <> operation <> right <> output

    {operation_key, {left, operation, right, output}}
  end

  defp solve_operations(operations, wires) when map_size(operations) == 0 do
    wires
  end

  defp solve_operations(operations, wires) do
    {operation_key, {left, operation, right, output}} =
      Enum.find(operations, fn {_, {left, _, right, _}} ->
        Map.has_key?(wires, left) and Map.has_key?(wires, right)
      end)

    left_value = Map.get(wires, left)
    right_value = Map.get(wires, right)

    new_value = solve_operation(left_value, operation, right_value)
    new_operations = Map.delete(operations, operation_key)
    new_wires = Map.put(wires, output, new_value)

    solve_operations(new_operations, new_wires)
  end

  defp solve_operation(left, operation, right) do
    case operation do
      "AND" -> Bitwise.band(left, right)
      "OR" -> Bitwise.bor(left, right)
      "XOR" -> Bitwise.bxor(left, right)
    end
  end
end

CrossedWires.solve()
|> IO.inspect()
