defmodule TreeTracer do
  @moduledoc """
  Trace remote function calls, aggregating them into an ets table
  Key: caller_mfa
  Value: target_mfa

  ex
  iex(16)> :ets.lookup(:functions, {"A", "key"})
    [
      {{"A", "key"}, {"B", "value"}},
      {{"A", "key"}, {"C", "value"}},
      {{"A", "key"}, {"D", "value"}}
    ]

  Ideally at the end we can recursively build a tree from a top level function of all the dependants
  """

  def run() do
    :ets.new(:functions, [:named_table, :public, :duplicate_bag])
    Mix.Task.clear()
    Mix.Task.run("compile", ["--force", "--tracer", __MODULE__])

    IO.puts("Trace complete. Building Tree…")

    root = {CodeVis, :i_alias, 0}

    # tree = build_tree(root)
    map = build_map(root)

    # callees = get_callees(root)

    IO.puts("Results for: #{Display.format_mfa(root)}\n")
    # IO.puts("#{Display.format_mfa(root)} -> #{format_ets_result(callees)}")
    # IO.inspect(map)
    Display.as_io(map, root)
    Display.as_file(map, root)
  end

  @type remote_call_result :: {mfa(), list()}

  @doc """
  Each MFA will return a list of remote MFAs called
  [ {mfa_a, [
      {mfa_b, []},
      {mfa_c, [ {mfa_d, []} ] }
    }
  ]
  """
  @spec build_tree(mfa()) :: [remote_call_result()]
  def build_tree(current_mfa) do
    case get_remote_calls(current_mfa) do
      [] ->
        # base case
        [{current_mfa, []}]

      remote_mfas ->
        [{current_mfa, Enum.map(remote_mfas, fn target -> {target, build_tree(target)} end)}]
    end
  end

  @spec get_remote_calls(mfa()) :: [mfa()]
  def get_remote_calls(mfa) do
    :functions
    |> :ets.lookup(mfa)
    |> Enum.map(&elem(&1, 1))
  end

  @doc """
  Alternate implementation, create a flat map and recurse over it (basically just like in the ets table)
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

  # skip built ins (TODO: Make this dynamic so it's not trial and error)
  @spec trace(tuple, Macro.Env.t()) :: :ok
  def trace({:remote_function, _meta, module, _name, _arity}, _env)
      when module in [
             :elixir_def,
             :elixir_module,
             :elixir_utils,
             Kernel.LexicalTracker,
             Module
           ],
      do: :ok

  def trace({:remote_function, _meta, module, name, arity}, env) do
    # IO.inspect(env.module)
    # env.line
    with {caller_name, caller_arity} <- env.function do
      caller = {env.module, caller_name, caller_arity}
      target = {module, name, arity}
      :ets.insert(:functions, {caller, target})
      # IO.puts("#{Display.format_mfa(caller)} -> #{Display.format_mfa(target)}")
    end

    :ok
  end

  def trace(_, _), do: :ok
end

TreeTracer.run()
