defmodule Display do
  alias Display.GraphIt

  @spec as_file(map(), mfa()) :: :ok
  def as_file(map, root_mfa) do
    stats =
      map
      |> CodeVis.module_stats()
      |> CodeVis.assign_module_colors()

    map
    |> GraphIt.new(root_mfa, stats)
    |> GraphIt.to_file()
  end

  @spec as_io(map(), mfa()) :: :ok
  def as_io(map, root_mfa) do
    IO.puts(print_map(map, root_mfa))
  end

  @spec format_mfa(mfa()) :: String.t()
  def format_mfa({module, function_name, arity}) do
    "#{inspect(module)}.#{function_name}/#{arity}"
  end

  @spec print_map(map(), mfa(), integer()) :: String.t()
  defp print_map(map, mfa, level \\ 0) do
    case Map.fetch!(map, mfa) do
      %{children: []} ->
        "#{indent(level)}#{format_mfa(mfa)} -> leaf"

      %{children: other_calls} ->
        sub_lines =
          other_calls
          |> Enum.map(fn next -> print_map(map, next, level + 2) end)
          |> Enum.join("\n")

        """
        #{indent(level)}#{format_mfa(mfa)} ->
        #{sub_lines}
        """
    end
  end

  @spec indent(integer()) :: String.t()
  defp indent(level), do: String.duplicate("-", level)
end
