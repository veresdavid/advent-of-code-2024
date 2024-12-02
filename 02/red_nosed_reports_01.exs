# Part 1 of the puzzle

defmodule RedNosedReports do
  def solve do
    safe_reports =
      IO.read(:eof)
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split/1)
      |> Enum.map(fn list -> Enum.map(list, &String.to_integer/1) end)
      |> Enum.filter(&safe_report?/1)

    length(safe_reports)
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
end

RedNosedReports.solve()
|> IO.inspect()
