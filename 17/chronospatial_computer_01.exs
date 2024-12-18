# Part 1 of the puzzle

defmodule ChronospatialComputer do
  @register_regex ~r/^Register (A|B|C): (?<register_value>\d+)$/

  def solve do
    device =
      IO.read(:eof)
      |> String.split("\n", trim: true)
      |> parse_device()

    device
    |> run_device()
    |> Map.get(:output)
    |> Enum.join(",")
  end

  defp parse_device(input_list) do
    [
      register_a_input,
      register_b_input,
      register_c_input,
      program_input
    ] = input_list

    %{
      register_a: parse_register(register_a_input),
      register_b: parse_register(register_b_input),
      register_c: parse_register(register_c_input),
      program: parse_program(program_input),
      instruction_pointer: 0,
      output: []
    }
  end

  defp parse_register(register_input) do
    @register_regex
    |> Regex.named_captures(register_input)
    |> Map.get("register_value")
    |> String.to_integer()
  end

  defp parse_program(program_input) do
    program_input
    |> String.replace("Program: ", "")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  defp run_device(device = %{program: program, instruction_pointer: instruction_pointer})
       when instruction_pointer >= length(program) do
    device
  end

  defp run_device(device) do
    opcode = Enum.at(device.program, device.instruction_pointer)

    new_device =
      case opcode do
        0 -> adv(device)
        1 -> bxl(device)
        2 -> bst(device)
        3 -> jnz(device)
        4 -> bxc(device)
        5 -> out(device)
        6 -> bdv(device)
        7 -> cdv(device)
      end

    run_device(new_device)
  end

  defp adv(device) do
    operand_code = Enum.at(device.program, device.instruction_pointer + 1)
    operand = resolve_combo_operand(operand_code, device)

    numerator = device.register_a
    denominator = Integer.pow(2, operand)

    result = div(numerator, denominator)

    device
    |> Map.put(:register_a, result)
    |> Map.update!(:instruction_pointer, fn ip_value -> ip_value + 2 end)
  end

  defp bxl(device) do
    left_operand = device.register_b
    right_operand = Enum.at(device.program, device.instruction_pointer + 1)

    result = Bitwise.bxor(left_operand, right_operand)

    device
    |> Map.put(:register_b, result)
    |> Map.update!(:instruction_pointer, fn ip_value -> ip_value + 2 end)
  end

  defp bst(device) do
    operand_code = Enum.at(device.program, device.instruction_pointer + 1)
    operand = resolve_combo_operand(operand_code, device)

    result = rem(operand, 8)

    device
    |> Map.put(:register_b, result)
    |> Map.update!(:instruction_pointer, fn ip_value -> ip_value + 2 end)
  end

  defp jnz(device) do
    if device.register_a == 0 do
      device
      |> Map.update!(:instruction_pointer, fn ip_value -> ip_value + 2 end)
    else
      operand = Enum.at(device.program, device.instruction_pointer + 1)

      device
      |> Map.put(:instruction_pointer, operand)
    end
  end

  defp bxc(device) do
    left_operand = device.register_b
    right_operand = device.register_c

    result = Bitwise.bxor(left_operand, right_operand)

    device
    |> Map.put(:register_b, result)
    |> Map.update!(:instruction_pointer, fn ip_value -> ip_value + 2 end)
  end

  defp out(device) do
    operand_code = Enum.at(device.program, device.instruction_pointer + 1)
    operand = resolve_combo_operand(operand_code, device)

    result = rem(operand, 8)

    device
    |> Map.update!(:output, fn output -> output ++ [result] end)
    |> Map.update!(:instruction_pointer, fn ip_value -> ip_value + 2 end)
  end

  defp bdv(device) do
    operand_code = Enum.at(device.program, device.instruction_pointer + 1)
    operand = resolve_combo_operand(operand_code, device)

    numerator = device.register_a
    denominator = Integer.pow(2, operand)

    result = div(numerator, denominator)

    device
    |> Map.put(:register_b, result)
    |> Map.update!(:instruction_pointer, fn ip_value -> ip_value + 2 end)
  end

  defp cdv(device) do
    operand_code = Enum.at(device.program, device.instruction_pointer + 1)
    operand = resolve_combo_operand(operand_code, device)

    numerator = device.register_a
    denominator = Integer.pow(2, operand)

    result = div(numerator, denominator)

    device
    |> Map.put(:register_c, result)
    |> Map.update!(:instruction_pointer, fn ip_value -> ip_value + 2 end)
  end

  defp resolve_combo_operand(operand_code, device) do
    case operand_code do
      0 -> 0
      1 -> 1
      2 -> 2
      3 -> 3
      4 -> device.register_a
      5 -> device.register_b
      6 -> device.register_c
    end
  end
end

ChronospatialComputer.solve()
|> IO.inspect()
