# Part 1 of the puzzle

defmodule LanParty do
  def solve do
    connection_inputs =
      IO.read(:eof)
      |> String.split("\n", trim: true)

    nodes =
      connection_inputs
      |> Enum.flat_map(fn conn -> String.split(conn, "-") end)
      |> MapSet.new()

    connections =
      connection_inputs
      |> Enum.flat_map(fn conn ->
        [node_1, node_2] = String.split(conn, "-")
        [{node_1, node_2}, {node_2, node_1}]
      end)
      |> MapSet.new()

    for node_1 <- nodes,
        node_2 <- nodes,
        node_3 <- nodes,
        MapSet.member?(connections, {node_1, node_2}),
        MapSet.member?(connections, {node_2, node_3}),
        MapSet.member?(connections, {node_3, node_1}) do
      {node_1, node_2, node_3}
    end
    |> Enum.filter(fn {node_1, node_2, node_3} ->
      [node_1, node_2, node_3]
      |> Enum.any?(fn node -> String.starts_with?(node, "t") end)
    end)
    |> length()
    |> div(6)
  end
end

LanParty.solve()
|> IO.inspect()
