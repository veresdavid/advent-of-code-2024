# Part 2 of the puzzle

defmodule RedNosedReports do
  def solve do
    {safe, unsafe} =
      IO.read(:eof)
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split/1)
      |> Enum.map(fn list -> Enum.map(list, &String.to_integer/1) end)
      |> Enum.reduce({[], []}, fn list, {safe, unsafe} ->
        case safe_report?(list) do
          true -> {[list | safe], unsafe}
          false -> {safe, [list | unsafe]}
        end
      end)

    single_bad =
      unsafe
      |> Enum.filter(&single_bad?/1)

    length(safe) + length(single_bad)
  end

  defp safe_report?(list) do
    [head | tail] = list

    {diffs, _} =
      tail
      |> Enum.reduce({[], head}, fn x, {diffs, prev} -> {[x - prev | diffs], x} end)

    cond do
      Enum.find(diffs, &(&1 == 0)) -> false
      Enum.any?(diffs, &(abs(&1) > 3)) -> false
      Enum.all?(diffs, &(&1 < 0)) -> true
      Enum.all?(diffs, &(&1 > 0)) -> true
      true -> false
    end
  end

  defp single_bad?(list) do
    0..length(list)
    |> Enum.any?(fn index_to_remove -> do_single_bad?(list, index_to_remove) end)
  end

  defp do_single_bad?(list, index_to_remove) do
    list
    |> List.delete_at(index_to_remove)
    |> safe_report?()
  end
end

RedNosedReports.solve()
|> IO.inspect()
