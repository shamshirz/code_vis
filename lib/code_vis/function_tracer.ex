defmodule CodeVis.FunctionTracer do
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

  End result
  ETS table `:functions` with an entry for every Function called and a list of all of the functions called from within that function
  """

  # def trace({:imported_function, meta, module, name, arity}, env) do
  #   Import2Alias.Server.record(env.file, meta[:line], meta[:column], module, name, arity)
  #   :ok
  # end

  # 1. Add more context to what's happening in trace/2
  # 2. What about a Module white list rather than black list?
  #   use Tracer modules: [CodeVis, Display]
  #   vs.
  #   Tracer (hardcoded ignore modules, there will be more and I won't be able to catch them)
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
    # IO.inspect(env.file, label: "module:#{module}")

    with {caller_name, caller_arity} <- env.function do
      caller = {env.module, caller_name, caller_arity}
      target = {module, name, arity}
      :ets.insert(:functions, {caller, target})
      # IO.puts("#{Display.format_mfa(caller)} -> #{Display.format_mfa(target)}")
    end

    :ok
  end

  def trace({:local_function, _meta, name, arity}, env) do
    # meta = `[line: number :: int]`
    with {caller_name, caller_arity} <- env.function do
      caller = {env.module, caller_name, caller_arity}
      target = {env.module, name, arity}
      # IO.puts("LOCAL: #{Display.format_mfa(caller)} -> #{Display.format_mfa(target)}")
      :ets.insert(:functions, {caller, target})
    end

    :ok
  end

  def trace(_, _), do: :ok
end
