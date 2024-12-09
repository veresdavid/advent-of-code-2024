# Part 2 of the puzzle

defmodule DiskFragmenter do
  def solve do
    IO.read(:line)
    |> String.trim()
    |> to_long_format()
    |> move_whole_files()
    |> checksum_block_map()
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

  defp move_whole_files(blocks) do
    max_index =
      blocks
      |> Enum.reverse()
      |> Enum.find(fn block -> block != {-1} end)
      |> elem(0)

    block_map =
      blocks
      |> Enum.with_index(fn {value}, index -> {index, value} end)
      |> Map.new()

    do_move_whole_files(block_map, max_index)
  end

  defp do_move_whole_files(block_map, 0) do
    block_map
  end

  defp do_move_whole_files(block_map, current_index) do
    space_layout =
      block_map_to_space_layout(block_map)

    free_space_options =
      Regex.scan(~r/\.+/, space_layout, return: :index)
      |> Enum.map(&hd/1)

    target_file_blocks =
      block_map
      |> Enum.filter(fn {_, index} -> index == current_index end)
      |> Enum.sort()

    file_block_size = length(target_file_blocks)

    first_block =
      target_file_blocks
      |> hd()

    new_block_map =
      shift_file_to_left(free_space_options, file_block_size, first_block, block_map)

    do_move_whole_files(new_block_map, current_index - 1)
  end

  defp block_map_to_space_layout(block_map) do
    block_map
    |> Enum.sort()
    |> Enum.map(fn {_, index} ->
      if index == -1, do: ".", else: "#"
    end)
    |> Enum.join()
  end

  defp shift_file_to_left(free_space_options, file_block_size, first_block, block_map) do
    {first_block_index, value} = first_block

    case Enum.find(free_space_options, fn {_, size} -> size >= file_block_size end) do
      nil ->
        block_map

      {free_index, _} when free_index < first_block_index ->
        new_block_map =
          first_block_index..(first_block_index + file_block_size - 1)
          |> Enum.reduce(block_map, fn idx, acc -> Map.put(acc, idx, -1) end)

        free_index..(free_index + file_block_size - 1)
        |> Enum.reduce(new_block_map, fn idx, acc -> Map.put(acc, idx, value) end)

      _ ->
        block_map
    end
  end

  defp checksum_block_map(block_map) do
    Enum.reduce(block_map, 0, fn {idx, val}, acc ->
      sub_result = if val != -1, do: idx * val, else: 0
      acc + sub_result
    end)
  end
end

DiskFragmenter.solve()
|> IO.inspect()
