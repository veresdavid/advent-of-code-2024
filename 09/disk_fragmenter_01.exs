# Part 1 of the puzzle

defmodule DiskFragmenter do
  def solve do
    IO.read(:line)
    |> String.trim()
    |> to_long_format()
    |> move_blocks()
    |> Enum.with_index(fn {element}, index -> {index, element} end)
    |> Enum.map(fn {index, element} -> index * element end)
    |> Enum.sum()
  end

  defp to_long_format(input) do
    input_numbers =
      input
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)

    do_to_long_format(input_numbers, 0, :file, [])
  end

  defp do_to_long_format([], _, _, accumulator) do
    Enum.reverse(accumulator)
  end

  defp do_to_long_format([head | tail], id, :file, accumulator) do
    sub_list = repeat_wrapped_in_tuple(id, head)

    do_to_long_format(tail, id + 1, :free, sub_list ++ accumulator)
  end

  defp do_to_long_format([head | tail], id, :free, accumulator) do
    sub_list = repeat_wrapped_in_tuple(-1, head)

    do_to_long_format(tail, id, :file, sub_list ++ accumulator)
  end

  defp repeat_wrapped_in_tuple(_, 0) do
    []
  end

  defp repeat_wrapped_in_tuple(id, times) do
    for _ <- 1..times do
      {id}
    end
  end

  defp move_blocks(blocks) do
    number_of_file_blocks = Enum.count(blocks, fn block -> block != {-1} end)

    reversed_file_blocks =
      blocks
      |> Enum.filter(fn block -> block != {-1} end)
      |> Enum.reverse()

    do_move_blocks(blocks, reversed_file_blocks, number_of_file_blocks, [])
  end

  defp do_move_blocks(_, _, 0, accumulator) do
    Enum.reverse(accumulator)
  end

  defp do_move_blocks(
         [{-1} | tail],
         [head | remaining_reversed_file_blocks],
         remaining,
         accumulator
       ) do
    do_move_blocks(tail, remaining_reversed_file_blocks, remaining - 1, [head | accumulator])
  end

  defp do_move_blocks([head | tail], reversed_file_blocks, remaining, accumulator) do
    do_move_blocks(tail, reversed_file_blocks, remaining - 1, [head | accumulator])
  end
end

DiskFragmenter.solve()
|> IO.inspect()
