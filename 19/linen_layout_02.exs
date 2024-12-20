# Part 2 of the puzzle

defmodule LinenLayout do
  def solve do
    # parse input
    [pattern_input, desired_input] =
      IO.read(:eof)
      |> String.split("\n\n")

    patterns =
      pattern_input
      |> String.split(", ")

    desired_designs =
      desired_input
      |> String.split("\n", trim: true)

    # init
    sorted_patterns =
      patterns
      |> Enum.sort_by(&String.length/1)

    initial_cache = build_initial_cache(patterns)

    sorted_designs =
      desired_designs
      |> Enum.sort_by(&String.length/1)

    # solution
    {result, _} =
      sorted_designs
      |> Enum.filter(fn design -> is_possible_design?(design, sorted_patterns) end)
      |> Enum.reduce({0, initial_cache}, fn design, {sum, current_cache} ->
        {num_of_sols, updated_cache} = fast_num_of_sols(design, sorted_patterns, current_cache)

        {sum + num_of_sols, updated_cache}
      end)

    result
  end

  defp build_initial_cache(patterns) do
    sorted_patterns =
      patterns
      |> Enum.sort_by(&String.length/1)

    # build cache from bottom to top
    # some base patterns might be built up from other base patterns
    {_, built_cache} =
      Enum.reduce(sorted_patterns, {[], %{}}, fn pattern, {known_patterns, current_cache} ->
        new_cache =
          if is_possible_design?(pattern, known_patterns) do
            {_, updated_cache} =
              fast_num_of_sols(pattern, known_patterns, current_cache)

            Map.update(updated_cache, pattern, 1, fn val -> val + 1 end)
          else
            Map.put(current_cache, pattern, 1)
          end

        {[pattern | known_patterns], new_cache}
      end)

    built_cache
  end

  # dynamic programming based solution
  # updating the cache each time we solve a sub-problem
  defp fast_num_of_sols(design, patterns, cache) do
    updated_cache = do_fast_num_of_sols([{"", design}], patterns, cache)

    num_of_sols = Map.get(updated_cache, design, 0)

    {num_of_sols, updated_cache}
  end

  defp do_fast_num_of_sols([], _, cache) do
    cache
  end

  defp do_fast_num_of_sols(stack, patterns, cache) do
    [head | tail] = stack
    {left, right} = head

    cond do
      # if we have the answer in cache, we can use it to create new cache elements
      Map.has_key?(cache, right) ->
        cache_right_value = Map.get(cache, right)
        new_cache_key = left <> right

        new_cache =
          if left != "" do
            Map.update(cache, new_cache_key, cache_right_value, fn val ->
              val + cache_right_value
            end)
          else
            cache
          end

        do_fast_num_of_sols(tail, patterns, new_cache)

      # if we don't know the answer yet, split and get answer from sub-results
      true ->
        valid_patterns =
          patterns
          |> Enum.filter(fn pattern -> String.starts_with?(right, pattern) end)
          |> Enum.filter(fn pattern ->
            # try to avoid dead ends
            candidate = String.replace(right, pattern, "", global: false)
            Enum.any?(patterns, fn p -> String.starts_with?(candidate, p) end)
          end)

        if valid_patterns == [] do
          # we cant split, so this branch is not possible
          # as it is not possible, so save it as 0
          new_cache = Map.put(cache, right, 0)
          do_fast_num_of_sols(tail, patterns, new_cache)
        else
          new_stack_elements =
            valid_patterns
            |> Enum.map(fn pattern ->
              new_right = String.replace(right, pattern, "", global: false)

              {pattern, new_right}
            end)

          new_stack = new_stack_elements ++ stack

          do_fast_num_of_sols(new_stack, patterns, cache)
        end
    end
  end

  # check from part 01

  defp is_possible_design?(design, patterns) do
    do_is_possible_design?([""], design, patterns)
  end

  defp do_is_possible_design?([], _, _) do
    false
  end

  defp do_is_possible_design?([head | _], design, _) when head == design do
    true
  end

  defp do_is_possible_design?([head | tail], design, patterns) do
    possible_states =
      patterns
      |> Enum.map(fn pattern -> head <> pattern end)
      |> Enum.filter(fn candidate -> String.starts_with?(design, candidate) end)

    do_is_possible_design?(possible_states ++ tail, design, patterns)
  end
end

LinenLayout.solve()
|> IO.inspect()
