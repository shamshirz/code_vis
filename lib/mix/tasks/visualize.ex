defmodule Mix.Tasks.Visualize do
  @moduledoc """
  Trace compiled functions and display a tree of called functions for a given root

  ## Visualize args

  The visualize task expects a module, function, arity string:

    mix visualize Module.function/#

  ## Example

    mix visualize Display.as_file/2
  """
  @shortdoc "Displays function dependencies"
  @requirements ["app.config"]

  use Mix.Task

  @impl true
  def run(args) do
    unless Version.match?(System.version(), ">= 1.10.0-rc") do
      Mix.raise("Elixir v1.10+ is required!")
    end

    :ets.new(:functions, [:named_table, :public, :duplicate_bag])
    Mix.Task.rerun("compile.elixir", ["--force", "--tracer", "CodeVis.FunctionTracer"])

    IO.puts("Trace complete. Building Tree…")

    root = parse_root(args)
    user_modules = CodeVis.ProjectAnalysis.user_modules() |> IO.inspect(label: "mods")

    map = build_map(root, user_modules)

    IO.puts("Results for: #{Display.format_mfa(root)}\n")
    Display.as_io(map, root)
    Display.as_file(map, root)
  end

  # Parse the input mfa_string if available.
  # Given no arg, attempts to default to the first function in the table - not a great display
  @spec parse_root([String.t()]) :: mfa()
  defp parse_root(args) do
    case args do
      [] ->
        case :ets.first(:functions) do
          :"$end_of_table" ->
            Mix.raise("no functions were found during compilation trace")

          key ->
            IO.puts("We didn't find a passed in MFA, so we default to a random function: #{key}")

            key
        end

      [mfa_string] ->
        case Mix.Utils.parse_mfa(mfa_string) do
          {:ok, [m, f, a]} ->
            {m, f, a}

          _ ->
            Mix.raise("I wasn't able to parse `#{mfa_string}` into a {Module, Function, Arity}")
        end
    end
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
  Adjacency matrix
  Includes only functions that are within user defined modules
  """
  @spec build_map(map(), mfa(), [module()]) :: map()
  def build_map(accumulator \\ %{}, current_mfa, user_modules) do
    case get_remote_calls(current_mfa) |> Enum.filter(fn {m, _f, _a} -> m in user_modules end) do
      [] ->
        # base case
        Map.put(accumulator, current_mfa, [])

      remote_mfas ->
        updated = Map.put(accumulator, current_mfa, remote_mfas)

        Enum.reduce(remote_mfas, updated, fn next_mfa, acc ->
          build_map(acc, next_mfa, user_modules)
        end)
    end
  end
end
