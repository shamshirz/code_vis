defmodule Mix.Tasks.Visualize do
  @moduledoc """
  Trace compiled functions and display a tree of called functions for a given root
  """
  @shortdoc "Displays function dependencies"
  @requirements ["app.config"]

  use Mix.Task

  @impl true
  def run(_) do
    unless Version.match?(System.version(), ">= 1.10.0-rc") do
      Mix.raise("Elixir v1.10+ is required!")
    end

    # Mix.Task.run("app.start")
    :ets.new(:functions, [:named_table, :public, :duplicate_bag])
    # Mix.Task.clear()
    IO.inspect(Application.load(:code_vis))
    Mix.Task.rerun("compile.elixir", ["--force", "--tracer", "CodeVis.FunctionTracer"])

    IO.puts("Trace complete. Building Tree…")

    # root = {CodeVis, :i_alias, 0}
    root = {TestProject, :i_alias, 0}

    # tree = build_tree(root)
    map = build_map(root)

    # callees = get_callees(root)

    IO.puts("Results for: #{Display.format_mfa(root)}\n")
    # IO.puts("#{Display.format_mfa(root)} -> #{format_ets_result(callees)}")
    # IO.inspect(map)
    Display.as_io(map, root)
    Display.as_file(map, root)
  end

  # defp run(module, alias) do
  #   {:ok, _} = Import2Alias.Server.start_link(module)
  #   Code.compiler_options(parser_options: [columns: true])
  #   Mix.Task.rerun("compile.elixir", ["--force", "--tracer", "Import2Alias.CallerTracer"])
  #   entries = Import2Alias.Server.entries()
  #   Import2Alias.import2alias(alias, entries)
  # end

  @spec get_remote_calls(mfa()) :: [mfa()]
  def get_remote_calls(mfa) do
    :functions
    |> :ets.lookup(mfa)
    |> Enum.map(&elem(&1, 1))
  end

  # This should live elsewhere
  @doc """
  Create a flat map and recurse over it (basically just like in the ets table)
  """
  @spec build_map(map(), mfa()) :: map()
  def build_map(accumulator \\ %{}, current_mfa) do
    case get_remote_calls(current_mfa) do
      [] ->
        # base case
        Map.put(accumulator, current_mfa, [])

      remote_mfas ->
        updated = Map.put(accumulator, current_mfa, remote_mfas)

        Enum.reduce(remote_mfas, updated, fn next_mfa, acc ->
          build_map(acc, next_mfa)
        end)
    end
  end
end
